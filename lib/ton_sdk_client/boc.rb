module TonSdk
  module Boc

    #
    # types
    #

    ParamsOfParse = Struct.new(:boc, keyword_init: true)
    ResultOfParse = Struct.new(:parsed)
    ParamsOfParseShardstate = Struct.new(:boc, :id, :workchain_id, keyword_init: true)
    ParamsOfGetBlockchainConfig = Struct.new(:block_boc)
    ResultOfGetBlockchainConfig = Struct.new(:config_boc)

    ParamsOfGetBocHash = Struct.new(:boc)
    ResultOfGetBocHash = Struct.new(:hash)

    ParamsOfGetBocDepth = Struct.new(:boc, keyword_init: true)
    ResultOfGetBocDepth = Struct.new(:depth)

    ParamsOfGetCodeFromTvc = Struct.new(:hash)
    ResultOfGetCodeFromTvc = Struct.new(:code)
    ParamsOfBocCacheGet = Struct.new(:boc_ref)

    ResultOfBocCacheGet = Struct.new(:boc)

    class BocCacheType
      private_class_method :new

      attr_reader :type_, :pin

      def self.new_with_type_pinned(pin)
        @type_ = :pinned
        @pin = pin
      end

      def self.new_with_type_unpinned
        @type_ = :unpinned
      end

      def to_h
        h1 = {
          type: Helper.sym_to_capitalized_case_str(@type_)
        }

        h2 = if @type_ == :pinned
          {
            pin: @pin
          }
        else
          { }
        end

        h1.merge(h2)
      end
    end

    ParamsOfBocCacheSet = Struct.new(:boc, :cache_type) do
      def to_h
        {
          boc: @boc,
          cache_type: @cache_type.to_h
        }
      end
    end

    ResultOfBocCacheSet = Struct.new(:boc_ref)
    ParamsOfBocCacheUnpin = Struct.new(:boc, :boc_ref)
    ParamsOfEncodeBoc = Struct.new(:builder, :boc_cache)
    ResultOfEncodeBoc = Struct.new(:boc)

    ParamsOfGetCodeSalt = Struct.new(:code, :boc_cache, keyword_init: true) do
      def to_h
        {
          code: code,
          boc_cache: boc_cache&.to_h
        }
      end
    end

    ResultOfGetCodeSalt = Struct.new(:salt)

    ParamsOfSetCodeSalt = Struct.new(:code, :salt, :boc_cache, keyword_init: true) do
      def to_h
        {
          code: code,
          salt: salt,
          boc_cache: boc_cache&.to_h
        }
      end
    end

    ResultOfSetCodeSalt = Struct.new(:code)

    ParamsOfDecodeTvc = Struct.new(:tvc, :boc_cache, keyword_init: true) do
      def to_h
        {
          tvc: tvc,
          boc_cache: boc_cache&.to_h
        }
      end
    end

    ResultOfDecodeTvc = Struct.new(
      :code,
      :code_hash,
      :code_depth,
      :data,
      :data_hash,
      :data_depth,
      :library,
      :tick,
      :tock,
      :split_depth,
      :compiler_version,
      keyword_init: true
    )

    ParamsOfEncodeTvc = Struct.new(
      :code,
      :data,
      :library,
      :tick,
      :tock,
      :split_depth,
      :boc_cache,
      keyword_init: true
    ) do
      def to_h
        {
          code: code,
          data: data,
          library: library,
          tick: tick,
          tock: tock,
          split_depth: split_depth,
          boc_cache: boc_cache&.to_h
        }
      end
    end

    ResultOfEncodeTvc = Struct.new(:tvc)

    ParamsOfGetCompilerVersion = Struct.new(:code, keyword_init: true)

    ResultOfGetCompilerVersion = Struct.new(:version)

    #
    # functions
    #

    def self.parse_message(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.parse_message", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfParse.new(resp.result["parsed"])
          )
        else
          yield resp
        end
      end
    end

    def self.parse_transaction(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.parse_transaction", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfParse.new(resp.result["parsed"])
          )
        else
          yield resp
        end
      end
    end

    def self.parse_account(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.parse_account", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfParse.new(resp.result["parsed"])
          )
        else
          yield resp
        end
      end
    end

    def self.parse_block(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.parse_block", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfParse.new(resp.result["parsed"])
          )
        else
          yield resp
        end
      end
    end

    def self.parse_shardstate(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.parse_shardstate", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfParse.new(resp.result["parsed"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_boc_hash(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.get_boc_hash", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGetBocHash.new(resp.result["hash"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_blockchain_config(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.get_blockchain_config", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGetBlockchainConfig.new(
              resp.result["config_boc"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.get_boc_depth(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.get_boc_depth", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGetBocDepth.new(
              resp.result["depth"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.get_code_from_tvc(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.get_code_from_tvc", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGetCodeFromTvc.new(resp.result["code"])
          )
        else
          yield resp
        end
      end
    end

    def self.cache_get(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.cache_get", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfBocCacheGet.new(
              boc: resp.result["boc"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.cache_set(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.cache_set", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfBocCacheSet.new(
              boc_ref: resp.result["boc_ref"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.cache_unpin(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.cache_unpin", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end

    def self.encode_boc(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.encode_boc", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfEncodeBoc.new(
              resp.result["boc"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.get_code_salt(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.get_code_salt", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGetCodeSalt.new(
              resp.result["salt"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.set_code_salt(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.set_code_salt", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfSetCodeSalt.new(
              resp.result["code"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.decode_tvc(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.decode_tvc", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfDecodeTvc.new(
              code: resp.result["code"],
              code_depth: resp.result["code_depth"],
              code_hash: resp.result["code_hash"],
              data: resp.result["data"],
              data_depth: resp.result["data_depth"],
              data_hash: resp.result["data_hash"],
              library: resp.result["library"],
              tick: resp.result["tick"],
              tock: resp.result["tock"],
              split_depth: resp.result["split_depth"],
              compiler_version: resp.result["compiler_version"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.encode_tvc(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.encode_tvc", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfEncodeTvc.new(
              resp.result["tvc"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.get_compiler_version(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.get_compiler_version", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGetCompilerVersion.new(
              resp.result["version"]
            )
          )
        else
          yield resp
        end
      end
    end
  end
end
