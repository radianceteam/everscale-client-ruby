require 'spec_helper'

describe EverSdk::Net do
  context "methods of net" do
    it "query" do
      pr1 = EverSdk::Net::ParamsOfQuery.new(
        query: "query{info{version}}"
      )
      EverSdk::Net.query(@c_ctx.context, pr1) { |a| @res = a }
      timeout_at = get_timeout_for_async_operation()
      is_next_iter = @res.nil?
      while is_next_iter
        sleep(0.1)
        now = get_now_for_async_operation()
        is_next_iter = @res.nil? && (now <= timeout_at)
      end

      unless @res.nil?
        expect(@res.success?).to eq true
        vers = @res.result.result["data"]["info"]["version"]
        expect(vers.split(".").length).to eq 3
      end
    end

    it "find_last_shard_block" do
      pr1 = EverSdk::Net::ParamsOfFindLastShardBlock.new(
        address: GIVER_ADDRESS
      )
      EverSdk::Net.find_last_shard_block(@c_ctx.context, pr1) { |a| @res = a }
      timeout_at = get_timeout_for_async_operation()
      is_next_iter = @res.nil?
      while is_next_iter
        sleep(0.1)
        now = get_now_for_async_operation()
        is_next_iter = @res.nil? && (now <= timeout_at)
      end

      unless @res.nil?
        expect(@res.success?).to eq true
        expect(@res.result.block_id.length).to_not eq 0
      end
    end

    it "query_collection" do

      # 1
      pr1 = EverSdk::Net::ParamsOfQueryCollection.new(
        collection: "blocks_signatures",
        result: "id",
        limit: 1
      )
      EverSdk::Net.query_collection(@c_ctx.context, pr1) { |a| @res1 = a }

      timeout_at = get_timeout_for_async_operation()
      is_next_iter = @res1.nil?
      while is_next_iter
        sleep(0.1)
        now = get_now_for_async_operation()
        is_next_iter = @res1.nil? && (now <= timeout_at)
      end

      unless @res1.nil?
        expect(@res1.success?).to eq true
      end


      # 2
      pr2 = EverSdk::Net::ParamsOfQueryCollection.new(
        collection: "accounts",
        result: "id balance",
      )
      EverSdk::Net.query_collection(@c_ctx.context, pr2) { |a| @res2 = a }
      timeout_at = get_timeout_for_async_operation()
      is_next_iter = @res2.nil?
      while is_next_iter
        sleep(0.1)
        now = get_now_for_async_operation()
        is_next_iter = @res2.nil? && (now <= timeout_at)
      end

      unless @res2.nil?
        expect(@res2.success?).to eq true
        expect(@res2.result.result.length).to be > 0
      end


      # 3
      pr3 = EverSdk::Net::ParamsOfQueryCollection.new(
        collection: "messages",
        filter: {
          "created_at": {"gt": 1562342740}
        },
        result: "body created_at"
      )
      EverSdk::Net.query_collection(@c_ctx.context, pr3) { |a| @res3 = a }
      timeout_at = get_timeout_for_async_operation()
      is_next_iter = @res3.nil?
      while is_next_iter
        sleep(0.1)
        now = get_now_for_async_operation()
        is_next_iter = @res3.nil? && (now <= timeout_at)
      end

      unless @res3.nil?
        expect(@res3.success?).to eq true
        expect(@res3.result.result[0]["created_at"]).to be > 1562342740
      end
    end

    it "wait_for_collection" do
      now = Time.now.utc.to_i
      pr1 = EverSdk::Net::ParamsOfWaitForCollection.new(
        collection: "transactions",
        filter: {
          "now": { "gt": now }
        },
        result: "id now"
      )

      EverSdk::Net.wait_for_collection(@c_ctx.context, pr1) { |a| @res = a }
      timeout_at = get_timeout_for_async_operation()
      is_next_iter = @res.nil?
      while is_next_iter
        sleep(0.1)
        now = get_now_for_async_operation()
        is_next_iter = @res.nil? && (now <= timeout_at)
      end

      unless @res.nil?
        expect(@res.success?).to eq true
        expect(@res.result.result["id"]).to_not eq nil
        expect(@res.result.result["now"]).to_not eq nil
      end
    end

    it "subscribe_collection" do
      cb = Proc.new do |a|
        puts "subscribe_collection callback: #{a}"
      end

      pr1 = EverSdk::Net::ParamsOfSubscribeCollection.new(
        collection: "messages",
        filter: {"dst": { "eq": "1" }},
        result: "id"
      )

      EverSdk::Net.subscribe_collection(@c_ctx.context, pr1, client_callback: cb) { |a| @res = a }

      timeout_at = get_timeout_for_async_operation()
      is_next_iter = @res.nil?
      while is_next_iter
        sleep(0.1)
        now = get_now_for_async_operation()
        is_next_iter = @res.nil? && (now <= timeout_at)
      end

      unless @res.nil?
        expect(@res.success?).to eq true
      end

      EverSdk::Net.unsubscribe(@c_ctx.context, @res.result) { |_| }
      sleep(1)
    end
  end
end
