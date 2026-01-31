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

// Bonero branding tests
// Acceptance criteria: Verify Bonero branding elements are correctly configured
// to distinguish from Monero and provide consistent user experience.

#include "gtest/gtest.h"
#include "cryptonote_config.h"
#include <cstring>

// Test suite: Verify data directory name
// Acceptance: Data directory must be "bonero" (not Monero's "bitmonero")
// This prevents conflicts with existing Monero installations
TEST(branding, data_directory_name)
{
  ASSERT_STREQ(CRYPTONOTE_NAME, "bonero");
}

// Test suite: Verify data directory is not Monero's
// Acceptance: Must differ from "bitmonero" to avoid data conflicts
TEST(branding, data_directory_not_monero)
{
  ASSERT_STRNE(CRYPTONOTE_NAME, "bitmonero");
}

// Test suite: Verify message signing domain separator
// Acceptance: Must be "BoneroMessageSignature" (not "MoneroMessageSignature")
// This is critical for security - prevents cross-chain signature replay attacks
TEST(branding, message_signing_domain)
{
  ASSERT_STREQ(config::HASH_KEY_MESSAGE_SIGNING, "BoneroMessageSignature");
}

// Test suite: Verify message signing domain differs from Monero
// Acceptance: Must not be Monero's domain to prevent signature replay attacks
TEST(branding, message_signing_domain_not_monero)
{
  ASSERT_STRNE(config::HASH_KEY_MESSAGE_SIGNING, "MoneroMessageSignature");
}
