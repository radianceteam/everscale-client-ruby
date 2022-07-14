require 'spec_helper'
require 'base64'

describe EverSdk::Crypto do
  context "methods of crypto" do
    it "encryption" do
      key = "01" * 32
      nonce = "ff" * 12
      encrypted = test_client.request(
        "crypto.chacha20",
        EverSdk::Crypto::ParamsOfChaCha20.new(
          data: Base64.strict_encode64("Message"),
          key: key,
          nonce: nonce
        )
      )

      expect(encrypted.data).to eq("w5QOGsJodQ==")

      decrypted = test_client.request(
        "crypto.chacha20",
        EverSdk::Crypto::ParamsOfChaCha20.new(
          data: encrypted.data,
          key: key,
          nonce: nonce
        )
      )

      expect(decrypted.data).to eq("TWVzc2FnZQ==")
    end

    it "#factorize" do
      pr1 = EverSdk::Crypto::ParamsOfFactorize.new(composite: "17ED48941A08F981")
      expect { |b| EverSdk::Crypto.factorize(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Crypto.factorize(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.factors[0]).to eq "494C553B"
      expect(@res.result.factors[1]).to eq "53911073"
    end

    it "#modular_power" do
      pr1 = EverSdk::Crypto::ParamsOfModularPower.new(
        base: "0123456789ABCDEF",
        exponent: "0123",
        modulus: "01234567"
      )
      expect { |b| EverSdk::Crypto.modular_power(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Crypto.modular_power(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.modular_power).to eq "63bfdf"
    end

    it "#ton_crc16" do
      b64_str = EverSdk::Helper.base64_from_hex("0123456789abcdef")
      pr1 = EverSdk::Crypto::ParamsOfTonCrc16.new(data: b64_str)
      expect { |b| EverSdk::Crypto.ton_crc16(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Crypto.ton_crc16(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.crc).to eq 43349
    end

    it "#generate_random_bytes" do
      pr1 = EverSdk::Crypto::ParamsOfGenerateRandomBytes.new(length: 32)
      expect { |b| EverSdk::Crypto.generate_random_bytes(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Crypto.generate_random_bytes(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.bytes.length).to eq 44
    end

    it "#sha256, sha512" do
      pr1 = EverSdk::Crypto::ParamsOfHash.new(data: Base64::urlsafe_encode64("Message to hash with sha 256", padding: false))
      expect { |b| EverSdk::Crypto.sha256(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Crypto.sha256(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.hash).to eq "16fd057308dd358d5a9b3ba2de766b2dfd5e308478fc1f7ba5988db2493852f5"

      pr2 = EverSdk::Crypto::ParamsOfHash.new(data: Base64::urlsafe_encode64("Message to hash with sha 512"))
      expect { |b| EverSdk::Crypto.sha512(@c_ctx.context, pr2, &b) }.to yield_control
      EverSdk::Crypto.sha512(@c_ctx.context, pr2) { |a| @res2 = a }
      expect(@res2.success?).to eq true
      expect(@res2.result.hash).to eq "2616a44e0da827f0244e93c2b0b914223737a6129bc938b8edf2780ac9482960baa9b7c7cdb11457c1cebd5ae77e295ed94577f32d4c963dc35482991442daa5"
    end

    it "#convert_public_key_to_ton_safe_format" do
      pr1 = EverSdk::Crypto::ParamsOfConvertPublicKeyToTonSafeFormat.new(
        public_key: "06117f59ade83e097e0fb33e5d29e8735bda82b3bf78a015542aaa853bb69600"
      )
      expect { |b| EverSdk::Crypto.convert_public_key_to_ton_safe_format(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Crypto.convert_public_key_to_ton_safe_format(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.ton_public_key).to eq "PuYGEX9Zreg-CX4Psz5dKehzW9qCs794oBVUKqqFO7aWAOTD"
    end

    it "keys" do
      result = test_client.request(
        "crypto.convert_public_key_to_ton_safe_format",
        EverSdk::Crypto::ParamsOfConvertPublicKeyToTonSafeFormat.new(
          public_key: "06117f59ade83e097e0fb33e5d29e8735bda82b3bf78a015542aaa853bb69600"
        )
      )

      expect("PuYGEX9Zreg-CX4Psz5dKehzW9qCs794oBVUKqqFO7aWAOTD").to eq(result.ton_public_key)

      result = test_client.request_no_params(
        "crypto.generate_random_sign_keys",
        is_single_thread_only: true # workaround
      )

      expect(result.public_.length).to eq(64)
      expect(result.secret.length).to eq(64)
      expect(result.secret).not_to eq(result.public_)

      result = test_client.request(
        "crypto.sign",
        EverSdk::Crypto::ParamsOfSign.new(
          unsigned: Base64.strict_encode64("Test Message"),
          keys: EverSdk::Crypto::KeyPair.new(
            public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e",
            secret: "56b6a77093d6fdf14e593f36275d872d75de5b341942376b2a08759f3cbae78f"
          )
        )
      )

      expect(result.signed).to eq("+wz+QO6l1slgZS5s65BNqKcu4vz24FCJz4NSAxef9lu0jFfs8x3PzSZRC+pn5k8+aJi3xYMA3BQzglQmjK3hA1Rlc3QgTWVzc2FnZQ==")
      expect(result.signature).to eq("fb0cfe40eea5d6c960652e6ceb904da8a72ee2fcf6e05089cf835203179ff65bb48c57ecf31dcfcd26510bea67e64f3e6898b7c58300dc14338254268cade103")

      result = test_client.request(
        "crypto.verify_signature",
        EverSdk::Crypto::ParamsOfVerifySignature.new(
          signed: Base64.strict_encode64("fb0cfe40eea5d6c960652e6ceb904da8a72ee2fcf6e05089cf835203179ff65bb48c57ecf31dcfcd26510bea67e64f3e6898b7c58300dc14338254268cade10354657374204d657373616765".scan(/../).map { |x| x.hex.chr }.join),
          public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e"
        )
      )

      expect(Base64.strict_decode64(result.unsigned)).to eq("Test Message")
    end

    it "#sign" do
      pr1 = EverSdk::Crypto::ParamsOfSign.new(
        unsigned: Base64.urlsafe_encode64("Test Message", padding: false),
        keys: EverSdk::Crypto::KeyPair.new(
          public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e",
          secret: "56b6a77093d6fdf14e593f36275d872d75de5b341942376b2a08759f3cbae78f"
        )
      )

      expect { |b| EverSdk::Crypto.sign(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Crypto.sign(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true

      expect(@res1.result.signed).to eq "+wz+QO6l1slgZS5s65BNqKcu4vz24FCJz4NSAxef9lu0jFfs8x3PzSZRC+pn5k8+aJi3xYMA3BQzglQmjK3hA1Rlc3QgTWVzc2FnZQ=="
      expect(@res1.result.signature).to eq "fb0cfe40eea5d6c960652e6ceb904da8a72ee2fcf6e05089cf835203179ff65bb48c57ecf31dcfcd26510bea67e64f3e6898b7c58300dc14338254268cade103"
    end

    it "#verify_signature" do
      pr1 = EverSdk::Crypto::ParamsOfVerifySignature.new(
        signed: EverSdk::Helper.base64_from_hex("fb0cfe40eea5d6c960652e6ceb904da8a72ee2fcf6e05089cf835203179ff65bb48c57ecf31dcfcd26510bea67e64f3e6898b7c58300dc14338254268cade10354657374204d657373616765"),
        public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e"
      )

      expect { |b| EverSdk::Crypto.verify_signature(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Crypto.verify_signature(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true

      a2 = Base64.decode64(@res1.result.unsigned)
      expect(a2).to eq "Test Message"
    end

    it "#scrypt" do
      pr1 = EverSdk::Crypto::ParamsOfScrypt.new(
        password: Base64.urlsafe_encode64("Test Password", padding: false),
        salt: Base64.urlsafe_encode64("Test Salt", padding: false),
        log_n: 10,
        r: 8,
        p: 16,
        dk_len: 64
      )

      expect { |b| EverSdk::Crypto.scrypt(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Crypto.scrypt(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.key).to eq "52e7fcf91356eca55fc5d52f16f5d777e3521f54e3c570c9bbb7df58fc15add73994e5db42be368de7ebed93c9d4f21f9be7cc453358d734b04a057d0ed3626d"
    end

    it "hdkey methods" do
      #1
      pr1 = EverSdk::Crypto::ParamsOfHDKeyXPrvFromMnemonic.new(
        phrase: "abuse boss fly battle rubber wasp afraid hamster guide essence vibrant tattoo"
      )

      expect { |b| EverSdk::Crypto.hdkey_xprv_from_mnemonic(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Crypto.hdkey_xprv_from_mnemonic(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.xprv).to eq "xprv9s21ZrQH143K25JhKqEwvJW7QAiVvkmi4WRenBZanA6kxHKtKAQQKwZG65kCyW5jWJ8NY9e3GkRoistUjjcpHNsGBUv94istDPXvqGNuWpC"


      #2
      pr2 = EverSdk::Crypto::ParamsOfHDKeySecretFromXPrv.new(xprv: @res1.result.xprv)
      expect { |b| EverSdk::Crypto.hdkey_secret_from_xprv(@c_ctx.context, pr2, &b) }.to yield_control
      EverSdk::Crypto.hdkey_secret_from_xprv(@c_ctx.context, pr2) { |a| @res2 = a }
      expect(@res2.success?).to eq true
      expect(@res2.result.secret).to eq "0c91e53128fa4d67589d63a6c44049c1068ec28a63069a55ca3de30c57f8b365"

      #3
      pr3 = EverSdk::Crypto::ParamsOfHDKeyPublicFromXPrv.new(xprv: @res1.result.xprv)
      expect { |b| EverSdk::Crypto.hdkey_public_from_xprv(@c_ctx.context, pr3, &b) }.to yield_control
      EverSdk::Crypto.hdkey_public_from_xprv(@c_ctx.context, pr3) { |a| @res3 = a }
      expect(@res3.success?).to eq true
      expect(@res3.result.public_).to eq "7b70008d0c40992283d488b1046739cf827afeabf647a5f07c4ad1e7e45a6f89"

      #4
      pr4 = EverSdk::Crypto::ParamsOfHDKeyDeriveFromXPrv.new(
        xprv: @res1.result.xprv,
        child_index: 0,
        hardened: false
      )
      expect { |b| EverSdk::Crypto.hdkey_derive_from_xprv(@c_ctx.context, pr4, &b) }.to yield_control
      EverSdk::Crypto.hdkey_derive_from_xprv(@c_ctx.context, pr4) { |a| @res4 = a }
      expect(@res4.success?).to eq true
      expect(@res4.result.xprv).to eq "xprv9uZwtSeoKf1swgAkVVCEUmC2at6t7MCJoHnBbn1MWJZyxQ4cySkVXPyNh7zjf9VjsP4vEHDDD2a6R35cHubg4WpzXRzniYiy8aJh1gNnBKv"

      #5
      pr5 = EverSdk::Crypto::ParamsOfHDKeyDeriveFromXPrvPath.new(
        xprv: @res1.result.xprv,
        path: "m/44'/60'/0'/0'"
      )
      expect { |b| EverSdk::Crypto.hdkey_derive_from_xprv_path(@c_ctx.context, pr5, &b) }.to yield_control
      EverSdk::Crypto.hdkey_derive_from_xprv_path(@c_ctx.context, pr5) { |a| @res4 = a }
      expect(@res4.success?).to eq true
      expect(@res4.result.xprv).to eq "xprvA1KNMo63UcGjmDF1bX39Cw2BXGUwrwMjeD5qvQ3tA3qS3mZQkGtpf4DHq8FDLKAvAjXsYGLHDP2dVzLu9ycta8PXLuSYib2T3vzLf3brVgZ"
    end

    it "mnemonics methods" do
      # 1
      pr1 = EverSdk::Crypto::ParamsOfMnemonicWords.new()
      expect { |b| EverSdk::Crypto.mnemonic_words(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Crypto.mnemonic_words(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.words.split(" ").count).to eq 2048

      (1...9).each do |dictionary|
        [12, 15, 18, 21, 24].each do |word_count|
          result = test_client.request(
            "crypto.mnemonic_from_random",
            EverSdk::Crypto::ParamsOfMnemonicFromRandom.new(
              dictionary: dictionary,
              word_count: word_count
            )
          )

          expect(result.phrase.split(" ").size).to eq(word_count)
        end
      end

      # 2
      pr2 = EverSdk::Crypto::ParamsOfMnemonicFromEntropy.new(
        entropy: "00112233445566778899AABBCCDDEEFF",
        dictionary: 1,
        word_count: 12,
      )
      expect { |b| EverSdk::Crypto.mnemonic_from_entropy(@c_ctx.context, pr2, &b) }.to yield_control
      EverSdk::Crypto.mnemonic_from_entropy(@c_ctx.context, pr2) { |a| @res2 = a }
      expect(@res2.success?).to eq true
      expect(@res2.result.phrase).to eq "abandon math mimic master filter design carbon crystal rookie group knife young"

      (1...9).each do |dictionary|
        [12, 15, 18, 21, 24].each do |word_count|
          result = test_client.request(
            "crypto.mnemonic_from_random",
            EverSdk::Crypto::ParamsOfMnemonicFromRandom.new(
              dictionary: dictionary,
              word_count: word_count
            )
          )
          verify_result = test_client.request(
            "crypto.mnemonic_verify",
            EverSdk::Crypto::ParamsOfMnemonicVerify.new(
              phrase: result.phrase,
              dictionary: dictionary,
              word_count: word_count
            )
          )

          expect(verify_result.valid).to eq(true)
        end
      end

      # 3
      pr3 = EverSdk::Crypto::ParamsOfMnemonicVerify.new(
        phrase: "one two"
      )
      expect { |b| EverSdk::Crypto.mnemonic_verify(@c_ctx.context, pr3, &b) }.to yield_control
      EverSdk::Crypto.mnemonic_verify(@c_ctx.context, pr3) { |a| @res3 = a }
      expect(@res3.success?).to eq true
      expect(@res3.result.valid).to eq false

      result = test_client.request(
        "crypto.mnemonic_derive_sign_keys",
        EverSdk::Crypto::ParamsOfMnemonicDeriveSignKeys.new(
          phrase: "unit follow zone decline glare flower crisp vocal adapt magic much mesh cherry teach mechanic rain float vicious solution assume hedgehog rail sort chuckle",
          path: nil,
          dictionary: 0,
          word_count: 24
        )
      )
      result = test_client.request(
        "crypto.convert_public_key_to_ton_safe_format",
        EverSdk::Crypto::ParamsOfConvertPublicKeyToTonSafeFormat.new(
          public_key: result.public_
        )
      )

      expect(result.ton_public_key).to eq("PuYTvCuf__YXhp-4jv3TXTHL0iK65ImwxG0RGrYc1sP3H4KS")

      result = test_client.request(
        "crypto.mnemonic_derive_sign_keys",
        EverSdk::Crypto::ParamsOfMnemonicDeriveSignKeys.new(
          phrase: "unit follow zone decline glare flower crisp vocal adapt magic much mesh cherry teach mechanic rain float vicious solution assume hedgehog rail sort chuckle",
          path: "m",
          dictionary: 0,
          word_count: 24
        )
      )
      result = test_client.request(
        "crypto.convert_public_key_to_ton_safe_format",
        EverSdk::Crypto::ParamsOfConvertPublicKeyToTonSafeFormat.new(
          public_key: result.public_
        )
      )

      expect(result.ton_public_key).to eq("PubDdJkMyss2qHywFuVP1vzww0TpsLxnRNnbifTCcu-XEgW0")

      result = test_client.request(
        "crypto.mnemonic_derive_sign_keys",
        EverSdk::Crypto::ParamsOfMnemonicDeriveSignKeys.new(
          phrase: "abandon math mimic master filter design carbon crystal rookie group knife young",
          path: nil,
          dictionary: nil,
          word_count: nil
        )
      )
      result = test_client.request(
        "crypto.convert_public_key_to_ton_safe_format",
        EverSdk::Crypto::ParamsOfConvertPublicKeyToTonSafeFormat.new(
          public_key: result.public_
        )
      )

      expect(result.ton_public_key).to eq("PuZhw8W5ejPJwKA68RL7sn4_RNmeH4BIU_mEK7em5d4_-cIx")

      result = test_client.request(
        "crypto.mnemonic_from_random",
        EverSdk::Crypto::ParamsOfMnemonicFromRandom.new(
          dictionary: nil,
          word_count: nil
        )
      )

      expect(result.phrase.split(" ").size).to eq(12)

      result = test_client.request(
        "crypto.mnemonic_from_random",
        EverSdk::Crypto::ParamsOfMnemonicFromRandom.new(
          dictionary: 0,
          word_count: 12
        )
      )

      expect(result.phrase.split(" ").size).to eq(12)

      result = test_client.request(
        "crypto.mnemonic_from_random",
        EverSdk::Crypto::ParamsOfMnemonicFromRandom.new(
          dictionary: 1,
          word_count: 12
        )
      )

      expect(result.phrase.split(" ").size).to eq(12)

      result = test_client.request(
        "crypto.mnemonic_from_entropy",
        EverSdk::Crypto::ParamsOfMnemonicFromEntropy.new(
          entropy: "2199ebe996f14d9e4e2595113ad1e627",
          dictionary: nil,
          word_count: nil
        )
      )
      result = test_client.request(
        "crypto.mnemonic_derive_sign_keys",
        EverSdk::Crypto::ParamsOfMnemonicDeriveSignKeys.new(
          phrase: result.phrase,
          path: nil,
          dictionary: nil,
          word_count: nil
        )
      )
      result = test_client.request(
        "crypto.convert_public_key_to_ton_safe_format",
        EverSdk::Crypto::ParamsOfConvertPublicKeyToTonSafeFormat.new(
          public_key: result.public_
        )
      )

      expect(result.ton_public_key).to eq("PuZdw_KyXIzo8IksTrERN3_WoAoYTyK7OvM-yaLk711sUIB3")
    end

    it "#signing_box" do
      # 1
      kp = EverSdk::Crypto::KeyPair.new(
        public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e",
        secret: "56b6a77093d6fdf14e593f36275d872d75de5b341942376b2a08759f3cbae78f"
      )

      EverSdk::Crypto.get_signing_box(@c_ctx.context, kp) { |a| @res1 = a }
      sleep(0.1) until @res1
      expect(@res1.success?).to eq true
      sb_handle = @res1.result.handle
      expect(sb_handle).to_not eq nil


      # 2
      reg_sb = EverSdk::Crypto::RegisteredSigningBox.new(handle: sb_handle)
      EverSdk::Crypto.signing_box_get_public_key(@c_ctx.context, reg_sb) { |a| @res2 = a }

      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res2 || (get_now_for_async_operation() >= timeout_at)

      expect(@res2.success?).to eq true
      expect(@res2.result.pubkey).to_not eq nil


      # 3
      unsigned_data =  Base64.urlsafe_encode64("11122Test Message34324652", padding: false)
      a3 = EverSdk::Crypto::ParamsOfSigningBoxSign.new(
        signing_box: sb_handle,
        unsigned: unsigned_data
      )
      EverSdk::Crypto.signing_box_sign(@c_ctx.context, a3) { |a| @res3 = a }

      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res3 || (get_now_for_async_operation() >= timeout_at)

      expect(@res3.success?).to eq true
      expect(@res3.result.signature).to_not eq nil


      # 4
      EverSdk::Crypto.register_signing_box(@c_ctx.context, callback: nil) { |a| @res4 = a }
      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res4 || (get_now_for_async_operation() >= timeout_at)

      expect(@res4.success?).to eq true
      expect(@res4.result.handle).to_not eq nil
    end

    it "#nacl" do
      # 1
      pr1 = EverSdk::Crypto::ParamsOfNaclSignKeyPairFromSecret.new(secret: "8fb4f2d256e57138fb310b0a6dac5bbc4bee09eb4821223a720e5b8e1f3dd674")
      EverSdk::Crypto::nacl_sign_keypair_from_secret_key(@c_ctx.context, pr1) { |a| @res = a }
      expect(@res.success?).to eq true
      expect(@res.result.public_).to eq "aa5533618573860a7e1bf19f34bd292871710ed5b2eafa0dcdbb33405f2231c6"


      # 2
      pr2 = EverSdk::Crypto::ParamsOfNaclSign.new(
        unsigned: Base64::strict_encode64("Test Message"),
        secret: "56b6a77093d6fdf14e593f36275d872d75de5b341942376b2a08759f3cbae78f1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e"
      )
      EverSdk::Crypto::nacl_sign(@c_ctx.context, pr2) { |a| @res2 = a }
      expect(@res2.success?).to eq true
      expect(@res2.result.signed).to eq "+wz+QO6l1slgZS5s65BNqKcu4vz24FCJz4NSAxef9lu0jFfs8x3PzSZRC+pn5k8+aJi3xYMA3BQzglQmjK3hA1Rlc3QgTWVzc2FnZQ=="

      # 3
      pr3 = EverSdk::Crypto::ParamsOfNaclSignOpen.new(
        signed: EverSdk::Helper.base64_from_hex("fb0cfe40eea5d6c960652e6ceb904da8a72ee2fcf6e05089cf835203179ff65bb48c57ecf31dcfcd26510bea67e64f3e6898b7c58300dc14338254268cade10354657374204d657373616765"),
        public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e"
      )
      EverSdk::Crypto::nacl_sign_open(@c_ctx.context, pr3) { |a| @res3 = a }
      expect(@res3.success?).to eq true
      expect("Test Message").to eq Base64.decode64(@res3.result.unsigned)

      result = test_client.request(
        "crypto.nacl_sign_detached",
        EverSdk::Crypto::ParamsOfNaclSign.new(
          unsigned: Base64.strict_encode64("Test Message"),
          secret: "56b6a77093d6fdf14e593f36275d872d75de5b341942376b2a08759f3cbae78f1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e"
        )
      )

      expect(result.signature).to eq("fb0cfe40eea5d6c960652e6ceb904da8a72ee2fcf6e05089cf835203179ff65bb48c57ecf31dcfcd26510bea67e64f3e6898b7c58300dc14338254268cade103")

      signature = result.signature
      result = test_client.request(
        "crypto.nacl_sign_detached_verify",
        EverSdk::Crypto::ParamsOfNaclSignDetachedVerify.new(
          unsigned: Base64.strict_encode64("Test Message"),
          signature: signature,
          public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e"
        )
      )

      expect(result.succeeded).to eq(true)

      result = test_client.request(
        "crypto.nacl_sign_detached_verify",
        EverSdk::Crypto::ParamsOfNaclSignDetachedVerify.new(
          unsigned: Base64.strict_encode64("Test Message 1"),
          signature: signature,
          public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e"
        )
      )

      expect(result.succeeded).to eq(false)

      # Box

      result = test_client.request_no_params("crypto.nacl_box_keypair")

      expect(result.public_.length).to eq(64)
      expect(result.secret.length).to eq(64)
      expect(result.public_).not_to eq(result.secret)

      result = test_client.request(
        "crypto.nacl_box_keypair_from_secret_key",
        EverSdk::Crypto::ParamsOfNaclBoxKeyPairFromSecret.new(
          secret: "e207b5966fb2c5be1b71ed94ea813202706ab84253bdf4dc55232f82a1caf0d4"
        )
      )

      expect(result.public_).to eq("a53b003d3ffc1e159355cb37332d67fc235a7feb6381e36c803274074dc3933a")

      result = test_client.request(
        "crypto.nacl_box",
        EverSdk::Crypto::ParamsOfNaclBox.new(
          decrypted: Base64.strict_encode64("Test Message"),
          nonce: "cd7f99924bf422544046e83595dd5803f17536f5c9a11746",
          their_public: "c4e2d9fe6a6baf8d1812b799856ef2a306291be7a7024837ad33a8530db79c6b",
          secret: "d9b9dc5033fb416134e5d2107fdbacab5aadb297cb82dbdcd137d663bac59f7f"
        )
      )

      expect(result.encrypted).to eq("li4XED4kx/pjQ2qdP0eR2d/K30uN94voNADxwA==")

      result = test_client.request(
        "crypto.nacl_box_open",
        EverSdk::Crypto::ParamsOfNaclBoxOpen.new(
          encrypted: EverSdk::Helper.base64_from_hex("962e17103e24c7fa63436a9d3f4791d9dfcadf4b8df78be83400f1c0"),
          nonce: "cd7f99924bf422544046e83595dd5803f17536f5c9a11746",
          their_public: "c4e2d9fe6a6baf8d1812b799856ef2a306291be7a7024837ad33a8530db79c6b",
          secret: "d9b9dc5033fb416134e5d2107fdbacab5aadb297cb82dbdcd137d663bac59f7f"
        )
      )

      expect(Base64.strict_decode64(result.decrypted)).to eq("Test Message")

      # Secret box

      result = test_client.request(
        "crypto.nacl_secret_box",
        EverSdk::Crypto::ParamsOfNaclSecretBox.new(
          decrypted: Base64.strict_encode64("Test Message"),
          nonce: "2a33564717595ebe53d91a785b9e068aba625c8453a76e45",
          key: "8f68445b4e78c000fe4d6b7fc826879c1e63e3118379219a754ae66327764bd8"
        )
      )

      expect(result.encrypted).to eq("JL7ejKWe2KXmrsns41yfXoQF0t/C1Q8RGyzQ2A==")

      result = test_client.request(
        "crypto.nacl_secret_box_open",
        EverSdk::Crypto::ParamsOfNaclSecretBoxOpen.new(
          encrypted: EverSdk::Helper.base64_from_hex("24bede8ca59ed8a5e6aec9ece35c9f5e8405d2dfc2d50f111b2cd0d8"),
          nonce: "2a33564717595ebe53d91a785b9e068aba625c8453a76e45",
          key: "8f68445b4e78c000fe4d6b7fc826879c1e63e3118379219a754ae66327764bd8"
        )
      )

      expect(Base64.strict_decode64(result.decrypted)).to eq("Test Message")

      e = test_client.request(
        "crypto.nacl_secret_box",
        EverSdk::Crypto::ParamsOfNaclSecretBox.new(
          decrypted: Base64.strict_encode64("Text with ' and \" and : {}"),
          nonce: "2a33564717595ebe53d91a785b9e068aba625c8453a76e45",
          key: "8f68445b4e78c000fe4d6b7fc826879c1e63e3118379219a754ae66327764bd8"
        )
      )
      d = test_client.request(
        "crypto.nacl_secret_box_open",
        EverSdk::Crypto::ParamsOfNaclSecretBoxOpen.new(
          encrypted: e.encrypted,
          nonce: "2a33564717595ebe53d91a785b9e068aba625c8453a76e45",
          key: "8f68445b4e78c000fe4d6b7fc826879c1e63e3118379219a754ae66327764bd8"
        )
      )

      expect(Base64.strict_decode64(d.decrypted)).to eq("Text with ' and \" and : {}")
    end
  end
end
