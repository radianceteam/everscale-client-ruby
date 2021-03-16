module TonSdk
  module Boc

    #
    # types
    #

    class ParamsOfParse
      attr_reader :boc

      def initialize(a)
        @boc = a
      end

      def to_h = { boc: @boc }
    end

    class ResultOfParse
      attr_reader :parsed

      def initialize(a)
        @parsed = a
      end
    end

    class ParamsOfParseShardstate
      attr_reader :boc, :id, :workchain_id

      def initialize(boc:, id_:, workchain_id:)
        @boc = boc
        @id_ = id_
        @workchain_id = workchain_id
      end

      def to_h
        {
          boc: @boc,
          id: @id_,
          workchain_id: @workchain_id
        }
      end
    end

    class ParamsOfGetBlockchainConfig
      attr_reader :block_boc

      def initialize(a)
        @block_boc = a
      end

      def to_h
        {
          block_boc: @block_boc
        }
      end
    end

    class ResultOfGetBlockchainConfig
      attr_reader :config_boc

      def initialize(a)
        @config_boc = a
      end
    end

    class ParamsOfGetBocHash
      attr_reader :boc

      def initialize(a)
        @boc = a
      end

      def to_h
        {
          boc: @boc
        }
      end
    end

    class ResultOfGetBocHash
      attr_reader :hash

      def initialize(a)
        @hash = a
      end
    end

    class ParamsOfGetCodeFromTvc
      attr_reader :tvc

      def initialize(a)
        @tvc = a
      end

      def to_h
        {
          tvc: @tvc
        }
      end
    end

    class ResultOfGetCodeFromTvc
      attr_reader :code

      def initialize(a)
        @code = a
      end
    end

    class ParamsOfEncodeBoc
      attr_reader :builder, :boc_cache

      def initialize(builder:, boc_cache: nil)
        @builder = builder
        @boc_cache = boc_cache
      end

      def to_h
        {
          builder: @builder.to_h,
          boc_cache?: @boc_cache.to_h || nil
        }
      end
    end

    class ResultOfEncodeBoc
      attr_reader :boc

      def initialize(a)
        @boc = a
      end
    end

    class BocCacheType
     attr_reader :type_, :pin

      def new_with_type_pinned(pin: nil)
        @type_ = :pinned
        @pin = pin
      end

      def new_with_type_unpinned
        @type_ = :unpinned
      end
    end

    class BocCacheType
     attr_reader :type_, :pin

      def new_with_type_pinned(pin: nil)
        @type_ = :pinned
        @pin = pin
      end

      def new_with_type_unpinned
        @type_ = :unpinned
      end
    end

    class BuilderOp
     attr_reader :type_, :pin

      def new_with_type_integer(size:, value:)
        @type_ = :integer
        @size = :size
        @value = value
      end

      def new_with_type_bit_string(value:)
        @type_ = :bit_string
        @value = value
      end

      def new_with_type_cell(builder:)
        @type_ = :cell
        @builder = builder
      end

      def new_with_type_cell_boc(boc:)
        @type_ = :cell_boc
        @boc = boc
      end
    end


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


    def self.encode_boc(ctx, params)
      Interop::request_to_native_lib(ctx, "boc.encode_boc", params.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfEncodeBoc.new(resp.result["boc"])
          )
        else
          yield resp
        end
      end
    end
  end
end