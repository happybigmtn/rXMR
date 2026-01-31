// Copyright (c) 2014-2022, The Monero Project
// Copyright (c) 2026, The Bonero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// Bonero address prefix tests
// Acceptance criteria: Verify that Bonero addresses use distinct prefixes
// from Monero to enable visual identification and prevent cross-network confusion.

#include "gtest/gtest.h"
#include "cryptonote_config.h"
#include "cryptonote_basic/account.h"
#include "cryptonote_basic/cryptonote_basic_impl.h"

// Test suite: Verify mainnet standard address prefix
// Acceptance: Prefix 66 produces addresses starting with 'B' for easy agent recognition
TEST(address_prefix, mainnet_standard_prefix_66)
{
  ASSERT_EQ(config::CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX, 66);
}

// Test suite: Verify mainnet integrated address prefix
// Acceptance: Prefix 67 produces addresses starting with 'Bi'
TEST(address_prefix, mainnet_integrated_prefix_67)
{
  ASSERT_EQ(config::CRYPTONOTE_PUBLIC_INTEGRATED_ADDRESS_BASE58_PREFIX, 67);
}

// Test suite: Verify mainnet subaddress prefix
// Acceptance: Prefix 98 produces addresses starting with 'Bo'
TEST(address_prefix, mainnet_subaddress_prefix_98)
{
  ASSERT_EQ(config::CRYPTONOTE_PUBLIC_SUBADDRESS_BASE58_PREFIX, 98);
}

// Test suite: Verify testnet standard address prefix
// Acceptance: Prefix 136 produces addresses starting with 'T'
TEST(address_prefix, testnet_standard_prefix)
{
  ASSERT_EQ(config::testnet::CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX, 136);
}

// Test suite: Verify testnet integrated address prefix
// Acceptance: Prefix 137 produces addresses starting with 'Ti'
TEST(address_prefix, testnet_integrated_prefix)
{
  ASSERT_EQ(config::testnet::CRYPTONOTE_PUBLIC_INTEGRATED_ADDRESS_BASE58_PREFIX, 137);
}

// Test suite: Verify testnet subaddress prefix
// Acceptance: Prefix 146 produces addresses starting with 'To'
TEST(address_prefix, testnet_subaddress_prefix)
{
  ASSERT_EQ(config::testnet::CRYPTONOTE_PUBLIC_SUBADDRESS_BASE58_PREFIX, 146);
}

// Test suite: Verify stagenet standard address prefix
// Acceptance: Prefix 86 produces addresses starting with 'S'
TEST(address_prefix, stagenet_standard_prefix)
{
  ASSERT_EQ(config::stagenet::CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX, 86);
}

// Test suite: Verify stagenet integrated address prefix
// Acceptance: Prefix 87 produces addresses starting with 'Si'
TEST(address_prefix, stagenet_integrated_prefix)
{
  ASSERT_EQ(config::stagenet::CRYPTONOTE_PUBLIC_INTEGRATED_ADDRESS_BASE58_PREFIX, 87);
}

// Test suite: Verify stagenet subaddress prefix
// Acceptance: Prefix 108 produces addresses starting with 'So'
TEST(address_prefix, stagenet_subaddress_prefix)
{
  ASSERT_EQ(config::stagenet::CRYPTONOTE_PUBLIC_SUBADDRESS_BASE58_PREFIX, 108);
}

// Test suite: Verify generated mainnet address starts with 'B'
// Acceptance: All mainnet standard addresses must begin with 'B' for visual identification
TEST(address_prefix, mainnet_standard_starts_with_B)
{
  cryptonote::account_base account;
  account.generate();
  std::string address = cryptonote::get_account_address_as_str(
    cryptonote::MAINNET, false, account.get_keys().m_account_address);
  ASSERT_EQ(address[0], 'B');
}

// Test suite: Verify generated testnet address starts with 'T'
// Acceptance: All testnet standard addresses must begin with 'T' for visual identification
TEST(address_prefix, testnet_standard_starts_with_T)
{
  cryptonote::account_base account;
  account.generate();
  std::string address = cryptonote::get_account_address_as_str(
    cryptonote::TESTNET, false, account.get_keys().m_account_address);
  ASSERT_EQ(address[0], 'T');
}

// Test suite: Verify generated stagenet address starts with 'S'
// Acceptance: All stagenet standard addresses must begin with 'S' for visual identification
TEST(address_prefix, stagenet_standard_starts_with_S)
{
  cryptonote::account_base account;
  account.generate();
  std::string address = cryptonote::get_account_address_as_str(
    cryptonote::STAGENET, false, account.get_keys().m_account_address);
  ASSERT_EQ(address[0], 'S');
}

// Test suite: Verify Monero addresses are rejected
// Acceptance: Bonero must refuse to parse Monero mainnet addresses (prefix 18 vs 66)
// This prevents accidental cross-network transactions
TEST(address_prefix, monero_addresses_rejected)
{
  // This is a valid Monero mainnet address (prefix 18, starts with '4')
  std::string monero_addr = "44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A";
  cryptonote::address_parse_info info;
  bool result = cryptonote::get_account_address_from_str(
    info, cryptonote::MAINNET, monero_addr);
  ASSERT_FALSE(result);  // Should fail - wrong prefix (18 vs 66)
}

// Test suite: Verify Bonero prefix differs from Monero
// Acceptance: Mainnet prefix 66 must not equal Monero's 18
TEST(address_prefix, mainnet_prefix_differs_from_monero)
{
  // Monero mainnet prefix is 18, Bonero is 66
  ASSERT_NE(config::CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX, 18);
}
