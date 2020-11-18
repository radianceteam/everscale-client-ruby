module TonSdk
  module Tvm
    class ExecutionOptions
      attr_reader :blockchain_config, :block_time, :block_lt, :transaction_lt

      def initialize(blockchain_config: nil, block_time: nil, block_lt: nil, transaction_lt: nil)
        @blockchain_config = blockchain_config
        @block_time = block_time
        @block_lt = block_lt
        @transaction_lt = transaction_lt
      end
    end

    class AccountForExecutor
      TYPES = [:none, :uninit, :account]
      attr_reader :type_, :boc, :unlimited_balance

      def initialize(type_:, boc: nil, unlimited_balance: nil)
        unless TYPES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end

        @type_ = type_
        @boc = boc
        @unlimited_balance = unlimited_balance
      end

      def to_h
        case @type_
        when :none
          {
            type: Helper.sym_to_capitalized_camel_case_str(@type_),
          }
        when :uninit
          {
            type: Helper.sym_to_capitalized_camel_case_str(@type_),
          }
        when :account
          {
            type: Helper.sym_to_capitalized_camel_case_str(@type_),
            boc: @boc,
            unlimited_balance: @unlimited_balance
          }
        end
      end
    end

    class ParamsOfRunExecutor
      attr_reader :message, :account, :execution_options, :abi, :skip_transaction_check

      def initialize(message: , account: , execution_options: nil, abi: nil, skip_transaction_check: nil)
        @message = message
        @account = account
        @execution_options = execution_options
        @abi = abi
        @skip_transaction_check = skip_transaction_check
      end

      def to_h
        abi_val = @abi.nil? ? nil : @abi.to_h
        exe_opt_val = @execution_options.nil? ? nil : @execution_options.to_h

        {
          message: @message,
          account: @account.to_h,
          execution_options: exe_opt_val,
          abi: abi_val,
          skip_transaction_check: @skip_transaction_check
        }
      end
    end

    class ResultOfRunExecutor
      attr_reader :transaction, :out_messages, :decoded, :account, :fees

      def initialize(transaction:, out_messages:, decoded: nil, account:, fees:)
        @transaction = transaction
        @out_messages = out_messages
        @decoded = decoded
        @account = account
        @fees = fees
      end
    end

    class ParamsOfRunTvm
      attr_reader :message, :account, :execution_options, :abi

      def initialize(message: , account: , execution_options: nil, abi: nil)
        @message = message
        @account = account
        @execution_options = execution_options
        @abi = abi
      end

      def to_h
        abi_val = @abi.nil? ? nil : @abi.to_h
        exe_opt_val = @execution_options.nil? ? nil : @execution_options.to_h

        {
          message: @message,
          account: @account,
          execution_options: exe_opt_val,
          abi: abi_val
        }
      end
    end

    class ResultOfRunTvm
      attr_reader :out_messages, :decoded, :account

      def initialize(out_messages: , decoded: nil, account:)
        @out_messages = out_messages
        @decoded = decoded
        @account = account
      end
    end

    class ParamsOfRunGet
      attr_reader :account, :function_name, :input, :execution_options

      def initialize(account:, function_name:, input: nil, execution_options: nil)
        @account = account
        @function_name = function_name
        @input = input
        @execution_options = execution_options
      end

      def to_h
        exe_opt_val = @execution_options.nil? ? nil : @execution_options.to_h

        {
          account: @account,
          function_name: @function_name,
          input: @input,
          execution_options: exe_opt_val
        }
      end
    end

    class ResultOfRunGet
      attr_reader :output

      def initialize(a)
        @output = a
      end
    end

    class TransactionFees
      attr_reader :in_msg_fwd_fee, :storage_fee, :gas_fee, :out_msgs_fwd_fee,
        :total_account_fees

      def initialize(in_msg_fwd_fee:, storage_fee: , gas_fee:, out_msgs_fwd_fee:,
        total_account_fees:, total_output:
      )
        @in_msg_fwd_fee = in_msg_fwd_fee
        @storage_fee = storage_fee
        @gas_fee = gas_fee
        @out_msgs_fwd_fee = out_msgs_fwd_fee
        @total_account_fees = total_account_fees
        @total_output = total_output
      end

      def to_h
        {
          in_msg_fwd_fee: @in_msg_fwd_fee,
          storage_fee: @storage_fee,
          gas_fee: @gas_fee,
          out_msgs_fwd_fee: @out_msgs_fwd_fee,
          total_account_fees: @total_account_fees,
          total_output: @total_output
        }
      end
    end

    def self.run_executor(ctx, pr)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(
        ctx,
        "tvm.run_executor",
        pr1,
        pr_json,
        single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfRunExecutor.new(
              transaction: resp.result["transaction"],
              out_messages: resp.result["out_messages"],
              decoded: resp.result["decoded"],
              account: resp.result["account"],
              fees: resp.result["fees"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.run_tvm(ctx, pr)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(
        ctx,
        "tvm.run_tvm",
        pr1,
        pr_json,
        single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfRunTvm.new(
              out_messages: resp.result["out_messages"],
              decoded: resp.result["decoded"],
              account: resp.result["account"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.run_get(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(
        ctx,
        "tvm.run_get",
        pr_json,
        single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfRunGet.new(resp.result["output"])
          )
        else
          yield resp
        end
      end
    end
  end
end