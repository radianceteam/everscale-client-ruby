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
    end

    ParamsOfFactorize = Struct.new(:composite)
    ResultOfFactorize = Struct.new(:factors)
    ParamsOfModularPower = Struct.new(:base, :exponent, :modulus, keyword_init: true)
    ResultOfModularPower = Struct.new(:modular_power)
    ParamsOfTonCrc16 = Struct.new(:data)

    ResultOfTonCrc16 = Struct.new(:crc)
    ParamsOfGenerateRandomBytes = Struct.new(:length)
    ResultOfGenerateRandomBytes = Struct.new(:bytes)
    ParamsOfConvertPublicKeyToTonSafeFormat  = Struct.new(:public_key)
    ResultOfConvertPublicKeyToTonSafeFormat = Struct.new(:ton_public_key)

    KeyPair = Struct.new(:public_, :secret, keyword_init: true) do
      def to_h
        {
          public: public_,
          secret: secret
        }
      end
    end
    ParamsOfSign = Struct.new(:unsigned, :keys, keyword_init: true) do
      def to_h
        {
          unsigned: unsigned,
          keys: keys&.to_h
        }
      end
    end
    ResultOfSign = Struct.new(:signed, :signature, keyword_init: true)
    ParamsOfVerifySignature = Struct.new(:signed, :public_)
    ResultOfVerifySignature = Struct.new(:unsigned)

    ParamsOfHash = Struct.new(:data)
    ResultOfHash = Struct.new(:hash)
    ParamsOfScrypt = Struct.new(:password, :salt, :log_n, :r, :p, :dk_len, keyword_init: true)
    ResultOfScrypt = Struct.new(:key)
    ParamsOfNaclSignKeyPairFromSecret = Struct.new(:secret)

    ParamsOfNaclSign = Struct.new(:unsigned, :secret)
    ResultOfNaclSign = Struct.new(:signed)
    ParamsOfNaclSignOpen = Struct.new(:signed, :public_) do
      def initialize(signed:, public_:)
        super
      end
    end

    ResultOfNaclSignOpen = Struct.new(:unsigned)
    ResultOfNaclSignDetached = Struct.new(:signature)
    ParamsOfNaclBoxKeyPairFromSecret = Struct.new(:secret)
    ParamsOfNaclBox = Struct.new(:decrypted, :nonce, :their_public, :secret) do
      def initialize(decrypted:, nonce:, their_public:, secret:)
        super
      end
    end

    ResultOfNaclBox = Struct.new(:encrypted)
    ParamsOfNaclBoxOpen = Struct.new(:encrypted, :nonce, :their_public, :secret) do
      def initialize(encrypted:, nonce:, their_public:, secret:)
        super
      end
    end

    ResultOfNaclBoxOpen = Struct.new(:decrypted)
    ParamsOfNaclSecretBox = Struct.new(:decrypted, :nonce, :key) do
      def initialize(decrypted:, nonce:, key:)
        super
      end
    end

    ParamsOfNaclSecretBoxOpen = Struct.new(:encrypted, :nonce, :key) do
      def initialize(encrypted:, nonce:, key:)
        super
      end
    end

    ParamsOfMnemonicWords = Struct.new(:dictionary)
    ResultOfMnemonicWords = Struct.new(:words)
    ParamsOfMnemonicFromRandom = Struct.new(:dictionary, :word_count, keyword_init: true)
    ResultOfMnemonicFromRandom = Struct.new(:phrase)

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

    ResultOfMnemonicFromEntropy = Struct.new(:phrase)

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

    ResultOfMnemonicVerify = Struct.new(:valid)

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

    ResultOfHDKeyXPrvFromMnemonic = Struct.new(:xprv)

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

    ResultOfHDKeyDeriveFromXPrv = Struct.new(:xprv)
    ParamsOfHDKeySecretFromXPrv = Struct.new(:xprv)
    ResultOfHDKeySecretFromXPrv = Struct.new(:secret)
    ParamsOfHDKeyPublicFromXPrv = Struct.new(:xprv)
    ResultOfHDKeyPublicFromXPrv = Struct.new(:public_)

    ParamsOfHDKeyDeriveFromXPrvPath = Struct.new(:xprv, :path, keyword_init: true)

    ResultOfHDKeyDeriveFromXPrvPath = Struct.new(:xprv)

    ParamsOfChaCha20 = Struct.new(:data, :key, :nonce) do
      def initialize(data:, key:, nonce:)
        super
      end
    end

    ResultOfChaCha20 = Struct.new(:data)

    ParamsOfSigningBoxSign = Struct.new(:signing_box, :unsigned, keyword_init: true)

    ResultOfSigningBoxSign = Struct.new(:signature)
    RegisteredSigningBox = Struct.new(:handle)
    ResultOfSigningBoxGetPublicKey = Struct.new(:pubkey)

    class ParamsOfNaclSignDetachedVerify
      attr_reader :unsigned, :signature, :public

      def initialize(unsigned:, signature:, public_:)
        @unsigned, @signature, @public_ = unsigned, signature, public_
      end

      def to_h
        {
          unsigned: @unsigned,
          signature: @signature,
          public: @public_
        }
      end
    end

    ResultOfNaclSignDetachedVerify = Struct.new(:succeeded)

    class ParamsOfAppSigningBox
      TYPES = [
        :get_public_key,
        :sign
      ]

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

    EncryptionBoxInfo = Struct.new(:hdpath, :algorithm, :options, :public, keyword_init: true)
    ParamsOfEncryptionBoxGetInfo = Struct.new(:encryption_box)
    ResultOfEncryptionBoxGetInfo = Struct.new(:info)
    RegisteredEncryptionBox = Struct.new(:handle)
    ParamsOfCreateEncryptionBox = Struct.new(:algorithm)

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
          yield NativeLibResponsetResult.new(
            result: ResultOfFactorize.new(resp.result["factors"])
          )
        else
          yield resp
        end
      end
    end

    def self.modular_power(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.modular_power", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfModularPower.new(resp.result["modular_power"])
          )
        else
          yield resp
        end
      end
    end

    def self.ton_crc16(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.ton_crc16", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfTonCrc16.new(resp.result["crc"])
          )
        else
          yield resp
        end
      end
    end

    def self.generate_random_bytes(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.generate_random_bytes", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGenerateRandomBytes.new(resp.result["bytes"])
          )
        else
          yield resp
        end
      end
    end

    def self.convert_public_key_to_ton_safe_format(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.convert_public_key_to_ton_safe_format", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfConvertPublicKeyToTonSafeFormat.new(resp.result["ton_public_key"])
          )
        else
          yield resp
        end
      end
    end

    def self.generate_random_sign_keys(ctx, is_single_thread_only: false)
      Interop::request_to_native_lib(ctx, "crypto.generate_random_sign_keys", nil, is_single_thread_only: is_single_thread_only) do |resp|
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

    def self.sign(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.sign", params) do |resp|
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

    def self.verify_signature(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.verify_signature", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfVerifySignature.new(resp.result["unsigned"])
          )
        else
          yield resp
        end
      end
    end

    def self.sha256(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.sha256", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHash.new(resp.result["hash"])
          )
        else
          yield resp
        end
      end
    end

    def self.sha512(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.sha512", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHash.new(resp.result["hash"])
          )
        else
          yield resp
        end
      end
    end

    def self.scrypt(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.scrypt", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfScrypt.new(resp.result["key"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_keypair_from_secret_key(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_keypair_from_secret_key", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: KeyPair.new(public_: resp.result["public"], secret: resp.result["secret"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclSign.new(resp.result["signed"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_open(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_open", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclSignOpen.new(resp.result["unsigned"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_detached(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_detached", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclSignDetached.new(resp.result["signature"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_sign_detached_verify(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_sign_detached_verify", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclSignDetachedVerify.new(resp.result["succeeded"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_box_keypair(ctx)
      Interop::request_to_native_lib(ctx, "crypto.nacl_box_keypair") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: KeyPair.new(public_: resp.result["public"], secret: resp.result["secret"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_box_keypair_from_secret_key(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_box_keypair_from_secret_key", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: KeyPair.new(public_: resp.result["public"], secret: resp.result["secret"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_box", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclBox.new(resp.result["encrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_box_open(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_box_open", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclBoxOpen.new(resp.result["decrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_secret_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_secret_box", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclBox.new(resp.result["encrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.nacl_secret_box_open(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.nacl_secret_box_open", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfNaclBoxOpen.new(resp.result["decrypted"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_words(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_words", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfMnemonicWords.new(resp.result["words"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_from_random(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_from_random", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfMnemonicFromRandom.new(resp.result["phrase"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_from_entropy(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_from_entropy", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfMnemonicFromEntropy.new(resp.result["phrase"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_verify(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_verify", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfMnemonicVerify.new(resp.result["valid"])
          )
        else
          yield resp
        end
      end
    end

    def self.mnemonic_derive_sign_keys(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.mnemonic_derive_sign_keys", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: KeyPair.new(public_: resp.result["public"], secret: resp.result["secret"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_xprv_from_mnemonic(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.hdkey_xprv_from_mnemonic", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHDKeyXPrvFromMnemonic.new(resp.result["xprv"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_derive_from_xprv(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.hdkey_derive_from_xprv", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHDKeyDeriveFromXPrv.new(resp.result["xprv"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_derive_from_xprv_path(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.hdkey_derive_from_xprv_path", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHDKeyDeriveFromXPrvPath.new(resp.result["xprv"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_secret_from_xprv(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.hdkey_secret_from_xprv", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHDKeySecretFromXPrv.new(resp.result["secret"])
          )
        else
          yield resp
        end
      end
    end

    def self.hdkey_public_from_xprv(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.hdkey_public_from_xprv", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfHDKeyPublicFromXPrv.new(resp.result["public"])
          )
        else
          yield resp
        end
      end
    end

    def self.chacha20(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.chacha20", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfChaCha20.new(resp.result["data"])
          )
        else
          yield resp
        end
      end
    end

    def self.register_signing_box(ctx, app_obj:, is_single_thread_only: false)
      client_callback = Proc.new do |type_, x|
        app_res = app_obj.request(x["request_data"])
        app_req_result = case app_res
        in [:success, result]
          TonSdk::Client::AppRequestResult.new(
            type_: :ok,
            result: result
          )
        in [:error, text]
          TonSdk::Client::AppRequestResult.new(
            type_: :error,
            text: text
          )
        end

        params = TonSdk::Client::ParamsOfResolveAppRequest.new(
          app_request_id: x["app_request_id"],
          result: app_req_result
        )
        TonSdk::Client.resolve_app_request(ctx, params)
      end

      Interop::request_to_native_lib(
        ctx,
        "crypto.register_signing_box",
        nil,
        is_single_thread_only: is_single_thread_only
      ) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: RegisteredSigningBox.new(resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_signing_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.get_signing_box", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: RegisteredSigningBox.new(resp.result["handle"])
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
          yield NativeLibResponsetResult.new(
            result: ResultOfSigningBoxGetPublicKey.new(resp.result["pubkey"])
          )
        else
          yield resp
        end
      end
    end

    def self.signing_box_sign(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.signing_box_sign", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfSigningBoxSign.new(resp.result["signature"])
          )
        else
          yield resp
        end
      end
    end

    def self.remove_signing_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.remove_signing_box", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end

    def self.register_encryption_box(ctx, app_obj:)
      client_callback = Proc.new do |type_, x|
        app_res = app_obj.request(x["request_data"])
        app_req_result = case app_res
        in [:success, result]
          TonSdk::Client::AppRequestResult.new(
            type_: :ok,
            result: result
          )
        in [:error, text]
          TonSdk::Client::AppRequestResult.new(
            type_: :error,
            text: text
          )
        end

        params = TonSdk::Client::ParamsOfResolveAppRequest.new(
          app_request_id: x["app_request_id"],
          result: app_req_result
        )
        TonSdk::Client.resolve_app_request(ctx, params)
      end

      Interop::request_to_native_lib(
        ctx,
        "crypto.register_encryption_box",
        nil,
        client_callback: client_callback,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: RegisteredEncryptionBox.new(resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.encryption_box_get_info(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.encryption_box_get_info", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfEncryptionBoxGetInfo.new(resp.result["info"])
          )
        else
          yield resp
        end
      end
    end

    def self.create_encryption_box(ctx, params)
      Interop::request_to_native_lib(ctx, "crypto.create_encryption_box", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: RegisteredEncryptionBox.new(resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end
  end
end
