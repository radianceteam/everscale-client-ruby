require 'spec_helper'

describe TonSdk::Boc do
  context "methods of boc" do
    it "#parse_message" do
      pr1 = TonSdk::Boc::ParamsOfParse.new("te6ccgEBAQEAWAAAq2n+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE/zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzSsG8DgAAAAAjuOu9NAL7BxYpA")

      expect { |b| TonSdk::Boc.parse_message(@c_ctx.context, pr1, &b) }.to yield_control
      expect { |b| TonSdk::Boc.parse_message(@c_ctx.context, pr1, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Boc.parse_message(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.parsed["id"]).to eq "dfd47194f3058ee058bfbfad3ea40cbbd9ad17ca77cd0904d4d9f18a48c2fbca"
      expect(@res.result.parsed["src"]).to eq "-1:0000000000000000000000000000000000000000000000000000000000000000"
      expect(@res.result.parsed["dst"]).to eq "-1:3333333333333333333333333333333333333333333333333333333333333333"
    end

    it "#parse_account" do
      pr1 = TonSdk::Boc::ParamsOfParse.new(File.read("spec/data/boc/parse_account1.txt"))

      expect { |b| TonSdk::Boc.parse_account(@c_ctx.context, pr1, &b) }.to yield_control
      expect { |b| TonSdk::Boc.parse_account(@c_ctx.context, pr1, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Boc.parse_account(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.parsed["id"]).to eq "0:2bb4a0e8391e7ea8877f4825064924bd41ce110fce97e939d3323999e1efbb13"
      expect(@res.result.parsed["last_trans_lt"]).to eq "0x20eadff7e03"
      expect(@res.result.parsed["balance"]).to eq "0x958a26eb8e7a18d"
    end

    it "#parse_transaction" do
      pr1 = TonSdk::Boc::ParamsOfParse.new("te6ccgECBwEAAZQAA7V75gA6WK5sEDTiHFGnH9ILOy2irjKLWTkWQMyMogsg40AAACDribjoE3gOAbYNpCaX4uLeXPQHt2Kw/Jp2OKkR2s+BASyeQM6wAAAg64IXyBX2DobAABRrMENIBQQBAhUEQojmJaAYazBCEQMCAFvAAAAAAAAAAAAAAAABLUUtpEnlC4z33SeGHxRhIq/htUa7i3D8ghbwxhQTn44EAJxC3UicQAAAAAAAAAAAdwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgnJAnYEvIQY6SnQKc3lXk6x1Z/lyplGFRbwAuNtVBi9EeceU3Ojl0F3EkRdylowY5x2qlgHNv4lNZUjhq0WqrLMNAQGgBgC3aADLL4ChL2HyLHwOLub5Mep87W3xdnMW8BpxKyVoGe3RPQAvmADpYrmwQNOIcUacf0gs7LaKuMotZORZAzIyiCyDjQ5iWgAGFFhgAAAEHXC9CwS+wdDGKTmMFkA=")

      expect { |b| TonSdk::Boc.parse_transaction(@c_ctx.context, pr1, &b) }.to yield_control
      expect { |b| TonSdk::Boc.parse_transaction(@c_ctx.context, pr1, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Boc.parse_transaction(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.parsed["id"]).to eq "d6315dbb2a741a2765da250bea4a186adf942469369c703c57c2050e2d6e9fe3"
      expect(@res.result.parsed["lt"]).to eq "0x20eb89b8e81"
      expect(@res.result.parsed["now"]).to eq 1600186476
    end

    it "#parse_block" do
      pr1 = TonSdk::Boc::ParamsOfParse.new(File.read("spec/data/boc/parse_block1.txt"))

      expect { |b| TonSdk::Boc.parse_block(@c_ctx.context, pr1, &b) }.to yield_control
      expect { |b| TonSdk::Boc.parse_block(@c_ctx.context, pr1, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Boc.parse_block(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.parsed["id"]).to eq "048f59d5d652459939ea5c5e7b291155205696b71e0c556f641df69e70e1e725"
      expect(@res.result.parsed["seq_no"]).to eq 4296363
      expect(@res.result.parsed["gen_utime"]).to eq 1600234696
    end

    it "#parse_shardstate" do
      pr1 = TonSdk::Boc::ParamsOfParseShardstate.new(
        id_: "zerostate:-1",
        workchain_id: -1,
        boc: File.read("spec/data/boc/parse_shardstate1.txt")
      )

      expect { |b| TonSdk::Boc.parse_shardstate(@c_ctx.context, pr1, &b) }.to yield_control
      expect { |b| TonSdk::Boc.parse_shardstate(@c_ctx.context, pr1, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Boc.parse_shardstate(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.parsed["id"]).to eq "zerostate:-1"
      expect(@res.result.parsed["workchain_id"]).to eq -1
      expect(@res.result.parsed["seq_no"]).to eq 0
    end

    it "#get_blockchain_config" do
      pr1 = TonSdk::Boc::ParamsOfGetBlockchainConfig.new(File.read("spec/data/boc/get_blockchain_config1.txt"))

      expect { |b| TonSdk::Boc.get_blockchain_config(@c_ctx.context, pr1, &b) }.to yield_control
      expect { |b| TonSdk::Boc.get_blockchain_config(@c_ctx.context, pr1, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Boc.get_blockchain_config(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true

      cont_boc = File.read("spec/data/boc/get_blockchain_config2.txt")
      expect(@res.result.config_boc).to eq cont_boc
    end
  end
end