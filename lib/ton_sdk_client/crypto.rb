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
      SCRYPT_FAILED = 108
      INVALID_KEYSIZE = 109
      NACL_SECRET_BOX_FAILED = 110
      NACL_BOX_FAILED = 111
      NACL_SIGN_FAILED = 112
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
      ENCRYPTION_BOX_NOT_REGISTERED = 123
      INVALID_IV_SIZE = 124
      UNSUPPORTED_CIPHER_MODE = 125
      CANNOT_CREATE_CIPHER = 126
      ENCRYPT_DATA_ERROR = 127
      DECRYPT_DATA_ERROR = 128
      IV_REQUIRED = 129
      CRYPTO_BOX_NOT_REGISTERED = 130
      INVALID_CRYPTO_BOX_TYPE = 131
      CRYPTO_BOX_SECRET_SERIALIZATION_ERROR = 132
      CRYPTO_BOX_SECRET_DESERIALIZATION_ERROR = 133
    end

    ParamsOfFactorize = KwStruct.new(:composite)
    ResultOfFactorize = KwStruct.new(:factors)
    ParamsOfModularPower = KwStruct.new(:base, :exponent, :modulus)
    ResultOfModularPower = KwStruct.new(:modular_power)
    ParamsOfTonCrc16 = KwStruct.new(:data)

    ResultOfTonCrc16 = KwStruct.new(:crc)
    ParamsOfGenerateRandomBytes = KwStruct.new(:length)
    ResultOfGenerateRandomBytes = KwStruct.new(:bytes)
    ParamsOfConvertPublicKeyToTonSafeFormat  = KwStruct.new(:public_key)
    ResultOfConvertPublicKeyToTonSafeFormat = KwStruct.new(:ton_public_key)

    KeyPair = KwStruct.new(:public_, :secret) do
      def to_h
        {
          public: public_,
          secret: secret
        }
      end
    end
    ParamsOfSign = KwStruct.new(:unsigned, :keys) do
      def to_h
        {
          unsigned: unsigned,
          keys: keys&.to_h
        }
      end
    end
    ResultOfSign = KwStruct.new(:signed, :signature)
    ParamsOfVerifySignature = KwStruct.new(:signed, :public_) do
      def to_h
        {
          signed: signed,
          public: public_
        }
      end
    end
    ResultOfVerifySignature = KwStruct.new(:unsigned)

    ParamsOfHash = KwStruct.new(:data)
    ResultOfHash = KwStruct.new(:hash)
    ParamsOfScrypt = KwStruct.new(:password, :salt, :log_n, :r, :p, :dk_len)
    ResultOfScrypt = KwStruct.new(:key)
    ParamsOfNaclSignKeyPairFromSecret = KwStruct.new(:secret)

    ParamsOfNaclSign = KwStruct.new(:unsigned, :secret)
    ResultOfNaclSign = KwStruct.new(:signed)
    ParamsOfNaclSignOpen = KwStruct.new(:signed, :public_) do
      def to_h
        {
          signed: signed,
          public: public_
        }
      end
    end

    ResultOfNaclSignOpen = KwStruct.new(:unsigned)

    ParamsOfNaclSignDetached = KwStruct.new(:unsigned, :secret)

    ResultOfNaclSignDetached = KwStruct.new(:signature)

    ParamsOfNaclBoxKeyPairFromSecret = KwStruct.new(:secret)

    ParamsOfNaclBox = KwStruct.new(:decrypted, :nonce, :their_public, :secret)

    ResultOfNaclBox = KwStruct.new(:encrypted)
    ParamsOfNaclBoxOpen = KwStruct.new(:encrypted, :nonce, :their_public, :secret)

    ResultOfNaclBoxOpen = KwStruct.new(:decrypted)
    ParamsOfNaclSecretBox = KwStruct.new(:decrypted, :nonce, :key)

    ParamsOfNaclSecretBoxOpen = KwStruct.new(:encrypted, :nonce, :key)

    ParamsOfMnemonicWords = KwStruct.new(:dictionary)
    ResultOfMnemonicWords = KwStruct.new(:words)
    ParamsOfMnemonicFromRandom = KwStruct.new(:dictionary, :word_count)
    ResultOfMnemonicFromRandom = KwStruct.new(:phrase)

    ParamsOfMnemonicFromEntropy = KwStruct.new(:entropy, :dictionary, :word_count)

    ResultOfMnemonicFromEntropy = KwStruct.new(:phrase)

    ParamsOfMnemonicVerify = KwStruct.new(:phrase, :dictionary, :word_count)

    ResultOfMnemonicVerify = KwStruct.new(:valid)

    ParamsOfMnemonicDeriveSignKeys = KwStruct.new(:phrase, :path, :dictionary, :word_count)

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

    ResultOfHDKeyXPrvFromMnemonic = KwStruct.new(:xprv)

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

    ResultOfHDKeyDeriveFromXPrv = KwStruct.new(:xprv)
    ParamsOfHDKeySecretFromXPrv = KwStruct.new(:xprv)
    ResultOfHDKeySecretFromXPrv = KwStruct.new(:secret)
    ParamsOfHDKeyPublicFromXPrv = KwStruct.new(:xprv)
    ResultOfHDKeyPublicFromXPrv = KwStruct.new(:public_)

    ParamsOfHDKeyDeriveFromXPrvPath = KwStruct.new(:xprv, :path)

    ResultOfHDKeyDeriveFromXPrvPath = KwStruct.new(:xprv)

    ParamsOfChaCha20 = KwStruct.new(:data, :key, :nonce)

    ResultOfChaCha20 = KwStruct.new(:data)

    ParamsOfSigningBoxSign = KwStruct.new(:signing_box, :unsigned)

    ResultOfSigningBoxSign = KwStruct.new(:signature)

    RegisteredSigningBox = KwStruct.new(:handle)

    ResultOfSigningBoxGetPublicKey = KwStruct.new(:pubkey)

    ParamsOfNaclSignDetachedVerify = KwStruct.new(:unsigned, :signature, :public_) do
      def to_h
        {
          unsigned: unsigned,
          signature: signature,
          public: public_
        }
      end
    end

    ResultOfNaclSignDetachedVerify = KwStruct.new(:succeeded)

    class ParamsOfAppSigningBox
      TYPES = [:get_public_key, :sign]

      attr_reader :type_, :unsigned

      def initialize(type_:, unsigned:)
        unless TYPES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end
        @type_ = type_
        @unsigned = unsigned
      end

      def to_h
        {
          type: Helper.sym_to_capitalized_case_str(@type_),
          unsigned: @unsigned
        }
      end
    end

    EncryptionBoxInfo = KwStruct.new(:hdpath, :algorithm, :options, :public)

    ParamsOfEncryptionBoxGetInfo = KwStruct.new(:encryption_box)

    ResultOfEncryptionBoxGetInfo = KwStruct.new(:info)

    ParamsOfEncryptionBoxEncrypt = KwStruct.new(:encryption_box, :data)

    RegisteredEncryptionBox = KwStruct.new(:handle)

    ResultOfEncryptionBoxEncrypt = KwStruct.new(:data)

    ParamsOfEncryptionBoxDecrypt = KwStruct.new(:encryption_box, :data)

    ResultOfEncryptionBoxDecrypt = KwStruct.new(:data)

    ParamsOfCreateEncryptionBox = KwStruct.new(:algorithm)

    class CryptoBoxSecret
      TYPES = %i[random_seed_phrase predefined_seed_phrase encrypted_secret]
      attr_reader :type, :args

      def initialize(type:, **args)
        unless TYPES.include?(type)
          raise ArgumentError.new("type #{type} is unknown; known types: #{TYPES}")
        end
        @type = type
        @args = args
      end

      def to_h
        hash = case type
               when :random_seed_phrase
                 {
                   dictionary: args[:dictionary],
                   wordcount: args[:wordcount]
                 }
               when :predefined_seed_phrase
                 {
                   phrase: args[:phrase],
                   dictionary: args[:dictionary],
                   wordcount: args[:wordcount]
                 }
               when :encrypted_secret
                 {
                   encrypted_secret: args[:encrypted_secret]
                 }
               end
        {
          type: Helper.sym_to_capitalized_case_str(type)
        }.merge(hash)
      end
    end

    class BoxEncryptionAlgorithm
      TYPES = %i[cha_cha20 nacl_box nacl_secret_box]
      attr_reader :type, :args

      def initialize(type:, **args)
        unless TYPES.include?(type)
          raise ArgumentError.new("type #{type} is unknown; known types: #{TYPES}")
        end
        @type = type
        @args = args
      end

      def to_h
        hash = case type
               when :cha_cha20
                 {
                   nonce: args[:nonce]
                 }
               when :nacl_box
                 {
                   their_public: args[:their_public],
                   nonce: args[:nonce]
                 }
               when :nacl_secret_box
                 {
                   nonce: args[:nonce]
                 }
               end
        {
          type: Helper.sym_to_capitalized_case_str(type)
        }.merge(hash)
      end
    end

    class ParamsOfAppEncryptionBox
      TYPES = %i[get_info encrypt decrypt]
      attr_reader :type, :args

      def initialize(type:, **args)
        unless TYPES.include?(type)
          raise ArgumentError.new("type #{type} is unknown; known types: #{TYPES}")
        end
        @type = type
        @args = args
      end

      def to_h
        hash = case type
               when :get_info
                 {}
               when :encrypt, :decrypt
                 {
                   data: args[:data]
                 }
               end
        {
          type: Helper.sym_to_capitalized_case_str(type)
        }.merge(hash)
      end
    end

    ParamsOfCreateCryptoBox = KwStruct.new(:secret_encryption_salt, :secret)

    RegisteredCryptoBox = KwStruct.new(:handle)

    ParamsOfAppPasswordProvider = KwStruct.new(:encryption_public_key) do
      attr_reader :type, :encryption_public_key

      def initialize(encryption_public_key:)
        @type = "GetPassword"
        @encryption_public_key = encryption_public_key
      end

      def to_h
        {
          type: type,
          encryption_public_key: encryption_public_key
        }
      end
    end

    ResultOfAppPasswordProvider = KwStruct.new(:type, :encrypted_password, :app_encryption_pubkey)

    ResultOfGetCryptoBoxInfo = KwStruct.new(:encrypted_secret)

    ResultOfGetCryptoBoxSeedPhrase = KwStruct.new(:phrase, :dictionary, :wordcount)

    ParamsOfGetSigningBoxFromCryptoBox = KwStruct.new(:handle, :hdpath, :secret_lifetime)

    ParamsOfGetEncryptionBoxFromCryptoBox = KwStruct.new(:handle, :hdpath, :algorithm, :secret_lifetime)

    class EncryptionAlgorithm
      private_class_method :new

      attr_reader :type_, :aes_params

      def self.new_with_type_aes(aes_params:)
        @type_ = :aes
        @aes_params = aes_params
      end
    end

    #
    # functions
    #

    def self.factorize(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.factorize", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfFactorize.new(factors: resp.result["factors"])
          )
        else
          yield resp
        end
      end
    end

    def self.modular_power(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.modular_power", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfModularPower.new(modular_power: resp.result["modular_power"])
          )
        else
          yield resp
        end
      end
    end

    def self.ton_crc16(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.ton_crc16", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfTonCrc16.new(crc: resp.result["crc"])
          )
        else
          yield resp
        end
      end
    end

    def self.generate_random_bytes(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.generate_random_bytes", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfGenerateRandomBytes.new(bytes: resp.result["bytes"])
          )
        else
          yield resp
        end
      end
    end

    def self.convert_public_key_to_ton_safe_format(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.convert_public_key_to_ton_safe_format", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfConvertPublicKeyToTonSafeFormat.new(ton_public_key: resp.result["ton_public_key"])
          )
        else
          yield resp
        end
      end
    end

    def self.generate_random_sign_keys(ctx, is_single_thread_only: false)
      Interop::request_to_native_lib(ctx, "crypto.generate_random_sign_keys", nil, is_single_thread_only: is_single_thread_only) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
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

    def self.sign(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.sign", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
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

    def self.verify_signature(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.verify_signature", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfVerifySignature.new(unsigned: resp.result["unsigned"])
          )
        else
          yield resp
        end
      end
    end

    def self.sha256(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.sha256", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfHash.new(hash: resp.result["hash"])
          )
        else
          yield resp
        end
      end
    end

    def self.sha512(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.sha512", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfHash.new(hash: resp.result["hash"])
          )
        else
          yield resp
        end
      end
    end

    def self.scrypt(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.scrypt", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfScrypt.new(key: resp.result["key"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_keypair_from_secret_key(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_keypair_from_secret_key", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
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

    def self.nacl_sign(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfNaclSign.new(signed: resp.result["signed"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_open(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_open", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfNaclSignOpen.new(unsigned: resp.result["unsigned"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_detached(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_detached", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfNaclSignDetached.new(signature: resp.result["signature"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_detached_verify(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_detached_verify", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfNaclSignDetachedVerify.new(succeeded: resp.result["succeeded"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_box_keypair(ctx)
      Interop::request_to_native_lib(ctx, "crypto.nacl_box_keypair") do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
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

    def self.nacl_box_keypair_from_secret_key(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_box_keypair_from_secret_key", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
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

    def self.nacl_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_box", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfNaclBox.new(encrypted: resp.result["encrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_box_open(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_box_open", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfNaclBoxOpen.new(decrypted: resp.result["decrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_secret_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_secret_box", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfNaclBox.new(encrypted: resp.result["encrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_secret_box_open(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_secret_box_open", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfNaclBoxOpen.new(decrypted: resp.result["decrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_words(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_words", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfMnemonicWords.new(words: resp.result["words"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_from_random(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_from_random", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfMnemonicFromRandom.new(phrase: resp.result["phrase"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_from_entropy(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_from_entropy", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfMnemonicFromEntropy.new(phrase: resp.result["phrase"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_verify(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_verify", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfMnemonicVerify.new(valid: resp.result["valid"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_derive_sign_keys(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_derive_sign_keys", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
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

    def self.hdkey_xprv_from_mnemonic(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.hdkey_xprv_from_mnemonic", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfHDKeyXPrvFromMnemonic.new(xprv: resp.result["xprv"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_derive_from_xprv(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.hdkey_derive_from_xprv", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfHDKeyDeriveFromXPrv.new(xprv: resp.result["xprv"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_derive_from_xprv_path(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.hdkey_derive_from_xprv_path", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfHDKeyDeriveFromXPrvPath.new(xprv: resp.result["xprv"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_secret_from_xprv(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.hdkey_secret_from_xprv", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfHDKeySecretFromXPrv.new(secret: resp.result["secret"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_public_from_xprv(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.hdkey_public_from_xprv", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfHDKeyPublicFromXPrv.new(public_: resp.result["public"])
          )
        else
          yield resp
        end
      end
    end

    def self.chacha20(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.chacha20", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfChaCha20.new(data: resp.result["data"])
          )
        else
          yield resp
        end
      end
    end

    def self.register_signing_box(ctx, callback:)
      Interop::request_to_native_lib(
        ctx,
        "crypto.register_signing_box",
        nil,
        client_callback: callback,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: RegisteredSigningBox.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_signing_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.get_signing_box", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: RegisteredSigningBox.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.signing_box_get_public_key(ctx, params, is_single_thread_only: false)
      Interop::request_to_native_lib(
        ctx,
        "crypto.signing_box_get_public_key",
        params,
        is_single_thread_only: is_single_thread_only
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfSigningBoxGetPublicKey.new(pubkey: resp.result["pubkey"])
          )
        else
          yield resp
        end
      end
    end

    def self.signing_box_sign(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.signing_box_sign", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfSigningBoxSign.new(signature: resp.result["signature"])
          )
        else
          yield resp
        end
      end
    end

    def self.remove_signing_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.remove_signing_box", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end

    def self.register_encryption_box(ctx, callback:)
      Interop::request_to_native_lib(
        ctx,
        "crypto.register_encryption_box",
        nil,
        client_callback: callback,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: RegisteredEncryptionBox.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.remove_encryption_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.remove_encryption_box", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end

    def self.encryption_box_get_info(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.encryption_box_get_info", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfEncryptionBoxGetInfo.new(info: resp.result["info"])
          )
        else
          yield resp
        end
      end
    end

    def self.encryption_box_encrypt(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.encryption_box_encrypt", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfEncryptionBoxEncrypt.new(data: resp.result["data"])
          )
        else
          yield resp
        end
      end
    end

    def self.encryption_box_decrypt(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.encryption_box_decrypt", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfEncryptionBoxDecrypt.new(data: resp.result["data"])
          )
        else
          yield resp
        end
      end
    end

    def self.create_encryption_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.create_encryption_box", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: RegisteredEncryptionBox.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.create_crypto_box(ctx, params, callback:)
      Interop::request_to_native_lib(
        ctx,
        "crypto.create_crypto_box",
        params,
        client_callback: callback,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: RegisteredCryptoBox.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.remove_crypto_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.remove_crypto_box", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end

    def self.get_crypto_box_info(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.get_crypto_box_info", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfGetCryptoBoxInfo.new(
              encrypted_secret: resp.result["encrypted_secret"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.get_crypto_box_seed_phrase(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.get_crypto_box_seed_phrase", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfGetCryptoBoxSeedPhrase.new(
              phrase: resp.result["phrase"],
              dictionary: resp.result["dictionary"],
              wordcount: resp.result["wordcount"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.get_signing_box_from_crypto_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.get_signing_box_from_crypto_box", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: RegisteredSigningBox.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_encryption_box_from_crypto_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.get_encryption_box_from_crypto_box", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: RegisteredEncryptionBox.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.clear_crypto_box_secret_cache(ctx, params)
      Interop::request_to_native_lib(
        ctx,
        "crypto.clear_crypto_box_secret_cache",
        params
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end
  end
end
