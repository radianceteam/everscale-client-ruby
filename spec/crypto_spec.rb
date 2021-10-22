require 'spec_helper'
require 'base64'

describe TonSdk::Crypto do
  context "methods of crypto" do
    it "#factorize" do
      pr1 = TonSdk::Crypto::ParamsOfFactorize.new("17ED48941A08F981")
      expect { |b| TonSdk::Crypto.factorize(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.factorize(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.factors[0]).to eq "494C553B"
      expect(@res.result.factors[1]).to eq "53911073"
    end

    it "#modular_power" do
      pr1 = TonSdk::Crypto::ParamsOfModularPower.new(
        base: "0123456789ABCDEF",
        exponent: "0123",
        modulus: "01234567"
      )
      expect { |b| TonSdk::Crypto.modular_power(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.modular_power(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.modular_power).to eq "63bfdf"
    end

    it "#ton_crc16" do
      b64_str = TonSdk::Helper.base64_from_hex("0123456789abcdef")
      pr1 = TonSdk::Crypto::ParamsOfTonCrc16.new(b64_str)
      expect { |b| TonSdk::Crypto.ton_crc16(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.ton_crc16(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.crc).to eq 43349
    end

    it "#generate_random_bytes" do
      pr1 = TonSdk::Crypto::ParamsOfGenerateRandomBytes.new(32)
      expect { |b| TonSdk::Crypto.generate_random_bytes(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.generate_random_bytes(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.bytes.length).to eq 44
    end

    it "#sha256, sha512" do
      pr1 = TonSdk::Crypto::ParamsOfHash.new(Base64::urlsafe_encode64("Message to hash with sha 256", padding: false))
      expect { |b| TonSdk::Crypto.sha256(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.sha256(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.hash).to eq "16fd057308dd358d5a9b3ba2de766b2dfd5e308478fc1f7ba5988db2493852f5"

      pr2 = TonSdk::Crypto::ParamsOfHash.new(Base64::urlsafe_encode64("Message to hash with sha 512"))
      expect { |b| TonSdk::Crypto.sha512(@c_ctx.context, pr2, &b) }.to yield_control
      TonSdk::Crypto.sha512(@c_ctx.context, pr2) { |a| @res2 = a }
      expect(@res2.success?).to eq true
      expect(@res2.result.hash).to eq "2616a44e0da827f0244e93c2b0b914223737a6129bc938b8edf2780ac9482960baa9b7c7cdb11457c1cebd5ae77e295ed94577f32d4c963dc35482991442daa5"
    end

    it "#convert_public_key_to_ton_safe_format" do
      pr1 = TonSdk::Crypto::ParamsOfConvertPublicKeyToTonSafeFormat.new(
        "06117f59ade83e097e0fb33e5d29e8735bda82b3bf78a015542aaa853bb69600"
      )
      expect { |b| TonSdk::Crypto.convert_public_key_to_ton_safe_format(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.convert_public_key_to_ton_safe_format(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.ton_public_key).to eq "PuYGEX9Zreg-CX4Psz5dKehzW9qCs794oBVUKqqFO7aWAOTD"
    end

    it "#generate_random_sign_keys" do
      expect { |b| TonSdk::Crypto.generate_random_sign_keys(@c_ctx.context, &b) }.to yield_control
      TonSdk::Crypto.generate_random_sign_keys(@c_ctx.context) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.public_.length).to eq 64
      expect(@res1.result.secret.length).to eq 64
      expect(@res1.result.public_).to_not eq @res1.result.secret
    end

    it "#sign" do
      pr1 = TonSdk::Crypto::ParamsOfSign.new(
        unsigned: Base64.urlsafe_encode64("Test Message", padding: false),
        keys: TonSdk::Crypto::KeyPair.new(
          public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e",
          secret: "56b6a77093d6fdf14e593f36275d872d75de5b341942376b2a08759f3cbae78f"
        )
      )

      expect { |b| TonSdk::Crypto.sign(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.sign(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true

      expect(@res1.result.signed).to eq "+wz+QO6l1slgZS5s65BNqKcu4vz24FCJz4NSAxef9lu0jFfs8x3PzSZRC+pn5k8+aJi3xYMA3BQzglQmjK3hA1Rlc3QgTWVzc2FnZQ=="
      expect(@res1.result.signature).to eq "fb0cfe40eea5d6c960652e6ceb904da8a72ee2fcf6e05089cf835203179ff65bb48c57ecf31dcfcd26510bea67e64f3e6898b7c58300dc14338254268cade103"
    end

    it "#verify_signature" do
      pr1 = TonSdk::Crypto::ParamsOfVerifySignature.new(
        signed: TonSdk::Helper.base64_from_hex("fb0cfe40eea5d6c960652e6ceb904da8a72ee2fcf6e05089cf835203179ff65bb48c57ecf31dcfcd26510bea67e64f3e6898b7c58300dc14338254268cade10354657374204d657373616765"),
        public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e"
      )

      expect { |b| TonSdk::Crypto.verify_signature(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.verify_signature(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true

      a2 = Base64.decode64(@res1.result.unsigned)
      expect(a2).to eq "Test Message"
    end

    it "#scrypt" do
      pr1 = TonSdk::Crypto::ParamsOfScrypt.new(
        password: Base64.urlsafe_encode64("Test Password", padding: false),
        salt: Base64.urlsafe_encode64("Test Salt", padding: false),
        log_n: 10,
        r: 8,
        p: 16,
        dk_len: 64
      )

      expect { |b| TonSdk::Crypto.scrypt(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.scrypt(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.key).to eq "52e7fcf91356eca55fc5d52f16f5d777e3521f54e3c570c9bbb7df58fc15add73994e5db42be368de7ebed93c9d4f21f9be7cc453358d734b04a057d0ed3626d"
    end

    it "hdkey methods" do
      #1
      pr1 = TonSdk::Crypto::ParamsOfHDKeyXPrvFromMnemonic.new(
        phrase: "abuse boss fly battle rubber wasp afraid hamster guide essence vibrant tattoo"
      )

      expect { |b| TonSdk::Crypto.hdkey_xprv_from_mnemonic(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.hdkey_xprv_from_mnemonic(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.xprv).to eq "xprv9s21ZrQH143K25JhKqEwvJW7QAiVvkmi4WRenBZanA6kxHKtKAQQKwZG65kCyW5jWJ8NY9e3GkRoistUjjcpHNsGBUv94istDPXvqGNuWpC"


      #2
      pr2 = TonSdk::Crypto::ParamsOfHDKeySecretFromXPrv.new(@res1.result.xprv)
      expect { |b| TonSdk::Crypto.hdkey_secret_from_xprv(@c_ctx.context, pr2, &b) }.to yield_control
      TonSdk::Crypto.hdkey_secret_from_xprv(@c_ctx.context, pr2) { |a| @res2 = a }
      expect(@res2.success?).to eq true
      expect(@res2.result.secret).to eq "0c91e53128fa4d67589d63a6c44049c1068ec28a63069a55ca3de30c57f8b365"

      #3
      pr3 = TonSdk::Crypto::ParamsOfHDKeyPublicFromXPrv.new(@res1.result.xprv)
      expect { |b| TonSdk::Crypto.hdkey_public_from_xprv(@c_ctx.context, pr3, &b) }.to yield_control
      TonSdk::Crypto.hdkey_public_from_xprv(@c_ctx.context, pr3) { |a| @res3 = a }
      expect(@res3.success?).to eq true
      expect(@res3.result.public_).to eq "02a8eb63085f73c33fa31b4d1134259406347284f8dab6fc68f4bf8c96f6c39b75"

      #4
      pr4 = TonSdk::Crypto::ParamsOfHDKeyDeriveFromXPrv.new(
        xprv: @res1.result.xprv,
        child_index: 0,
        hardened: false
      )
      expect { |b| TonSdk::Crypto.hdkey_derive_from_xprv(@c_ctx.context, pr4, &b) }.to yield_control
      TonSdk::Crypto.hdkey_derive_from_xprv(@c_ctx.context, pr4) { |a| @res4 = a }
      expect(@res4.success?).to eq true
      expect(@res4.result.xprv).to eq "xprv9uZwtSeoKf1swgAkVVCEUmC2at6t7MCJoHnBbn1MWJZyxQ4cySkVXPyNh7zjf9VjsP4vEHDDD2a6R35cHubg4WpzXRzniYiy8aJh1gNnBKv"

      #5
      pr5 = TonSdk::Crypto::ParamsOfHDKeyDeriveFromXPrvPath.new(
        xprv: @res1.result.xprv,
        path: "m/44'/60'/0'/0'"
      )
      expect { |b| TonSdk::Crypto.hdkey_derive_from_xprv_path(@c_ctx.context, pr5, &b) }.to yield_control
      TonSdk::Crypto.hdkey_derive_from_xprv_path(@c_ctx.context, pr5) { |a| @res4 = a }
      expect(@res4.success?).to eq true
      expect(@res4.result.xprv).to eq "xprvA1KNMo63UcGjmDF1bX39Cw2BXGUwrwMjeD5qvQ3tA3qS3mZQkGtpf4DHq8FDLKAvAjXsYGLHDP2dVzLu9ycta8PXLuSYib2T3vzLf3brVgZ"
    end

    it "mnemonics methods" do
      # 1
      pr1 = TonSdk::Crypto::ParamsOfMnemonicWords.new()
      expect { |b| TonSdk::Crypto.mnemonic_words(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.mnemonic_words(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.words.split(" ").count).to eq 2048

      # 2
      pr2 = TonSdk::Crypto::ParamsOfMnemonicFromEntropy.new(
        entropy: "00112233445566778899AABBCCDDEEFF",
        dictionary: 1,
        word_count: 12,
      )
      expect { |b| TonSdk::Crypto.mnemonic_from_entropy(@c_ctx.context, pr2, &b) }.to yield_control
      TonSdk::Crypto.mnemonic_from_entropy(@c_ctx.context, pr2) { |a| @res2 = a }
      expect(@res2.success?).to eq true
      expect(@res2.result.phrase).to eq "abandon math mimic master filter design carbon crystal rookie group knife young"

      # 3
      pr3 = TonSdk::Crypto::ParamsOfMnemonicVerify.new(
        phrase: "one two"
      )
      expect { |b| TonSdk::Crypto.mnemonic_verify(@c_ctx.context, pr3, &b) }.to yield_control
      TonSdk::Crypto.mnemonic_verify(@c_ctx.context, pr3) { |a| @res3 = a }
      expect(@res3.success?).to eq true
      expect(@res3.result.valid).to eq false
    end

    it "#chacha20" do
      pr1 = TonSdk::Crypto::ParamsOfChaCha20.new(
        data: Base64.strict_encode64("Message"),
        key: "01" * 32,
        nonce: "ff" * 12,
      )
      expect { |b| TonSdk::Crypto.chacha20(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Crypto.chacha20(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.data).to eq "w5QOGsJodQ=="
    end

    it "#signing_box" do
      # 1
      kp = TonSdk::Crypto::KeyPair.new(
        public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e",
        secret: "56b6a77093d6fdf14e593f36275d872d75de5b341942376b2a08759f3cbae78f"
      )

      TonSdk::Crypto.get_signing_box(@c_ctx.context, kp) { |a| @res1 = a }
      sleep(0.1) until @res1
      expect(@res1.success?).to eq true
      sb_handle = @res1.result.handle
      expect(sb_handle).to_not eq nil


      # 2
      reg_sb = TonSdk::Crypto::RegisteredSigningBox.new(sb_handle)
      TonSdk::Crypto.signing_box_get_public_key(@c_ctx.context, reg_sb) { |a| @res2 = a }

      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res2 || (get_now_for_async_operation() >= timeout_at)

      expect(@res2.success?).to eq true
      expect(@res2.result.pubkey).to_not eq nil


      # 3
      unsigned_data =  Base64.urlsafe_encode64("11122Test Message34324652", padding: false)
      a3 = TonSdk::Crypto::ParamsOfSigningBoxSign.new(
        signing_box: sb_handle,
        unsigned: unsigned_data
      )
      TonSdk::Crypto.signing_box_sign(@c_ctx.context, a3) { |a| @res3 = a }

      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res3 || (get_now_for_async_operation() >= timeout_at)

      expect(@res3.success?).to eq true
      expect(@res3.result.signature).to_not eq nil


      # 4
      TonSdk::Crypto.register_signing_box(@c_ctx.context, nil) { |a| @res4 = a }
      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res4 || (get_now_for_async_operation() >= timeout_at)

      expect(@res4.success?).to eq true
      expect(@res4.result.handle).to_not eq nil
    end

    it "#nacl" do
      # 1
      pr1 = TonSdk::Crypto::ParamsOfNaclSignKeyPairFromSecret.new("8fb4f2d256e57138fb310b0a6dac5bbc4bee09eb4821223a720e5b8e1f3dd674")
      TonSdk::Crypto::nacl_sign_keypair_from_secret_key(@c_ctx.context, pr1) { |a| @res = a }
      expect(@res.success?).to eq true
      expect(@res.result.public_).to eq "aa5533618573860a7e1bf19f34bd292871710ed5b2eafa0dcdbb33405f2231c6"


      # 2
      pr2 = TonSdk::Crypto::ParamsOfNaclSign.new(
        unsigned: Base64::strict_encode64("Test Message"),
        secret: "56b6a77093d6fdf14e593f36275d872d75de5b341942376b2a08759f3cbae78f1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e"
      )
      TonSdk::Crypto::nacl_sign(@c_ctx.context, pr2) { |a| @res2 = a }
      expect(@res2.success?).to eq true
      expect(@res2.result.signed).to eq "+wz+QO6l1slgZS5s65BNqKcu4vz24FCJz4NSAxef9lu0jFfs8x3PzSZRC+pn5k8+aJi3xYMA3BQzglQmjK3hA1Rlc3QgTWVzc2FnZQ=="

      # 3
      pr3 = TonSdk::Crypto::ParamsOfNaclSignOpen.new(
        signed: TonSdk::Helper.base64_from_hex("fb0cfe40eea5d6c960652e6ceb904da8a72ee2fcf6e05089cf835203179ff65bb48c57ecf31dcfcd26510bea67e64f3e6898b7c58300dc14338254268cade10354657374204d657373616765"),
        public_: "1869b7ef29d58026217e9cf163cbfbd0de889bdf1bf4daebf5433a312f5b8d6e"
      )
      TonSdk::Crypto::nacl_sign_open(@c_ctx.context, pr3) { |a| @res3 = a }
      expect(@res3.success?).to eq true
      expect("Test Message").to eq Base64.decode64(@res3.result.unsigned)
    end
  end
end
