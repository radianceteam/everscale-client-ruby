require 'spec_helper'

describe TonSdk::Processing do
  context "methods of processing" do
    it "wait for message" do
      cont_json = File.read("#{TESTS_DATA_DIR}/contracts/abi_v2/Events.abi.json")
      abi1 = TonSdk::Abi::Abi.new(
        type_: :contract,
        value: TonSdk::Abi::AbiContract.from_json(JSON.parse(cont_json))
      )

      tvc1_cont_bin = IO.binread("#{TESTS_DATA_DIR}/contracts/abi_v2/Events.tvc")
      tvc1 = Base64::strict_encode64(tvc1_cont_bin)

      keys = TonSdk::Crypto::KeyPair.new(
        public_: "4c7c408ff1ddebb8d6405ee979c716a14fdd6cc08124107a61d3c25597099499",
        secret: "cc8929d635719612a9478b9cd17675a39cfad52d8959e8a177389b8c0b9122a7"
      )

      pr_s1 = TonSdk::Abi::ParamsOfEncodeMessage.new(
        abi: abi1,
        deploy_set: TonSdk::Abi::DeploySet.new(
          tvc: tvc1
        ),
        call_set: TonSdk::Abi::CallSet.new(
          function_name: "constructor",
        ),
        signer: TonSdk::Abi::Signer.new(type_: :keys, keys: keys)
      )

      TonSdk::Abi.encode_message(@c_ctx.context, pr_s1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      # TODO finish up
    end

    # TODO more tests
  end
end