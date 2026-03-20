#!/usr/bin/env bash

set -euo pipefail

RXMR_CONFIG="${RXMR_CONFIG:-}"
RXMR_DATADIR="${RXMR_DATADIR:-}"
HEALTHY=1
CONFIG_PATH=""

usage() {
    cat <<'EOF'
Check whether a local rXMR daemon is synced enough to mine and serving the expected mainnet ports.

Usage:
  rxmr-doctor [--config PATH] [--datadir DIR]

Environment:
  RXMR_CONFIG   Config path (default: ~/.rxmr/rxmr.conf)
  RXMR_DATADIR  Datadir (default: ~/.rxmr)
EOF
}

info() { printf '[INFO] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; HEALTHY=0; }
error() { printf '[ERROR] %s\n' "$1" >&2; exit 1; }

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --config)
                [ $# -ge 2 ] || error "--config requires a path"
                RXMR_CONFIG="$2"
                shift 2
                ;;
            --datadir)
                [ $# -ge 2 ] || error "--datadir requires a path"
                RXMR_DATADIR="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error "Unknown argument: $1"
                ;;
        esac
    done
}

resolve_config_path() {
    CONFIG_PATH="$HOME/.rxmr/rxmr.conf"
    if [ -n "$RXMR_CONFIG" ]; then
        CONFIG_PATH="$RXMR_CONFIG"
    elif [ -n "$RXMR_DATADIR" ] && [ -f "$RXMR_DATADIR/rxmr.conf" ]; then
        CONFIG_PATH="$RXMR_DATADIR/rxmr.conf"
    fi
}

config_value() {
    local key

    key="$1"
    [ -f "$CONFIG_PATH" ] || return 1
    sed -n "s/^[[:space:]]*$key[[:space:]]*=[[:space:]]*//p" "$CONFIG_PATH" | tail -1
}

json_value() {
    python3 -c '
import json
import sys

path = [part for part in sys.argv[1].split(".") if part]
payload = json.loads(sys.argv[2])
value = payload
for part in path:
    if not isinstance(value, dict):
        raise SystemExit(1)
    value = value.get(part)
    if value is None:
        raise SystemExit(1)

if isinstance(value, bool):
    print("true" if value else "false")
else:
    print(value)
' "$1" "$(cat)"
}

rpc_curl() {
    local endpoint
    endpoint="$1"
    shift

    curl -fsS "${CURL_AUTH[@]}" "$@" "$RPC_BASE/$endpoint"
}

show_config_peers() {
    if [ ! -f "$CONFIG_PATH" ]; then
        warn "Config not found at $CONFIG_PATH"
        return
    fi

    info "Configured peers from $CONFIG_PATH:"
    grep '^add-peer=' "$CONFIG_PATH" || warn "No add-peer entries found"
}

main() {
    local rpc_host rpc_port rpc_login info_json mining_json
    local height target_height incoming outgoing busy_syncing synchronized nettype
    local active address threads speed p2p_port

    parse_args "$@"
    resolve_config_path

    command -v curl >/dev/null 2>&1 || error "curl is required"
    command -v python3 >/dev/null 2>&1 || error "python3 is required"

    rpc_host="$(config_value rpc-bind-ip || true)"
    rpc_port="$(config_value rpc-bind-port || true)"
    rpc_login="$(config_value rpc-login || true)"
    p2p_port="$(config_value p2p-bind-port || true)"

    [ -n "$rpc_host" ] || rpc_host="127.0.0.1"
    [ -n "$rpc_port" ] || rpc_port="18881"
    [ -n "$p2p_port" ] || p2p_port="18880"

    RPC_BASE="http://$rpc_host:$rpc_port"
    CURL_AUTH=()
    if [ -n "$rpc_login" ]; then
        CURL_AUTH=(--digest -u "$rpc_login")
    fi

    info "RPC endpoint: $RPC_BASE"

    info_json="$(rpc_curl json_rpc -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' 2>/dev/null || true)"
    if [ -z "$info_json" ]; then
        warn "Could not reach rxmrd RPC. Start the daemon first."
        show_config_peers
        exit 1
    fi

    mining_json="$(rpc_curl mining_status -H 'Content-Type: application/json' -d '{}' 2>/dev/null || true)"

    height="$(printf '%s' "$info_json" | json_value result.height 2>/dev/null || true)"
    target_height="$(printf '%s' "$info_json" | json_value result.target_height 2>/dev/null || true)"
    incoming="$(printf '%s' "$info_json" | json_value result.incoming_connections_count 2>/dev/null || true)"
    outgoing="$(printf '%s' "$info_json" | json_value result.outgoing_connections_count 2>/dev/null || true)"
    busy_syncing="$(printf '%s' "$info_json" | json_value result.busy_syncing 2>/dev/null || true)"
    synchronized="$(printf '%s' "$info_json" | json_value result.synchronized 2>/dev/null || true)"
    nettype="$(printf '%s' "$info_json" | json_value result.nettype 2>/dev/null || true)"

    [ -n "$nettype" ] && info "Nettype: $nettype"
    [ -n "$height" ] && info "Height: $height"
    [ -n "$target_height" ] && info "Target height: $target_height"
    [ -n "$incoming" ] && info "Inbound peers: $incoming"
    [ -n "$outgoing" ] && info "Outbound peers: $outgoing"
    [ -n "$busy_syncing" ] && info "Busy syncing: $busy_syncing"
    [ -n "$synchronized" ] && info "Synchronized: $synchronized"

    if [ "${nettype:-mainnet}" != "mainnet" ]; then
        warn "Daemon is not on mainnet"
    fi
    if [ "${outgoing:-0}" -eq 0 ]; then
        warn "No outbound peers yet"
    fi
    if [ "${busy_syncing:-false}" = "true" ] || [ "${synchronized:-false}" != "true" ]; then
        warn "Daemon is still syncing"
    fi

    if [ -n "$mining_json" ]; then
        active="$(printf '%s' "$mining_json" | json_value active 2>/dev/null || true)"
        address="$(printf '%s' "$mining_json" | json_value address 2>/dev/null || true)"
        threads="$(printf '%s' "$mining_json" | json_value threads_count 2>/dev/null || true)"
        speed="$(printf '%s' "$mining_json" | json_value speed 2>/dev/null || true)"

        [ -n "$active" ] && info "Mining active: $active"
        [ -n "$address" ] && info "Mining address: $address"
        [ -n "$threads" ] && info "Mining threads: $threads"
        [ -n "$speed" ] && info "Reported hashrate: ${speed} H/s"

        if [ "${active:-false}" != "true" ]; then
            warn "Mining is not active. Start it with rxmr-start-miner --address YOUR_RXMR_ADDRESS"
        fi
    else
        warn "Could not read /mining_status"
    fi

    if command -v ss >/dev/null 2>&1; then
        if ss -ltn 2>/dev/null | grep -q "[.:]$p2p_port[[:space:]]"; then
            info "P2P port listening: $p2p_port"
        else
            warn "P2P port $p2p_port is not listening"
        fi
    fi

    show_config_peers

    if [ "$HEALTHY" -eq 1 ]; then
        info "Node looks healthy for the current rXMR mainnet"
        exit 0
    fi

    warn "Node needs attention before it is fully ready to mine"
    exit 1
}

main "$@"
