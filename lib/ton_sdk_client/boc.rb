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

    class ParamsOfBocCacheGet
      attr_reader :boc_ref

      def initialize(a)
        @boc_ref = a
      end

      def to_h = { boc_ref: @boc_ref }
    end

    class ResultOfBocCacheGet
      attr_reader :boc

      def initialize(a)
        @boc = a
      end
    end

    class BocCacheType
      TYPES = [
        :pinned,
        :unpinned
      ]
      attr_reader :type_, :pin

      def initialize(type_:, pin:)
        unless TYPES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end
        @type_ = type_
        @pin = pin
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

    class ParamsOfBocCacheSet
      attr_reader :boc, :cache_type

      def initialize(boc:, cache_type:)
        @boc = boc
        @cache_type = cache_type
      end

      def to_h
        {
          boc: @boc,
          cache_type: @cache_type.to_h
        }
      end
    end

    class ResultOfBocCacheGet
      attr_reader :boc_ref

      def initialize(a)
        @boc_ref = a
      end
    end

    class ParamsOfBocCacheUnpin
      attr_reader :boc, :boc_ref

      def initialize(boc:, boc_ref:)
        @boc = boc
        @boc_ref = boc_ref
      end

      def to_h
        {
          boc: @boc,
          boc_ref: @boc_ref
        }
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
  end
end