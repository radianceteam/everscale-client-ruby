module TonSdk
  module Processing

    #
    # types
    #

    class ParamsOfSendMessage
      attr_reader :message, :abi, :send_events

      def initialize(message:, abi: nil, send_events:)
        @message = message
        @abi = abi
        @send_events = send_events
      end

      def to_h
        {
          message: @message,
          abi: @abi.nil? ? nil : @abi.to_h,
          send_events: @send_events
        }
      end
    end

    ResultOfSendMessage = KwStruct.new(:shard_block_id)

    class ParamsOfWaitForTransaction
      attr_reader :abi, :message, :shard_block_id, :send_events

      def initialize(abi: nil, message:, shard_block_id:, send_events:)
        @abi = abi
        @message = message
        @shard_block_id = shard_block_id
        @send_events = send_events
      end

      def to_h
        {
          abi: @abi.nil? ? nil : @abi.to_h,
          message: @message,
          shard_block_id: @shard_block_id,
          send_events: @send_events
        }
      end
    end

    class ResultOfProcessMessage
      attr_reader :transaction, :out_messages, :decoded, :fees

      def initialize(transaction:, out_messages:, decoded: nil, fees:)
        @transaction = transaction
        @out_messages = out_messages
        @decoded = decoded
        @fees = fees
      end

      def to_h
        {
          transaction: @transaction,
          out_messages: @out_messages,
          decoded: @decoded,
          fees: @fees
        }
      end
    end

    class ProcessingEvent
      TYPES = [
        :will_fetch_first_block,
        :fetch_first_block_failed,
        :will_send,
        :did_send,
        :send_failed,
        :will_fetch_next_block,
        :fetch_next_block_failed,
        :message_expired
      ]

      attr_reader :type_, :error, :shard_block_id, :message_id, :message

      def initialize(type_:, error: nil, shard_block_id: nil, message_id: nil, message: nil)
        unless TYPES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end
        @type_ = type_
        @error = error
        @shard_block_id = shard_block_id
        @message_id = message_id
        @message = message
      end

      def to_h
        h1 = {
          type: @type
        }

        h2 = case @type_
        when :will_fetch_first_block
          { }
        when :fetch_first_block_failed
          { 
            error: @error
          }
        when :will_send, :did_send, :will_fetch_next_block
          {
            shard_block_id: @shard_block_id,
            message_id: @message_id,
            message: @message
          }
        when :send_failed, :fetch_next_block_failed
          {
            shard_block_id: @shard_block_id,
            message_id: @message_id,
            message: @message,
            error: @error
          }
        when :message_expired
          {
            message_id: @message_id,
            message: @message,
            error: @error
          }
        else
          raise ArgumentError.new("unsupported type: #{@type_}")
        end

        h1.merge(h2)
      end
    end

    DecodedOutput = KwStruct.new(:out_messages, :output) do
      def initialize(out_messages:, output: nil)
        super
      end
    end

    ParamsOfProcessMessage = KwStruct.new(:message_encode_params, :send_events) do
      def to_h
        {
          message_encode_params: message_encode_params.to_h,
          send_events: send_events
        }
      end
    end


    #
    # functions
    #

    def self.send_message(ctx, params, client_callback = nil)
      if (params.send_events == true) && client_callback.nil?
        raise ArgumentError.new("with `send_events` set to true, `client_callback` may not be nil")
      end

      Interop::request_to_native_lib(
        ctx,
        "processing.send_message",
        params,
        client_callback: client_callback,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfSendMessage.new(shard_block_id: resp.result["shard_block_id"])
          )
        else
          yield resp
        end
      end
    end

    def self.wait_for_transaction(ctx, params, client_callback = nil)
      if (params.send_events == true) && client_callback.nil?
        raise ArgumentError.new("with `send_events` set to true, `client_callback` may not be nil")
      end

      Interop::request_to_native_lib(
        ctx,
        "processing.wait_for_transaction",
        params,
        client_callback: client_callback,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfProcessMessage.new(
              transaction: resp.result["transaction"],
              out_messages: resp.result["out_messages"],
              decoded: resp.result["decoded"],
              fees: resp.result["fees"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.process_message(ctx, params, client_callback = nil)
      if (params.send_events == true) && client_callback.nil?
        raise ArgumentError.new("with `send_events` set to true `client_callback` may not be nil")
      end

      Interop::request_to_native_lib(
        ctx,
        "processing.process_message",
        params,
        client_callback: client_callback,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfProcessMessage.new(
              transaction: resp.result["transaction"],
              out_messages: resp.result["out_messages"],
              decoded: resp.result["decoded"],
              fees: resp.result["fees"]
            )
          )
        else
          yield resp
        end
      end
    end
  end
end
