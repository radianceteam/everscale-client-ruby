module EverSdk
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

    ParamsOfQueryCollection = KwStruct.new(:collection, :filter, :result, :order, :limit) do
      def initialize(collection: , filter: nil, result: , order: [], limit: nil)
        super
      end

      def to_h
        h = super
        ord_h_s = if !self.order.nil?
          self.order.map do |x|
            {
              path: x.path,
              direction: x.direction.to_s.upcase
            }
          end
        end

        h[:order] = ord_h_s
        h
      end
    end

    ResultOfQueryCollection = KwStruct.new(:result)
    ResultOfWaitForCollection = KwStruct.new(:result)
    ResultOfQuery = KwStruct.new(:result)
    ResultOfBatchQuery = KwStruct.new(:results)
    ParamsOfWaitForCollection = KwStruct.new(:collection, :filter, :result, :timeout) do
      def initialize(collection:, filter: nil, result:, timeout: nil)
        super
      end
    end

    ParamsOfSubscribeCollection = KwStruct.new(:collection, :filter, :result) do
      def initialize(collection:, filter: nil, result:)
        super
      end
    end

    ParamsOfSubscribe = KwStruct.new(:subscription, :variables)

    ResultOfSubscribeCollection = KwStruct.new(:handle)

    ParamsOfQuery = KwStruct.new(:query, :variables) do
      def initialize(query:, variables: nil)
        super
      end
    end

    ParamsOfFindLastShardBlock = KwStruct.new(:address)
    ResultOfFindLastShardBlock = KwStruct.new(:block_id)
    EndpointsSet = KwStruct.new(:endpoints)

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

      def self.new_with_type_query_counterparties(params)
        @type_ = :query_counterparties
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

    ParamsOfBatchQuery = KwStruct.new(:operations) do
      def to_h
        {
          operations: self.operations.compact.map(&:to_h)
        }
      end
    end

    ParamsOfAggregateCollection = KwStruct.new(:collection, :filter, :fields) do
      def initialize(collection:, filter: nil, fields: [])
        super
      end

      def to_h
        h = super
        h[:fields] = fields.map(&:to_h)
        h
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

    ResultOfAggregateCollection = KwStruct.new(:values)

    ParamsOfQueryCounterparties = KwStruct.new(:account, :result, :first, :after) do
      def initialize(account:, result:, first: nil, after: nil)
        super
      end
    end

    ResultOfGetEndpoints = KwStruct.new(:query, :endpoints)

    TransactionNode = KwStruct.new(
      :id_,
      :in_msg,
      :out_msgs,
      :account_addr,
      :total_fees,
      :aborted,
      :exit_code
    ) do
      def initialize(id_:, in_msg:, out_msgs:, account_addr:, total_fees:, aborted:, exit_code: nil)
        super
      end
    end

    MessageNode = KwStruct.new(
      :id_,
      :src_transaction_id,
      :dst_transaction_id,
      :src,
      :dst,
      :value,
      :bounce,
      :decoded_body
    ) do
      def initialize(
        id_:,
        src_transaction_id: nil,
        dst_transaction_id: nil,
        src: nil,
        dst: nil,
        value: nil,
        bounce:,
        decoded_body: nil
      )
        super
      end
    end

    ParamsOfQueryTransactionTree = KwStruct.new(:in_msg, :abi_registry, :timeout) do
      def initialize(in_msg:, abi_registry: [], timeout: nil)
        super
      end

      def to_h
        h = super
        h[:abi_registry] = abi_registry&.map(&:to_h)
        h
      end
    end
    ResultOfQueryTransactionTree = KwStruct.new(:messages, :transactions)

    ParamsOfCreateBlockIterator = KwStruct.new(:start_time, :end_time, :shard_filter, :result)
    RegisteredIterator = KwStruct.new(:handle)
    ParamsOfResumeBlockIterator = KwStruct.new(:resume_state)
    ParamsOfCreateTransactionIterator = KwStruct.new(:start_time, :end_time, :shard_filter, :accounts_filter, :result, :include_transfers)
    ParamsOfResumeTransactionIterator = KwStruct.new(:resume_state, :accounts_filter) do
      def initialize(resume_state:, accounts_filter: nil)
        super
      end
    end
    ParamsOfIteratorNext = KwStruct.new(:iterator, :limit, :return_resume_state) do
      def initialize(iterator:, limit: nil, return_resume_state: nil)
        super
      end
    end
    ResultOfIteratorNext = KwStruct.new(:items, :has_more, :resume_state) do
      def initialize(items: [], has_more:, resume_state: nil)
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
          yield NativeLibResponseResult.new(
            result: ResultOfQueryCollection.new(result: resp.result["result"])
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
          yield NativeLibResponseResult.new(
            result: ResultOfWaitForCollection.new(result: resp.result["result"])
          )
        else
          yield resp
        end
      end
    end

    def self.unsubscribe(ctx, params)
      Interop::request_to_native_lib(ctx, "net.unsubscribe", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
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
          yield NativeLibResponseResult.new(
            result: ResultOfSubscribeCollection.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.subscribe(ctx, params, client_callback: nil)
      Interop::request_to_native_lib(
        ctx,
        "net.subscribe",
        params,
        client_callback: client_callback,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfSubscribeCollection.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.query(ctx, params)
      Interop::request_to_native_lib(ctx, "net.query", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfQuery.new(result: resp.result["result"])
          )
        else
          yield resp
        end
      end
    end

    def self.suspend(ctx)
      Interop::request_to_native_lib(ctx, "net.suspend") do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(result: "")
        else
          yield resp
        end
      end
    end

    def self.resume(ctx)
      Interop::request_to_native_lib(ctx, "net.resume") do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(result: "")
        else
          yield resp
        end
      end
    end

    def self.find_last_shard_block(ctx, params)
      Interop::request_to_native_lib(ctx, "net.find_last_shard_block", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfFindLastShardBlock.new(block_id: resp.result["block_id"])
          )
        else
          yield resp
        end
      end
    end

    def self.fetch_endpoints(ctx)
      Interop::request_to_native_lib(ctx, "net.fetch_endpoints") do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: EndpointsSet.new(endpoints: resp.result["endpoints"])
          )
        else
          yield resp
        end
      end
    end

    def self.set_endpoints(ctx, params)
      Interop::request_to_native_lib(ctx, "net.set_endpoints", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end

    def self.batch_query(ctx, params)
      Interop::request_to_native_lib(ctx, "net.batch_query", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfBatchQuery.new(results: resp.result["results"])
          )
        else
          yield resp
        end
      end
    end

    def self.aggregate_collection(ctx, params)
      Interop::request_to_native_lib(ctx, "net.aggregate_collection", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfAggregateCollection.new(values: resp.result["values"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_endpoints(ctx)
      Interop::request_to_native_lib(ctx, "net.get_endpoints") do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfGetEndpoints.new(
              query: resp.result["query"],
              endpoints: resp.result["endpoints"],
            )
          )
        else
          yield resp
        end
      end
    end

    def self.query_counterparties(ctx, params)
      Interop::request_to_native_lib(ctx, "net.query_counterparties", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfQueryCollection.new(result: resp.result["result"])
          )
        else
          yield resp
        end
      end
    end

    def self.query_transaction_tree(ctx, params)
      Interop::request_to_native_lib(ctx, "net.query_transaction_tree", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfQueryTransactionTree.new(
              messages: resp.result["messages"],
              transactions: resp.result["transactions"],
            )
          )
        else
          yield resp
        end
      end
    end

    def self.create_block_iterator(ctx, params)
      Interop::request_to_native_lib(ctx, "net.create_block_iterator", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: RegisteredIterator.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.resume_block_iterator(ctx, params)
      Interop::request_to_native_lib(ctx, "net.resume_block_iterator", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: RegisteredIterator.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.create_transaction_iterator(ctx, params)
      Interop::request_to_native_lib(ctx, "net.create_transaction_iterator", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: RegisteredIterator.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.resume_transaction_iterator(ctx, params)
      Interop::request_to_native_lib(ctx, "net.resume_transaction_iterator", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: RegisteredIterator.new(handle: resp.result["handle"])
          )
        else
          yield resp
        end
      end
    end

    def self.iterator_next(ctx, params)
      Interop::request_to_native_lib(ctx, "net.iterator_next", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfIteratorNext.new(
              items: resp.result["items"],
              has_more: resp.result["has_more"],
              resume_state: resp.result["resume_state"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.remove_iterator(ctx, params)
      Interop::request_to_native_lib(ctx, "net.remove_iterator", params) do |resp|
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
