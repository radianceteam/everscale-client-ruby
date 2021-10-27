module TonSdk
  module Boc

    #
    # types
    #

    ParamsOfParse = KwStruct.new(:boc)
    ResultOfParse = KwStruct.new(:parsed)
    ParamsOfParseShardstate = KwStruct.new(:boc, :id, :workchain_id)
    ParamsOfGetBlockchainConfig = KwStruct.new(:block_boc)
    ResultOfGetBlockchainConfig = KwStruct.new(:config_boc)

    ParamsOfGetBocHash = KwStruct.new(:boc)
    ResultOfGetBocHash = KwStruct.new(:hash)

    ParamsOfGetBocDepth = KwStruct.new(:boc)
    ResultOfGetBocDepth = KwStruct.new(:depth)

    ParamsOfGetCodeFromTvc = KwStruct.new(:hash)
    ResultOfGetCodeFromTvc = KwStruct.new(:code)
    ParamsOfBocCacheGet = KwStruct.new(:boc_ref)

    ResultOfBocCacheGet = KwStruct.new(:boc)

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

    ParamsOfBocCacheSet = KwStruct.new(:boc, :cache_type) do
      def to_h
        {
          boc: @boc,
          cache_type: @cache_type.to_h
        }
      end
    end

    ResultOfBocCacheSet = KwStruct.new(:boc_ref)
    ParamsOfBocCacheUnpin = KwStruct.new(:boc, :boc_ref)
    ParamsOfEncodeBoc = KwStruct.new(:builder, :boc_cache)
    ResultOfEncodeBoc = KwStruct.new(:boc)

    ParamsOfGetCodeSalt = KwStruct.new(:code, :boc_cache) do
      def to_h
        {
          code: code,
          boc_cache: boc_cache&.to_h
        }
      end
    end

    ResultOfGetCodeSalt = KwStruct.new(:salt)

    ParamsOfSetCodeSalt = KwStruct.new(:code, :salt, :boc_cache) do
      def to_h
        {
          code: code,
          salt: salt,
          boc_cache: boc_cache&.to_h
        }
      end
    end

    ResultOfSetCodeSalt = KwStruct.new(:code)

    ParamsOfDecodeTvc = KwStruct.new(:tvc, :boc_cache) do
      def to_h
        {
          tvc: tvc,
          boc_cache: boc_cache&.to_h
        }
      end
    end

    ResultOfDecodeTvc = KwStruct.new(
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
      :compiler_version
    )

    ParamsOfEncodeTvc = KwStruct.new(
      :code,
      :data,
      :library,
      :tick,
      :tock,
      :split_depth,
      :boc_cache
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

    ResultOfEncodeTvc = KwStruct.new(:tvc)

    ParamsOfGetCompilerVersion = KwStruct.new(:code)

    ResultOfGetCompilerVersion = KwStruct.new(:version)

    #
    # functions
    #

    def self.parse_message(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.parse_message", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfParse.new(parsed: resp.result["parsed"])
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
            result: ResultOfParse.new(parsed: resp.result["parsed"])
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
            result: ResultOfParse.new(parsed: resp.result["parsed"])
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
            result: ResultOfParse.new(parsed: resp.result["parsed"])
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
            result: ResultOfParse.new(parsed: resp.result["parsed"])
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
            result: ResultOfGetBocHash.new(hash: resp.result["hash"])
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
              config_boc: resp.result["config_boc"]
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
              depth: resp.result["depth"]
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
            result: ResultOfGetCodeFromTvc.new(code: resp.result["code"])
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
              boc: resp.result["boc"]
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
              salt: resp.result["salt"]
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
              code: resp.result["code"]
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
              tvc: resp.result["tvc"]
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
              version: resp.result["version"]
            )
          )
        else
          yield resp
        end
      end
    end
  end
end
