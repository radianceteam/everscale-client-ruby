module TonSdk
  module Net

    #
    # types
    #

    module ErrorCode
      QUERY_FAILED = 601
      SUBSCRIBE_FAILED = 602
      WAIT_FOR_FAILED = 603
      GET_SUBSCRIPTION_FAILED = 604
      INVALID_SERVER_RESPONSE = 605
      CLOCK_OUT_OF_SYNC = 606
      WAIT_FOR_TIMEOUT = 607
      GRAPHQL_ERROR = 608
      NETWORK_MODULE_SUSPENDED = 609
      WEBSOCKET_DISCONNECTED = 610
      NOT_SUPPORTED = 611
      NO_ENDPOINTS_PROVIDED = 612
      GRAPHQL_WEBSOCKET_INIT_ERROR = 613,
      NETWORK_MODULE_RESUMED = 614
    end

    class OrderBy
      SORT_DIRECTION_VALUES = [:asc, :desc]

      attr_reader :path, :direction

      def initialize(path:, direction:)
        @path = path
        unless SORT_DIRECTION_VALUES.include?(direction)
          raise ArgumentError.new("direction #{direction} doesn't exist; existing values: #{SORT_DIRECTION_VALUES}")
        end

        @direction = direction
      end
    end

    class ParamsOfQueryCollection
      attr_reader :collection, :filter, :result, :order, :limit

      def initialize(collection: , filter: nil, result: , order: nil, limit: nil)
        @collection = collection
        @filter = filter
        @result = result
        @order = order
        @limit = limit
      end

      def to_h
        ord_h_s = if !@order.nil?
          @order.map do |x|
            {
              path: x.path,
              direction: x.direction.to_s.upcase
            }
          end
        end

        {
          collection: @collection,
          filter: @filter,
          result: @result,
          order: ord_h_s,
          limit: @limit
        }
      end
    end

    class ResultOfQueryCollection
      attr_reader :result

      def initialize(a)
        @result = a
      end
    end

    class ParamsOfWaitForCollection
      attr_reader :collection, :filter, :result, :timeout

      def initialize(collection:, filter: nil, result:, timeout: nil)
        @collection = collection
        @filter = filter
        @result = result
        @timeout = timeout
      end

      def to_h
        {
          collection: @collection,
          filter: @filter,
          result: @result,
          timeout: @timeout
        }
      end
    end

    class ResultOfWaitForCollection
      attr_reader :result

      def initialize(a)
        @result = a
      end
    end

    class ParamsOfSubscribeCollection
      attr_reader :collection, :filter, :result

      def initialize(collection:, filter: nil, result:)
        @collection = collection
        @filter = filter
        @result = result
      end

      def to_h
        {
          collection: @collection,
          filter: @filter,
          result: @result
        }
      end
    end

    class ResultOfSubscribeCollection
      attr_reader :handle

      def initialize(a)
        @handle = a
      end

      def to_h = { handle: @handle }
    end

    class ParamsOfQuery
      attr_reader :query, :variables

      def initialize(query:, variables: nil)
        @query = query
        @variables = variables
      end

      def to_h
        {
          query: @query,
          variables: @variables
        }
      end
    end

    class ResultOfQuery
      attr_reader :result

      def initialize(a)
        @result = a
      end
    end

    class ParamsOfFindLastShardBlock
      attr_reader :address

      def initialize(a)
        @address = a
      end

      def to_h = { address: @address }
    end

    class ResultOfFindLastShardBlock
      attr_reader :block_id

      def initialize(a)
        @block_id = a
      end
    end

    class EndpointsSet
      attr_reader :endpoints

      def initialize(a)
        @endpoints = a
      end

      def to_h = { endpoints: @endpoints }
    end

    class ParamsOfBatchQuery
      attr_reader :operations

      def initialize(a)
        @operations = a
      end

      def to_h = { operations: @operations }
    end

    class ResultOfBatchQuery
      attr_reader :results

      def initialize(a)
        @results = a
      end

      def to_h = { results: @results }
    end


    class ParamsOfAggregateCollection
      attr_reader :collection, :filter, :fields

      def initialize(collection:, filter: nil, fields: [])
        @collection = collection
        @filter = filter
        @fields = fields
      end

      def to_h
        {
          collection: @collection,
          filter: @filter,
          fields: @fields.map(&:to_h)
        }
      end
    end

    class FieldAggregation
      AGGREGATION_FN_VALUES = [
        :count,
        :min,
        :max,
        :sum,
        :average
      ]

      attr_reader :field, :fn

      def initialize(field:, fn:)
        unless AGGREGATION_FN_VALUES.include?(fn)
          raise ArgumentError.new("aggregate function #{fn} doesn't exist; existing values: #{AGGREGATION_FN_VALUES}")
        end
        @field = field
        @fn = fn
      end

      def to_h
        {
          field: @field,
          fn: @fn.to_s.upcase
        }
      end
    end

    class ResultOfAggregateCollection
      attr_reader :values

      def initialize(a)
        @values = a
      end

      def to_h = { values: @values }
    end



    #
    # functions
    #

    def self.query_collection(ctx, params)
      Interop::request_to_native_lib(
        ctx,
        "net.query_collection",
        params.to_h.to_json,
        single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfQueryCollection.new(resp.result["result"])
          )
        else
          yield resp
        end
      end
    end

    def self.wait_for_collection(ctx, params)
      Interop::request_to_native_lib(
        ctx,
        "net.wait_for_collection",
        params.to_h.to_json,
        single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfWaitForCollection.new(resp.result["result"])
          )
        else
          yield resp
        end
      end
    end

    def self.unsubscribe(ctx, params)
      Interop::request_to_native_lib(ctx, "net.unsubscribe", params.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ""
          )
        else
          yield resp
        end
      end
    end

    def self.subscribe_collection(ctx, params, custom_response_handler = nil, &block)
      Interop::request_to_native_lib(
        ctx,
        "net.subscribe_collection",
        params.to_h.to_json,
        custom_response_handler: custom_response_handler,
        single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfSubscribeCollection.new(resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.query(ctx, params)
      Interop::request_to_native_lib(ctx, "net.query", params.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfQuery.new(resp.result["result"])
          )
        else
          yield resp
        end
      end
    end

    def self.suspend(ctx)
      Interop::request_to_native_lib(ctx, "net.suspend", "") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(result: "")
        else
          yield resp
        end
      end
    end

    def self.resume(ctx)
      Interop::request_to_native_lib(ctx, "net.resume", "") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(result: "")
        else
          yield resp
        end
      end
    end

    def self.find_last_shard_block(ctx, params)
      Interop::request_to_native_lib(ctx, "net.find_last_shard_block", params.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfFindLastShardBlock.new(resp.result["block_id"])
          )
        else
          yield resp
        end
      end
    end

    def self.fetch_endpoints(ctx)
      Interop::request_to_native_lib(ctx, "net.fetch_endpoints", nil) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: EndpointsSet.new(resp.result["endpoints"])
          )
        else
          yield resp
        end
      end
    end

    def self.set_endpoints(ctx, params)
      Interop::request_to_native_lib(ctx, "net.set_endpoints", params.to_h.to_json) do |resp|
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

  def self.batch_query(ctx, params)
    Interop::request_to_native_lib(ctx, "net.batch_query", params.to_h.to_json) do |resp|
      if resp.success?
        yield NativeLibResponsetResult.new(
          result: ResultOfBatchQuery.new(resp.result["results"])
        )
      else
        yield resp
      end
    end
  end

  def self.aggregate_collection(ctx, params)
    Interop::request_to_native_lib(ctx, "net.aggregate_collection", params.to_h.to_json) do |resp|
      if resp.success?
        yield NativeLibResponsetResult.new(
          result: ResultOfAggregateCollection.new(resp.result["values"])
        )
      else
        yield resp
      end
    end
  end
end