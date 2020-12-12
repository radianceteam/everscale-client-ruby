module TonSdk
  module Net
    class SortDirection
      VALUES = [:asc, :desc]
    end

    class OrderBy
      attr_reader :path, :direction

      def initialize(path:, direction:)
        @path = path
        unless SortDirection::VALUES.include?(direction)
          raise ArgumentError.new("direction #{direction} doesn't exist; existing values: #{SortDirection::VALUES}")
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

      def to_h
        {
          handle: @handle
        }
      end
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



    #
    # methods
    #

    def self.query_collection(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(
        ctx,
        "net.query_collection",
        pr_json,
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

    def self.wait_for_collection(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(
        ctx,
        "net.wait_for_collection",
        pr_json,
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

    def self.unsubscribe(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "net.unsubscribe", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ""
          )
        else
          yield resp
        end
      end
    end

    def self.subscribe_collection(ctx, pr1, custom_response_callback = nil, &block)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(
        ctx,
        "net.subscribe_collection",
        pr_json,
        custom_response_callback: custom_response_callback,
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

    def self.query(ctx, pr_s)
      pr_json = pr_s.to_h.to_json
      Interop::request_to_native_lib(ctx, "net.query", pr_json) do |resp|
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
          yield NativeLibResponsetResult.new(result: nil)
        else
          yield resp
        end
      end
    end

    def self.resume(ctx)
      Interop::request_to_native_lib(ctx, "net.resume") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(result: nil)
        else
          yield resp
        end
      end
    end
  end
end