require 'spec_helper'

describe TonSdk::Net do
  context "methods of net" do
    it "query_collection" do
      # 1
      pr1 = TonSdk::Net::ParamsOfQueryCollection.new(
        collection: "blocks_signatures",
        result: "id",
        limit: 1
      )
      TonSdk::Net.query_collection(@c_ctx.context, pr1) { |a| @res1 = a }
      now = get_now_for_async_operation()
      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res1 || now >= timeout_at

      expect(@res1.success?).to eq true

      # 2
      pr2 = TonSdk::Net::ParamsOfQueryCollection.new(
        collection: "accounts",
        result: "id balance",
      )
      TonSdk::Net.query_collection(@c_ctx.context, pr2) { |a| @res2 = a }
      now = get_now_for_async_operation()
      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res2 || now >= timeout_at

      expect(@res2.success?).to eq true
      expect(@res2.result.result.length).to be > 0

      # 3
      pr3 = TonSdk::Net::ParamsOfQueryCollection.new(
        collection: "messages",
        filter: {
          "created_at": {"gt": 1562342740}
        },
        result: "body created_at"
      )
      TonSdk::Net.query_collection(@c_ctx.context, pr3) { |a| @res3 = a }
      now = get_now_for_async_operation()
      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res3 || now >= timeout_at

      expect(@res3.success?).to eq true
      expect(@res3.result.result[0]["created_at"]).to be > 1562342740
    end

    it "wait_for_collection" do
      now = Time.now.utc.to_i
      pr1 = TonSdk::Net::ParamsOfWaitForCollection.new(
        collection: "transactions",
        filter: {
          "now": { "gt": now }
        },
        result: "id now"
      )

      TonSdk::Net.wait_for_collection(@c_ctx.context, pr1) { |a| @res = a }
      now = get_now_for_async_operation()
      now = get_now_for_async_operation()
      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res || now >= (timeout_at * 2)

      expect(@res.success?).to eq true
      expect(@res.result.result["id"]).to_not eq nil
      expect(@res.result.result["now"]).to_not eq nil
    end

    it "subscribe_collection" do
      cb = Proc.new do |a|
        puts "subscribe_collection callback: #{a}"
      end

      pr1 = TonSdk::Net::ParamsOfSubscribeCollection.new(
        collection: "messages",
        filter: {"dst": { "eq": "1" }},
        result: "id"
      )

      TonSdk::Net.subscribe_collection(@c_ctx.context, pr1, cb) { |a| @res = a }
      now = get_now_for_async_operation()
      timeout_at = get_timeout_for_async_operation()
      sleep(0.1) until @res || now >= timeout_at

      expect(@res.success?).to eq true

      TonSdk::Net.unsubscribe(@c_ctx.context, @res.result) { |_| }
      sleep 1
    end
  end
end