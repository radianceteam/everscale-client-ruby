module TonSdk
  module Proofs

    #
    # types
    #

    module ErrorCode
      INVALID_DATA = 901
      PROOF_CHECK_FAILED = 902
      INTERNAL_ERROR = 903
      DATA_DIFFERS_FROM_PROVEN = 904
    end

    ParamsOfProofBlockData = KwStruct.new(:block)

    ParamsOfProofTransactionData = KwStruct.new(:transaction)

    #
    # functions
    #

    def self.proof_block_data(ctx, params)
      Interop::request_to_native_lib(ctx, "proofs.proof_block_data", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ""
          )
        else
          yield resp
        end
      end
    end

    def self.proof_transaction_data(ctx, params)
      Interop::request_to_native_lib(ctx, "proofs.proof_transaction_data", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ""
          )
        else
          yield resp
        end
      end
    end
  end
end
