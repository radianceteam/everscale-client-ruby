module TonSdk
  module Boc

    #
    # types
    #

    ParamsOfParse = Struct.new(:boc) do
      def to_h = { boc: @boc }
    end

    ResultOfParse = Struct.new(:parsed)

    ParamsOfParseShardstate = Struct.new(:boc, :id, :workchain_id) do
      def to_h
        {
          boc: @boc,
          id: @id_,
          workchain_id: @workchain_id
        }
      end
    end

    ParamsOfGetBlockchainConfig = Struct.new(:block_boc) do
      def to_h = { block_boc: @block_boc }
    end

    ResultOfGetBlockchainConfig = Struct.new(:config_boc)

    ParamsOfGetBocHash = Struct.new(:boc) do
      def to_h
        {
          boc: @boc
        }
      end
    end

    ResultOfGetBocHash = Struct.new(:hash)

    ParamsOfGetCodeFromTvc = Struct.new(:hash) do
      def to_h = { tvc: @tvc }
    end

    ResultOfGetCodeFromTvc = Struct.new(:code)

    ParamsOfBocCacheGet = Struct.new(:boc_ref) do
      def to_h = { boc_ref: @boc_ref }
    end

    ResultOfBocCacheGet = Struct.new(:boc) do

    class BocCacheType
      TYPES = [
        :pinned,
        :unpinned
      ]

      attr_reader :type_, :pin

      def new_with_type_pinned(pin)
        @type_ = :pinned
        @pin = pin
      end

      def new_with_type_unpinned
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

    ResultOfBocCacheGet = Struct.new(:boc_ref)

    ParamsOfBocCacheUnpin = Struct.new(:boc, :boc_ref) do
      def to_h
        {
          boc: @boc,
          boc_ref: @boc_ref
        }
      end
    end

    ParamsOfEncodeBoc = Struct.new(:builder, :boc_cache) do
      def to_h
        {
          boc: @boc,
          boc_ref: @boc_ref
        }
      end
    end

    ResultOfEncodeBoc = Struct.new(:boc)

    ParamsOfGetBlockchainConfig = Struct.new(:block_boc) do
      def to_h = { block_boc: @block_boc }
    end

    ResultOfGetBlockchainConfig = Struct.new(:config_boc)


    #
    # functions
    #

    def self.parse_message(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.parse_message", params.to_h.to_json) do |resp|
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
      Interop::request_to_native_lib(ctx, "boc.parse_transaction", params.to_h.to_json) do |resp|
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
      Interop::request_to_native_lib(ctx, "boc.parse_account", params.to_h.to_json) do |resp|
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
      Interop::request_to_native_lib(ctx, "boc.parse_block", params.to_h.to_json) do |resp|
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
      Interop::request_to_native_lib(ctx, "boc.parse_shardstate", params.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfParse.new(resp.result["parsed"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_blockchain_config(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.get_blockchain_config", params.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGetBlockchainConfig.new(resp.result["config_boc"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_boc_hash(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.get_boc_hash", params.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGetBocHash.new(resp.result["hash"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_code_from_tvc(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.get_code_from_tvc", params.to_h.to_json) do |resp|
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
      Interop::request_to_native_lib(ctx, "boc.cache_get", params.to_h.to_json) do |resp|
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
      Interop::request_to_native_lib(ctx, "boc.cache_set", params.to_h.to_json) do |resp|
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
      Interop::request_to_native_lib(ctx, "boc.cache_unpin", params.to_h.to_json) do |resp|
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
      Interop::request_to_native_lib(ctx, "boc.encode_boc", params.to_h.to_json) do |resp|
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

    def self.get_blockchain_config(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.get_blockchain_config", params.to_h.to_json) do |resp|
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
  end
end