module TonSdk
  module Crypto

    #
    # types
    #
    module ErrorCode
      INVALID_PUBLICKEY = 100
      INVALID_SECRETKEY = 101
      INVALID_KEY = 102
      INVALID_FACTORIZE_CHALLENGE = 106
      INVALID_BIGINT = 107
      SCRYPT_FAILED = 108,
      INVALID_KEYSIZE = 109
      NACL_SECRET_BOX_FAILED = 110,
      NACL_BOX_FAILED = 111,
      NACL_SIGN_FAILED = 112,
      BIP39_INVALID_ENTROPY = 113
      BIP39_INVALID_PHRASE = 114
      BIP32_INVALID_KEY = 115
      BIP32_INVALID_DERIVEPATH = 116
      BIP39_INVALID_DICTIONARY = 117
      BIP39_INVALID_WORDCOUNT = 118
      MNEMONIC_GENERATION_FAILED = 119
      MNEMONICFROMENTROPY_FAILED = 120
      SIGNING_BOX_NOT_REGISTERED = 121
      INVALID_SIGNATURE = 122
    end

    class ParamsOfFactorize
      attr_reader :composite

      def initialize(a)
        @composite = a
      end

      def to_h = { composite: @composite }
    end

    class ResultOfFactorize
      attr_reader :factors

      def initialize(a)
        @factors = a
      end
    end

    class ParamsOfModularPower
      attr_reader :base, :exponent, :modulus

      def initialize(base:, exponent:, modulus:)
        @base = base
        @exponent = exponent
        @modulus = modulus
      end

      def to_h
        {
          base: @base,
          exponent: @exponent,
          modulus: @modulus
        }
      end
    end

    class ResultOfModularPower
      attr_reader :modular_power

      def initialize(a)
        @modular_power = a
      end
    end

    class ParamsOfTonCrc16
      attr_reader :data

      def initialize(a)
        @data = a
      end

      def to_h = { data: @data }
    end

    class ResultOfTonCrc16
      attr_reader :crc

      def initialize(a)
        @crc = a
      end
    end

    class ParamsOfGenerateRandomBytes
      attr_reader :length

      def initialize(a)
        @length = a
      end

      def to_h
        {
          length: @length
        }
      end
    end

    class ResultOfGenerateRandomBytes
      attr_reader :bytes

      def initialize(a)
        @bytes = a
      end
    end

    class ParamsOfConvertPublicKeyToTonSafeFormat
      attr_reader :public_key

      def initialize(a)
        @public_key = a
      end

      def to_h
        {
          public_key: @public_key
        }
      end
    end

    class ResultOfConvertPublicKeyToTonSafeFormat
      attr_reader :ton_public_key

      def initialize(a)
        @ton_public_key = a
      end
    end

    class KeyPair
      attr_reader :public_, :secret

      def initialize(public_: , secret:)
        @public_ = public_
        @secret = secret
      end

      def to_h
        {
          public: @public_,
          secret: @secret
        }
      end
    end

    class ParamsOfSign
      attr_reader :unsigned, :keys

      def initialize(unsigned:, keys:)
        @unsigned = unsigned
        @keys = keys
      end

      def to_h
        {
          unsigned: @unsigned,
          keys: @keys.to_h
        }
      end
    end

    class ResultOfSign
      attr_reader :signed, :signature

      def initialize(signed:, signature:)
        @signed = signed
        @signature = signature
      end
    end

    class ParamsOfVerifySignature
      attr_reader :signed, :public_

      def initialize(signed:, public_:)
        @signed = signed
        @public_ = public_
      end

      def to_h
        {
          signed: @signed,
          public: @public_
        }
      end
    end

    class ResultOfVerifySignature
      attr_reader :unsigned

      def initialize(a)
        @unsigned = a
      end
    end

    class ParamsOfHash
      attr_reader :data

      def initialize(a)
        @data = a
      end

      def to_h
        {
          data: @data
        }
      end
    end

    class ResultOfHash
      attr_reader :hash

      def initialize(a)
        @hash = a
      end
    end

    class ParamsOfScrypt
      attr_reader :password, :salt, :log_n, :r, :p_, :dk_len

      def initialize(password:, salt:, log_n:, r:, p_:, dk_len:)
        @password = password
        @salt = salt
        @log_n = log_n
        @r = r
        @p_ = p_
        @dk_len = dk_len
      end

      def to_h
        {
          password: @password,
          salt: @salt,
          log_n: @log_n,
          r: @r,
          p: @p_,
          dk_len: @dk_len
        }
      end
    end

    class ResultOfScrypt
      attr_reader :key

      def initialize(a)
        @key = a
      end
    end

    class ParamsOfNaclSignKeyPairFromSecret
      attr_reader :secret

      def initialize(a)
        @secret = a
      end

      def to_h
        {
          secret: @secret
        }
      end
    end

    class ParamsOfNaclSign
      attr_reader :unsigned, :secret

      def initialize(unsigned:, secret:)
        @unsigned = unsigned
        @secret = secret
      end

      def to_h
        {
          unsigned: @unsigned,
          secret: @secret
        }
      end
    end

    class ResultOfNaclSign
      attr_reader :secret

      def initialize(a)
        @secret = a
      end
    end

    class ParamsOfNaclSignOpen
      attr_reader :signed, :public_

      def initialize(signed:, public_:)
        @signed = signed
        @public_ = public_
      end

      def to_h
        {
          signed: @signed,
          public: @public_
        }
      end
    end

    class ResultOfNaclSignOpen
      attr_reader :unsigned

      def initialize(a)
        @unsigned = a
      end
    end

    class ResultOfNaclSignDetached
      attr_reader :signature

      def initialize(a)
        @signature = a
      end
    end

    class ParamsOfNaclBoxKeyPairFromSecret
      attr_reader :secret

      def initialize(a)
        @secret = a
      end

      def to_h
        {
          secret: @secret
        }
      end
    end

    class ParamsOfNaclBox
      attr_reader :decrypted, :nonce, :their_public, :secret

      def initialize(decrypted:, nonce:, their_public:, secret:)
        @decrypted = decrypted
        @nonce = nonce
        @their_public = their_public
        @secret = secret
      end

      def to_h
        {
          decrypted: @decrypted,
          nonce: @nonce,
          their_public: @their_public,
          secret: @secret
        }
      end
    end

    class ResultOfNaclBox
      attr_reader :encrypted

      def initialize(a)
        @encrypted = a
      end
    end

    class ParamsOfNaclBoxOpen
      attr_reader :encrypted, :nonce, :their_public, :secret

      def initialize(encrypted:, nonce:, their_public:, secret:)
        @encrypted = encrypted
        @nonce = nonce
        @their_public = their_public
        @secret = secret
      end

      def to_h
        {
          encrypted: @encrypted,
          nonce: @nonce,
          their_public: @their_public,
          secret: @secret
        }
      end
    end

    class ResultOfNaclBoxOpen
      attr_reader :decrypted

      def initialize(a)
        @decrypted = a
      end
    end

    class ParamsOfNaclSecretBox
      attr_reader :decrypted, :nonce, :key

      def initialize(decrypted:, nonce:, key:)
        @decrypted = decrypted
        @nonce = nonce
        @key = key
      end

      def to_h
        {
          decrypted: @decrypted,
          nonce: @nonce,
          key: @key
        }
      end
    end

    class ParamsOfNaclSecretBoxOpen
      attr_reader :encrypted, :nonce, :key

      def initialize(encrypted:, nonce:, key:)
        @encrypted = encrypted
        @nonce = nonce
        @key = key
      end

      def to_h
        {
          encrypted: @encrypted,
          nonce: @nonce,
          key: @key
        }
      end
    end

    class ParamsOfMnemonicWords
      attr_reader :dictionary

      def initialize(a: nil)
        @dictionary = a
      end

      def to_h
        {
          dictionary: @dictionary
        }
      end
    end

    class ResultOfMnemonicWords
      attr_reader :words

      def initialize(a)
        @words = a
      end
    end

    class ParamsOfMnemonicFromRandom
      attr_reader :dictionary, :word_count

      def initialize(dictionary: nil, word_count: nil)
        @dictionary = dictionary
        @word_count = word_count
      end

      def to_h
        {
          dictionary: @dictionary,
          word_count: @word_count
        }
      end
    end

    class ResultOfMnemonicFromRandom
      attr_reader :phrase

      def initialize(a)
        @phrase = a
      end
    end

    class ParamsOfMnemonicFromEntropy
      attr_reader :entropy, :dictionary, :word_count

      def initialize(entropy:, dictionary: nil, word_count: nil)
        @entropy = entropy
        @dictionary = dictionary
        @word_count = word_count
      end

      def to_h
        {
          entropy: @entropy,
          dictionary: @dictionary,
          word_count: @word_count
        }
      end
    end

    class ResultOfMnemonicFromEntropy
      attr_reader :phrase

      def initialize(a)
        @phrase = a
      end
    end

    class ParamsOfMnemonicVerify
      attr_reader :phrase, :dictionary, :word_count

      def initialize(phrase:, dictionary: nil, word_count: nil)
        @phrase = phrase
        @dictionary = dictionary
        @word_count = word_count
      end

      def to_h
        {
          phrase: @phrase,
          dictionary: @dictionary,
          word_count: @word_count
        }
      end
    end

    class ResultOfMnemonicVerify
      attr_reader :valid

      def initialize(a)
        @valid = a
      end
    end

    class ParamsOfMnemonicDeriveSignKeys
      attr_reader :phrase, :path, :dictionary, :word_count

      def initialize(phrase:, path: nil, dictionary: nil, word_count: nil)
        @phrase = phrase
        @path = path
        @dictionary = dictionary
        @word_count = word_count
      end

      def to_h
        {
          phrase: @phrase,
          path: @path,
          dictionary: @dictionary,
          word_count: @word_count
        }
      end
    end

    class ParamsOfHDKeyXPrvFromMnemonic
      attr_reader :phrase, :dictionary, :word_count

      def initialize(phrase:, dictionary: nil, word_count: nil)
        @phrase = phrase
        @dictionary = dictionary
        @word_count = word_count
      end

      def to_h
        {
          phrase: @phrase,
          dictionary: @dictionary,
          word_count: @word_count
        }
      end
    end

    class ResultOfHDKeyXPrvFromMnemonic
      attr_reader :xprv

      def initialize(a)
        @xprv = a
      end
    end

    class ParamsOfHDKeyDeriveFromXPrv
      attr_reader :xprv, :child_index, :hardened

      def initialize(xprv:, child_index:, hardened:)
        @xprv = xprv
        @child_index = child_index
        @hardened = hardened
      end

      def to_h
        {
          xprv: @xprv,
          child_index: @child_index,
          hardened: @hardened
        }
      end
    end

    class ResultOfHDKeyDeriveFromXPrv
      attr_reader :xprv

      def initialize(a)
        @xprv = a
      end

      def to_h
        {
          xprv: @xprv,
          path: @path
        }
      end
    end

    class ParamsOfHDKeySecretFromXPrv
      attr_reader :xprv

      def initialize(a)
        @xprv = a
      end

      def to_h
        {
          xprv: @xprv
        }
      end
    end

    class ResultOfHDKeySecretFromXPrv
      attr_reader :secret

      def initialize(a)
        @secret = a
      end
    end

    class ParamsOfHDKeyPublicFromXPrv
      attr_reader :xprv

      def initialize(a)
        @xprv = a
      end

      def to_h
        {
          xprv: @xprv
        }
      end
    end

    class ResultOfHDKeyPublicFromXPrv
      attr_reader :public_

      def initialize(a)
        @public_ = a
      end
    end

    class ParamsOfHDKeyDeriveFromXPrvPath
      attr_reader :xprv, :path

      def initialize(xprv:, path:)
        @xprv = xprv
        @path = path
      end

      def to_h
        {
          xprv: @xprv,
          path: @path
        }
      end
    end

    class ResultOfHDKeyDeriveFromXPrvPath
      attr_reader :xprv

      def initialize(a)
        @xprv = a
      end
    end

    class ParamsOfChaCha20
      attr_reader :data, :key, :nonce

      def initialize(data:, key:, nonce:)
        @data = data
        @key = key
        @nonce = nonce
      end

      def to_h
        {
          data: @data,
          key: @key,
          nonce: @nonce
        }
      end
    end

    class ResultOfChaCha20
      attr_reader :data

      def initialize(a)
        @data = a
      end
    end

    class ParamsOfSigningBoxSign
      attr_reader :signing_box, :unsigned

      def initialize(signing_box:, unsigned:)
        @signing_box = signing_box
        @unsigned = unsigned
      end

      def to_h
        {
          signing_box: @signing_box,
          unsigned: @unsigned
        }
      end
    end

    class ResultOfSigningBoxSign
      attr_reader :signature

      def initialize(a)
        @signature = a
      end
    end

    class RegisteredSigningBox
      attr_reader :handle

      def initialize(a)
        @handle = a
      end

      def to_h
        {
          handle: @handle
        }
      end
    end

    class ResultOfSigningBoxGetPublicKey
      attr_reader :pubkey

      def initialize(a)
        @pubkey = a
      end

      def to_h = { pubkey: @pubkey }
    end

    class ParamsOfNaclSignDetachedVerify
      attr_reader :unsigned, :signature, :public

      def initialize(unsigned:, signature:, public_:)
        @unsigned:, @signature:, @public_ = unsigned, signature, public_
      end

      def to_h
        {
          unsigned: @unsigned,
          signature: @signature,
          public: @public_
        }
      end
    end

    class ResultOfNaclSignDetachedVerify 
      attr_reader :succeeded

      def initialize(a)
        @succeeded = a
      end

      def to_h = { succeeded: @succeeded }
    end


    #
    # functions
    #

    def self.factorize(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.factorize", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfFactorize.new(resp.result["factors"])
          )
        else
          yield resp
        end
      end
    end

    def self.modular_power(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.modular_power", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfModularPower.new(resp.result["modular_power"])
          )
        else
          yield resp
        end
      end
    end

    def self.ton_crc16(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.ton_crc16", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfTonCrc16.new(resp.result["crc"])
          )
        else
          yield resp
        end
      end
    end

    def self.generate_random_bytes(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.generate_random_bytes", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGenerateRandomBytes.new(resp.result["bytes"])
          )
        else
          yield resp
        end
      end
    end

    def self.convert_public_key_to_ton_safe_format(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.convert_public_key_to_ton_safe_format", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfConvertPublicKeyToTonSafeFormat.new(resp.result["ton_public_key"])
          )
        else
          yield resp
        end
      end
    end

    def self.generate_random_sign_keys(ctx)
      Interop::request_to_native_lib(ctx, "crypto.generate_random_sign_keys", "") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: KeyPair.new(
              public_: resp.result["public"],
              secret: resp.result["secret"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.sign(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.sign", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfSign.new(
              signed: resp.result["signed"],
              signature: resp.result["signature"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.verify_signature(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.verify_signature", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfVerifySignature.new(resp.result["unsigned"])
          )
        else
          yield resp
        end
      end
    end

    def self.sha256(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.sha256", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHash.new(resp.result["hash"])
          )
        else
          yield resp
        end
      end
    end

    def self.sha512(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.sha512", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHash.new(resp.result["hash"])
          )
        else
          yield resp
        end
      end
    end

    def self.scrypt(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.scrypt", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfScrypt.new(resp.result["key"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_keypair_from_secret_key(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_keypair_from_secret_key", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: KeyPair.new(public_: resp.result["public"], secret: resp.result["secret"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclSign.new(resp.result["signed"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_open(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_open", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclSignOpen.new(resp.result["unsigned"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_detached(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_detached", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclSignDetached.new(resp.result["signature"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_box_keypair(ctx)
      Interop::request_to_native_lib(ctx, "crypto.nacl_box_keypair", "") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: KeyPair.new(public_: resp.result["public"], secret: resp.result["secret"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_box_keypair_from_secret_key(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.nacl_box_keypair_from_secret_key", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: KeyPair.new(public_: resp.result["public"], secret: resp.result["secret"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_box(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.nacl_box", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclBox.new(resp.result["encrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_box_open(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.nacl_box_open", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclBoxOpen.new(resp.result["decrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_secret_box(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.nacl_secret_box", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclBox.new(resp.result["encrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_secret_box_open(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.nacl_secret_box_open", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclBoxOpen.new(resp.result["decrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_words(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_words", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfMnemonicWords.new(resp.result["words"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_from_random(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_from_random", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfMnemonicFromRandom.new(resp.result["phrase"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_from_entropy(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_from_entropy", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfMnemonicFromEntropy.new(resp.result["phrase"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_verify(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_verify", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfMnemonicVerify.new(resp.result["valid"])
          )
        else
          yield resp
        end
      end
    end


    def self.mnemonic_derive_sign_keys(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_derive_sign_keys", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: KeyPair.new(public_: resp.result["public"], secret: resp.result["secret"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_xprv_from_mnemonic(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.hdkey_xprv_from_mnemonic", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHDKeyXPrvFromMnemonic.new(resp.result["xprv"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_derive_from_xprv(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.hdkey_derive_from_xprv", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHDKeyDeriveFromXPrv.new(resp.result["xprv"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_derive_from_xprv_path(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.hdkey_derive_from_xprv_path", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHDKeyDeriveFromXPrvPath.new(resp.result["xprv"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_secret_from_xprv(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.hdkey_secret_from_xprv", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHDKeySecretFromXPrv.new(resp.result["secret"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_public_from_xprv(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.hdkey_public_from_xprv", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHDKeyPublicFromXPrv.new(resp.result["public"])
          )
        else
          yield resp
        end
      end
    end

    def self.chacha20(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "crypto.chacha20", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfChaCha20.new(resp.result["data"])
          )
        else
          yield resp
        end
      end
    end

    def self.register_signing_box(ctx, pr_s)
      Interop::request_to_native_lib(ctx, "crypto.register_signing_box", pr_s.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: RegisteredSigningBox.new(resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_signing_box(ctx, pr_s)
      Interop::request_to_native_lib(ctx, "crypto.get_signing_box", pr_s.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: RegisteredSigningBox.new(resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.signing_box_get_public_key(ctx, pr_s)
      Interop::request_to_native_lib(ctx, "crypto.signing_box_get_public_key", pr_s.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfSigningBoxGetPublicKey.new(resp.result["pubkey"])
          )
        else
          yield resp
        end
      end
    end


    def self.signing_box_sign(ctx, pr_s)
      Interop::request_to_native_lib(ctx, "crypto.signing_box_sign", pr_s.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfSigningBoxSign.new(resp.result["signature"])
          )
        else
          yield resp
        end
      end
    end

    def self.remove_signing_box(ctx, pr_s)
      Interop::request_to_native_lib(ctx, "crypto.remove_signing_box", pr_s.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfSigningBoxSign.new(resp.result["signature"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_detached_verify(ctx, pr_s)
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_detached_verify", pr_s.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclSignDetachedVerify.new(resp.result["succeeded"])
          )
        else
          yield resp
        end
      end
    end
  end
end