require 'spec_helper'

describe TonSdk::Processing do
  context "methods of processing" do
    xit "send and wait for message" do
      abi = load_abi(name: "Events")
      tvc = load_tvc(name: "Events")

      keys = TonSdk::Crypto::KeyPair.new(
        public_: "4c7c408ff1ddebb8d6405ee979c716a14fdd6cc08124107a61d3c25597099499",
        secret: "cc8929d635719612a9478b9cd17675a39cfad52d8959e8a177389b8c0b9122a7"
      )

      pr_s1 = TonSdk::Abi::ParamsOfEncodeMessage.new(
        abi: abi,
        deploy_set: TonSdk::Abi::DeploySet.new(tvc: tvc),
        call_set: TonSdk::Abi::CallSet.new(
          function_name: "constructor",
        ),
        signer: TonSdk::Abi::Signer.new(type_: :keys, keys: keys)
      )

      TonSdk::Abi.encode_message(@c_ctx.context, pr_s1) { |a| @res1 = a }
      expect(@res1.success?).to eq true


      # TODO finish up



      get_grams_from_giver(@c_ctx.context, @res1.result.address)


      pr_s2 = TonSdk::Processing::ParamsOfSendMessage.new(
        abi: abi,
        message: @res1.result.message,
        send_events: true
      )

      @events = Queue.new
      resp_handler = Proc.new do |a|
        @events.push(a)
      end

      TonSdk::Processing::send_message(@c_ctx.context, pr_s2, resp_handler) { |a| @res2 = a }
      timeout_at2 = get_timeout_for_async_operation()
      is_next_iter2 = @res2.nil?
      while is_next_iter2
        sleep(0.1)
        now = get_now_for_async_operation()
        is_next_iter2 = @res2.nil? && (now <= timeout_at2)
      end

      expect(@res2.success?).to eq true
      expect(@res2.result.shard_block_id).to_not eq 0

      pr_s3 = TonSdk::Processing::ParamsOfWaitForTransaction.new(
        abi: abi,
        message: @res1.result.message,
        shard_block_id: (@res2.result.shard_block_id || ""),
        send_events: true
      )

      TonSdk::Processing::wait_for_transaction(@c_ctx.context, pr_s3, resp_handler) { |a| @res3 = a }

      timeout_at3 = get_timeout_for_async_operation()
      is_next_iter3 = @res3.nil?
      while is_next_iter3
        sleep(0.1)
        now = get_now_for_async_operation()
        is_next_iter3 = @res3.nil? && (now <= timeout_at3)
      end

      for x in 0..@events.size
        evt_tp = TonSdk::Helper.capitalized_case_str_to_snake_case_sym(@events.pop["type"])
        is_type_known = TonSdk::Processing::ProcessingEvent::TYPES.include?(evt_tp)
        expect(is_type_known).to eq true
      end

      # TODO finish it
      # take into account that it may behave differently each time it's being run
    end

    # TODO more tests
  end
end
