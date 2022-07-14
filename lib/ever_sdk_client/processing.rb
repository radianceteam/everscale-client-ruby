module EverSdk
  module Processing
    #
    # types
    #

    module ErrorCode
      MESSAGE_ALREADY_EXPIRED = 501
      MESSAGE_HAS_NOT_DESTINATION_ADDRESS = 502
      CAN_NOT_BUILD_MESSAGE_CELL = 503
      FETCH_BLOCK_FAILED = 504
      SEND_MESSAGE_FAILED = 505
      INVALID_MESSAGE_BOC = 506
      MESSAGE_EXPIRED = 507
      TRANSACTION_WAIT_TIMEOUT = 508
      INVALID_BLOCK_RECEIVED = 509
      CAN_NOT_CHECK_BLOCK_SHARD = 510
      BLOCK_NOT_FOUND = 511
      INVALID_DATA = 512
      EXTERNAL_SIGNER_MUST_NOT_BE_USED = 513
      MESSAGE_REJECTED = 514
      INVALID_REMP_STATUS = 515
      NEXT_REMP_STATUS_TIMEOUT = 516
    end

    class ParamsOfSendMessage
      attr_reader :message, :abi, :send_events

      def initialize(message:, abi: nil, send_events:)
        @message = message
        @abi = abi
        @send_events = send_events
      end

      def to_h
        {
          message: message,
          abi: abi&.to_h,
          send_events: send_events
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
          abi: abi&.to_h,
          message: message,
          shard_block_id: shard_block_id,
          send_events: send_events
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
          transaction: transaction,
          out_messages: out_messages,
          decoded: decoded,
          fees: fees
        }
      end
    end

    class ProcessingEvent
      TYPES = %i[
        will_fetch_first_block
        fetch_first_block_failed
        will_send
        did_send
        send_failed
        will_fetch_next_block
        fetch_next_block_failed
        message_expired
        remp_sent_to_validators
        remp_included_into_block
        remp_included_into_accepted_block
        remp_other
        remp_error
      ]

      attr_reader :type_, :error, :shard_block_id, :message_id, :message, :args

      def initialize(type_:, error: nil, shard_block_id: nil, message_id: nil, message: nil, **args)
        unless TYPES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end
        @type_ = type_
        @error = error
        @shard_block_id = shard_block_id
        @message_id = message_id
        @message = message
        @args = args
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
             when :remp_sent_to_validators, :remp_included_into_block, :remp_included_into_accepted_block, :remp_other, :remp_error
               {
                 message_id: message_id,
                 timestamp: args[:timestamp],
                 json: args[:json]
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
      def initialize(message_encode_params:, send_events:)
        super
      end

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
              decoded: DecodedOutput.new(
                out_messages: resp.result.dig("decoded", "out_messages"),
                output: resp.result.dig("decoded", "output")
              ),
              fees: Tvm::TransactionFees.new(**resp.result["fees"].transform_keys(&:to_sym))
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
              decoded: DecodedOutput.new(
                out_messages: resp.result.dig("decoded", "out_messages"),
                output: resp.result.dig("decoded", "output")
              ),
              fees: Tvm::TransactionFees.new(**resp.result["fees"].transform_keys(&:to_sym))
            )
          )
        else
          yield resp
        end
      end
    end
  end
end
