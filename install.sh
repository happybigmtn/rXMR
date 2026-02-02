#!/usr/bin/env bash
set -euo pipefail

# Bonero Install Script
# Private money for private machines.

VERSION="${VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
DATA_DIR="${DATA_DIR:-$HOME/.bonero}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case "$ARCH" in
        x86_64|amd64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *) error "Unsupported architecture: $ARCH" ;;
    esac
    
    case "$OS" in
        linux) PLATFORM="linux-$ARCH" ;;
        darwin) PLATFORM="macos-$ARCH" ;;
        *) error "Unsupported OS: $OS" ;;
    esac
    
    info "Detected platform: $PLATFORM"
}

check_dependencies() {
    if command -v bonerod &>/dev/null; then
        CURRENT=$(bonerod --version 2>/dev/null | head -1 || echo "unknown")
        warn "Bonero already installed: $CURRENT"
    fi
}

install_from_source() {
    info "Building Bonero from source..."
    
    # Check for required tools
    for cmd in git cmake make g++; do
        command -v $cmd &>/dev/null || error "Missing required tool: $cmd"
    done
    
    # Install dependencies based on OS
    if [[ "$OS" == "linux" ]]; then
        if command -v apt-get &>/dev/null; then
            info "Installing dependencies via apt..."
            sudo apt-get update
            sudo apt-get install -y \
                build-essential cmake pkg-config git \
                libboost-all-dev libssl-dev libzmq3-dev \
                libunbound-dev libsodium-dev libhidapi-dev \
                liblzma-dev libreadline-dev libexpat1-dev \
                libusb-1.0-0-dev libudev-dev
        fi
    elif [[ "$OS" == "darwin" ]]; then
        if command -v brew &>/dev/null; then
            info "Installing dependencies via Homebrew..."
            brew install cmake boost openssl zmq unbound libsodium hidapi
        fi
    fi
    
    # Clone and build
    BUILD_DIR=$(mktemp -d)
    cd "$BUILD_DIR"
    
    info "Cloning Bonero repository..."
    git clone --recursive https://github.com/happybigmtn/bonero.git
    cd bonero
    
    info "Initializing submodules..."
    git submodule update --init --recursive
    
    info "Building (this takes 10-20 minutes)..."
    mkdir -p build && cd build
    cmake -DCMAKE_BUILD_TYPE=Release ..
    make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
    
    # Install binaries
    mkdir -p "$INSTALL_DIR"
    cp bin/bonerod bin/bonero-wallet-cli bin/bonero-wallet-rpc "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR"/bonero*
    
    info "Cleaning up build directory..."
    rm -rf "$BUILD_DIR"
}

setup_config() {
    mkdir -p "$DATA_DIR"
    
    if [[ ! -f "$DATA_DIR/bonero.conf" ]]; then
        info "Creating default config..."
        cat > "$DATA_DIR/bonero.conf" << EOF
# Bonero Configuration
log-level=1
p2p-bind-ip=0.0.0.0
p2p-bind-port=18080
rpc-bind-ip=127.0.0.1
rpc-bind-port=18081

# Seed nodes
add-peer=95.111.227.14:18080
add-peer=95.111.229.108:18080
add-peer=95.111.239.142:18080
add-peer=161.97.83.147:18080
add-peer=161.97.97.83:18080
add-peer=161.97.114.192:18080
add-peer=161.97.117.0:18080
add-peer=194.163.144.177:18080
add-peer=185.218.126.23:18080
add-peer=185.239.209.227:18080
EOF
    fi
}

add_to_path() {
    SHELL_RC=""
    if [[ -f "$HOME/.zshrc" ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        SHELL_RC="$HOME/.bashrc"
    fi
    
    if [[ -n "$SHELL_RC" ]]; then
        if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
            info "Added $INSTALL_DIR to PATH in $SHELL_RC"
        fi
    fi
}

main() {
    echo ""
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║       Bonero Installer                ║"
    echo "  ║   Private money for private machines  ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo ""
    
    detect_platform
    check_dependencies
    install_from_source
    setup_config
    
    if [[ "${1:-}" == "--add-path" ]]; then
        add_to_path
    fi
    
    echo ""
    info "Installation complete!"
    echo ""
    echo "  Binaries installed to: $INSTALL_DIR"
    echo "  Data directory: $DATA_DIR"
    echo ""
    echo "  Next steps:"
    echo "    1. Create a wallet:"
    echo "       bonero-wallet-cli --generate-new-wallet=mywallet"
    echo ""
    echo "    2. Start the daemon:"
    echo "       bonerod --detach --config-file=$DATA_DIR/bonero.conf"
    echo ""
    echo "    3. Start mining (replace ADDRESS with your wallet address):"
    echo "       bonerod --detach --start-mining ADDRESS --mining-threads 4"
    echo ""
}

main "$@"
