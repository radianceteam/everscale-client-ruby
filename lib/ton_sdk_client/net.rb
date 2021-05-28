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
      GRAPHQL_WEBSOCKET_INIT_ERROR = 613
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

      def initialize(collection: , filter: nil, result: , order: [], limit: nil)
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

    ResultOfQueryCollection = Struct.new(:result)
    ResultOfWaitForCollection = Struct.new(:result)
    ResultOfQuery = Struct.new(:result)
    ResultOfBatchQuery = Struct.new(:results)
    ParamsOfWaitForCollection = Struct.new(:collection, :filter, :result, :timeout) do
      def initialize(collection:, filter: nil, result:, timeout: nil)
        super
      end
    end

    ParamsOfSubscribeCollection = Struct.new(:collection, :filter, :result) do
      def initialize(collection:, filter: nil, result:)
        super
      end
    end

    ResultOfSubscribeCollection = Struct.new(:handle)
    ParamsOfQuery = Struct.new(:query, :variables) do
      def initialize(query:, variables: nil)
        super
      end
    end

    ParamsOfFindLastShardBlock = Struct.new(:address)
    ResultOfFindLastShardBlock = Struct.new(:block_id)
    EndpointsSet = Struct.new(:endpoints)

    class ParamsOfQueryOperation
      private_class_method :new

      attr_reader :type_, :params

      def self.new_with_type_query_collection(params)
        @type_ = :query_collection
        @params = params
      end

      def self.new_with_type_wait_for_collection(params)
        @type_ = :wait_for_collection
        @params = params
      end
      
      def self.new_with_type_aggregate_collection(params)
        @type_ = :aggregate_collection
        @params = params
      end

      def to_h
        tp = {
          type: Helper.sym_to_capitalized_case_str(@type_)
        }

        param_keys = @params.to_h
        tp.merge(param_keys)
      end
    end

    ParamsOfBatchQuery = Struct.new(:operations) do
      def to_h
        {
          operations: @operations.compact.map(&:to_h)
        }
      end
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

    ResultOfAggregateCollection = Struct.new(:values)

    ParamsOfQueryCounterparties = Struct.new(:account, :result, :first, :after, keyword_init: true) do
      def initialize(account:, result:, first: nil, after: nil)
        super
      end
    end


    #
    # functions
    #

    def self.query_collection(ctx, params)
      Interop::request_to_native_lib(
        ctx,
        "net.query_collection",
        params,
        is_single_thread_only: false
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
        params,
        is_single_thread_only: false
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
      Interop::request_to_native_lib(ctx, "net.unsubscribe", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ""
          )
        else
          yield resp
        end
      end
    end

    def self.subscribe_collection(ctx, params, client_callback: nil)
      Interop::request_to_native_lib(
        ctx,
        "net.subscribe_collection",
        params,
        client_callback: client_callback,
        is_single_thread_only: false
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
      Interop::request_to_native_lib(ctx, "net.query", params) do |resp|
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
      Interop::request_to_native_lib(ctx, "net.suspend") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(result: "")
        else
          yield resp
        end
      end
    end

    def self.resume(ctx)
      Interop::request_to_native_lib(ctx, "net.resume") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(result: "")
        else
          yield resp
        end
      end
    end

    def self.find_last_shard_block(ctx, params)
      Interop::request_to_native_lib(ctx, "net.find_last_shard_block", params) do |resp|
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
      Interop::request_to_native_lib(ctx, "net.fetch_endpoints") do |resp|
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
      Interop::request_to_native_lib(ctx, "net.set_endpoints", params) do |resp|
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
    Interop::request_to_native_lib(ctx, "net.batch_query", params) do |resp|
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
    Interop::request_to_native_lib(ctx, "net.aggregate_collection", params) do |resp|
      if resp.success?
        yield NativeLibResponsetResult.new(
          result: ResultOfAggregateCollection.new(resp.result["values"])
        )
      else
        yield resp
      end
    end
  end

  def self.query_counterparties(ctx, params)
    Interop::request_to_native_lib(ctx, "net.query_counterparties", params) do |resp|
      if resp.success?
        yield NativeLibResponsetResult.new(
          result: ResultOfQueryCollection.new(resp.result["result"])
        )
      else
        yield resp
      end
    end
  end
end