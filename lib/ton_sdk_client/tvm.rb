module TonSdk
  module Tvm

    #
    # types
    #

    module ErrorCode
      CANNOT_READ_TRANSACTION = 401
      CANNOT_READ_BLOCKCHAIN_CONFIG = 402
      TRANSACTION_ABORTED = 403
      INTERNAL_ERROR = 404
      ACTION_PHASE_FAILED = 405
      ACCOUNT_CODE_MISSING = 406
      LOW_BALANCE = 407
      ACCOUNT_FROZEN_OR_DELETED = 408
      ACCOUNT_MISSING = 409
      UNKNOWN_EXECUTION_ERROR = 410
      INVALID_INPUT_STACK = 411
      INVALID_ACCOUNT_BOC = 412
      INVALID_MESSAGE_TYPE = 413
      CONTRACT_EXECUTION_ERROR = 414
    end

    ExecutionOptions = KwStruct.new(:blockchain_config, :block_time, :block_lt, :transaction_lt) do
      def initialize(blockchain_config: nil, block_time: nil, block_lt: nil, transaction_lt: nil)
        super
      end
    end

    class AccountForExecutor
      private_class_method :new

      TYPES = [:none, :uninit, :account]
      attr_reader :type_, :boc, :unlimited_balance

      def self.new_with_type_none
        @type_ = :none
      end

      def self.new_with_type_uninit
        @type_ = :uninit
      end

      def self.new_with_type_account(boc:, unlimited_balance: nil)
        @type_ = :account
        @boc = boc
        @unlimited_balance = unlimited_balance
      end

      def to_h
        h1 = case @type_
        when :none, :uninit
          {
            type: Helper.sym_to_capitalized_case_str(@type_),
          }
        when :account
          {
            type: Helper.sym_to_capitalized_case_str(@type_),
            boc: @boc,
            unlimited_balance: @unlimited_balance
          }
        end
      end
    end

    ParamsOfRunExecutor = KwStruct.new(
      :message,
      :account,
      :execution_options,
      :abi,
      :skip_transaction_check,
      :boc_cache,
      :return_updated_account
    ) do
      def initialize(
        message:,
        account:,
        execution_options: nil,
        abi: nil,
        skip_transaction_check: nil,
        boc_cache: nil,
        return_updated_account: nil
      )
        super
      end

      def to_h
        h = super
        h[:account] = self.account.to_h
        h[:execution_options] = self.execution_options&.to_h
        h[:abi] = self.abi&.to_h
        h[:boc_cache] = self.boc_cache&.to_h
        h
      end
    end

    ResultOfRunExecutor = KwStruct.new(:transaction, :out_messages, :decoded, :account, :fees) do
      def initialize(transaction:, out_messages:, decoded: nil, account:, fees:)
        super
      end
    end

    class ParamsOfRunTvm
      attr_reader :message, :account, :execution_options, :abi,
                    :boc_cache, :return_updated_account

      def initialize(message:, account:, execution_options: nil, abi: nil, boc_cache: nil, return_updated_account: nil)
        @message = message
        @account = account
        @execution_options = execution_options
        @abi = abi
        @boc_cache = boc_cache
        @return_updated_account = return_updated_account
      end

      def to_h
        {
          message: @message,
          account: @account,
          execution_options: @execution_options&.to_h,
          abi: @abi&.to_h,
          boc_cache: @boc_cache&.to_h,
          return_updated_account: @return_updated_account
        }
      end
    end

    ResultOfRunTvm = KwStruct.new(:out_messages, :decoded, :account) do
      def initialize(out_messages:, decoded: nil, account:)
        super
      end
    end

    class ParamsOfRunGet
      attr_reader :account, :function_name, :input, :execution_options, :tuple_list_as_array

      def initialize(account:, function_name:, input: nil, execution_options: nil, tuple_list_as_array: nil)
        @account = account
        @function_name = function_name
        @input = input
        @execution_options = execution_options
        @tuple_list_as_array = tuple_list_as_array
      end

      def to_h
        {
          account: @account,
          function_name: @function_name,
          input: @input,
          execution_options: @execution_options&.to_h,
          tuple_list_as_array: @tuple_list_as_array
        }
      end
    end

    ResultOfRunGet = KwStruct.new(:output)

    TransactionFees = KwStruct.new(
      :in_msg_fwd_fee,
      :storage_fee,
      :gas_fee,
      :out_msgs_fwd_fee,
      :total_account_fees,
      :total_output,
      :ext_in_msg_fee,
      :total_fwd_fees,
      :account_fees
    ) do
      def initialize(
        in_msg_fwd_fee:,
        storage_fee:,
        gas_fee:,
        out_msgs_fwd_fee:,
        total_account_fees:,
        total_output:,
        ext_in_msg_fee:,
        total_fwd_fees:,
        account_fees:
      )
        super
      end
    end


    #
    # functions
    #

    def self.run_executor(ctx, params)
      Interop::request_to_native_lib(
        ctx,
        "tvm.run_executor",
        params,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
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

    def self.run_tvm(ctx, params)
      Interop::request_to_native_lib(
        ctx,
        "tvm.run_tvm",
        params,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
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

    def self.run_get(ctx, params)
      Interop::request_to_native_lib(
        ctx,
        "tvm.run_get",
        params,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: ResultOfRunGet.new(output: resp.result["output"])
          )
        else
          yield resp
        end
      end
    end
  end
end
