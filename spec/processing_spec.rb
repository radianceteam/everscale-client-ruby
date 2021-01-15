require 'spec_helper'

describe TonSdk::Processing do
  context "methods of processing" do
    it "#process_message" do
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

      encode_params = TonSdk::Abi::ParamsOfEncodeMessage.new(
        abi: abi1,
        deploy_set: TonSdk::Abi::DeploySet.new(
          tvc: tvc1
        ),
        call_set: TonSdk::Abi::CallSet.new(
          function_name: "constructor",
          header: TonSdk::Abi::FunctionHeader.new(
            pubkey: keys.public_,
          ),
        ),
        signer: TonSdk::Abi::Signer.new(type_: :keys, keys: keys)
      )

      @q = Queue.new()
      cb = Proc.new do |a|
        a_tp = a["type"]
        @q.push(a_tp)
        puts "process_message > event: #{a_tp}"
      end

      pr1 = TonSdk::Processing::ParamsOfProcessMessage.new(
        message_encode_params: encode_params,
        send_events: true
      )







      # FIX
      # take other approach to testing this

      TonSdk::Processing.process_message(@c_ctx.context, pr1, cb) { |a| @res1 = a }

      timeout_at = get_timeout_for_async_operation()
      is_next_iter = @res1.nil?
      while is_next_iter
        sleep(0.1)
        now = get_now_for_async_operation()
        is_next_iter = @res1.nil? && (now <= timeout_at)
      end

      while @q.length > 0
        elem = TonSdk::Helper.capitalized_case_str_to_snake_case_sym(@q.pop())
        is_known_event_type = TonSdk::Processing::ProcessingEvent::TYPES.include?(elem)
        expect(is_known_event_type).to be true
      end

      # expected error:
      # ".. need to transfer funds to this account first to have a positive balance and then deploy its code"
      # expect(@res1.result).to eq 123
      # expect(@res1.error["code"]).to eq 409
    end
  end
end