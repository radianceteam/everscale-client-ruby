require 'spec_helper'
require 'json'

describe TonSdk::Tvm do
  context "methods of tvm" do
    it "#run_get" do
      account = File.read(File.join(TESTS_DATA_DIR, "tvm", "encoded_account.txt"))

      # 1
      elector_address = "-1:3333333333333333333333333333333333333333333333333333333333333333"
      input1 = elector_address.split(":")[1]

      pr1 = TonSdk::Tvm::ParamsOfRunGet.new(
        account: account,
        function_name: "compute_returned_stake",
        input:  "0x#{input1}"
      )

      TonSdk::Tvm.run_get(@c_ctx.context, pr1) { |a| @res1 = a }
      now = get_now_for_async_operation()
      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res1 || now >= timeout_at

      expect(@res1.success?).to eq true
      expect(@res1.result.output[0]).to eq "0"


      # 2
      pr2 = TonSdk::Tvm::ParamsOfRunGet.new(
        account: account,
        function_name: "past_elections"
      )

      TonSdk::Tvm.run_get(@c_ctx.context, pr2) { |a| @res2 = a }
      now = get_now_for_async_operation()
      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res2 || now >= timeout_at

      expect(@res2.success?).to eq true
      expect(@res2.result.output[0][0][0]).to eq "1588268660"
    end
  end
end