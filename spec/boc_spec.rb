require 'spec_helper'

describe TonSdk::Boc do
  context "methods of boc" do
    it "test_pinned_cache" do
      boc1 = load_tvc(name: "Hello")
      boc2 = load_tvc(name: "Events")

      pin1 = "pin1"
      pin2 = "pin2"

      ref1 = test_client.request(
        "boc.cache_set",
        TonSdk::Boc::ParamsOfBocCacheSet.new(
          boc: boc1,
          cache_type: TonSdk::Boc::BocCacheType.new(type: :pinned, pin: pin1)
        )
      ).boc_ref

      expect(ref1[0]).to eq("*")
      expect(ref1.length).to eq(65)

      boc = test_client.request(
        "boc.cache_get",
        TonSdk::Boc::ParamsOfBocCacheGet.new(boc_ref: ref1)
      )

      expect(boc.boc).to eq(boc1)

      ref2 = test_client.request(
        "boc.cache_set",
        TonSdk::Boc::ParamsOfBocCacheSet.new(
          boc: boc2,
          cache_type: TonSdk::Boc::BocCacheType.new(type: :pinned, pin: pin1)
        )
      ).boc_ref

      expect(ref1).not_to eq(ref2)

      ref3 = test_client.request(
        "boc.cache_set",
        TonSdk::Boc::ParamsOfBocCacheSet.new(
          boc: boc1,
          cache_type: TonSdk::Boc::BocCacheType.new(type: :pinned, pin: pin2)
        )
      ).boc_ref

      expect(ref3).to eq(ref1)

      # unpin pin1 and check that boc2 which had only this pin is removed from cache but boc1 which
      # had both pins is still in cache
      test_client.request(
        "boc.cache_unpin",
        TonSdk::Boc::ParamsOfBocCacheUnpin.new(pin: pin1)
      )

      boc = test_client.request(
        "boc.cache_get",
        TonSdk::Boc::ParamsOfBocCacheGet.new(boc_ref: ref1)
      )

      expect(boc.boc).to eq(boc1)

      boc = test_client.request(
        "boc.cache_get",
        TonSdk::Boc::ParamsOfBocCacheGet.new(boc_ref: ref2)
      )

      expect(boc.boc).to eq(nil)

      ref4 = test_client.request(
        "boc.cache_set",
        TonSdk::Boc::ParamsOfBocCacheSet.new(
          boc: boc2,
          cache_type: TonSdk::Boc::BocCacheType.new(type: :pinned, pin: pin2)
        )
      ).boc_ref

      # unpin pin2 with particular ref and that only this ref is removed from cache
      test_client.request(
        "boc.cache_unpin",
        TonSdk::Boc::ParamsOfBocCacheUnpin.new(boc_ref: ref4, pin: pin2)
      )

      boc = test_client.request(
        "boc.cache_get",
        TonSdk::Boc::ParamsOfBocCacheGet.new(boc_ref: ref1)
      )

      expect(boc.boc).to eq(boc1)

      boc = test_client.request(
        "boc.cache_get",
        TonSdk::Boc::ParamsOfBocCacheGet.new(boc_ref: ref4)
      )

      expect(boc.boc).to eq(nil)

      test_client.request(
        "boc.cache_unpin",
        TonSdk::Boc::ParamsOfBocCacheUnpin.new(pin: pin2)
      )

      boc = test_client.request(
        "boc.cache_get",
        TonSdk::Boc::ParamsOfBocCacheGet.new(boc_ref: ref1)
      )

      expect(boc.boc).to eq(nil)
    end

    it "test_unpinned_cache" do
      boc1 = load_tvc(name: "testDebot")
      boc2 = load_tvc(name: "Subscription")

      boc_max_size = [
        Base64.strict_decode64(boc1).length,
        Base64.strict_decode64(boc2).length
      ].max

      test_client = TestClient.new(
        config: {
          boc: {
            cache_max_size: boc_max_size / 1024 + 1
          }
        }
      )

      ref1 = test_client.request(
        "boc.cache_set",
        TonSdk::Boc::ParamsOfBocCacheSet.new(
          boc: boc1,
          cache_type: TonSdk::Boc::BocCacheType.new(type: :unpinned)
        )
      ).boc_ref

      boc = test_client.request(
        "boc.cache_get",
        TonSdk::Boc::ParamsOfBocCacheGet.new(
          boc_ref: ref1
        )
      )

      expect(boc.boc).to eq(boc1)

      # add second BOC to remove first BOC by insufficient cache size
      ref2 = test_client.request(
        "boc.cache_set",
        TonSdk::Boc::ParamsOfBocCacheSet.new(
          boc: boc2,
          cache_type: TonSdk::Boc::BocCacheType.new(type: :unpinned)
        )
      ).boc_ref

      boc = test_client.request(
        "boc.cache_get",
        TonSdk::Boc::ParamsOfBocCacheGet.new(
          boc_ref: ref1
        )
      )

      expect(boc.boc).to eq(nil)

      boc = test_client.request(
        "boc.cache_get",
        TonSdk::Boc::ParamsOfBocCacheGet.new(
          boc_ref: ref2
        )
      )

      expect(boc.boc).to eq(boc2)
    end

    it "#get_boc_hash" do
      result = test_client.request(
        "boc.get_boc_hash",
        TonSdk::Boc::ParamsOfGetBocHash.new(
          boc: "te6ccgEBAQEAWAAAq2n+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE/zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzSsG8DgAAAAAjuOu9NAL7BxYpA"
        )
      )

      expect(result.hash).to eq("dfd47194f3058ee058bfbfad3ea40cbbd9ad17ca77cd0904d4d9f18a48c2fbca")
    end

    it "#get_boc_depth" do
      boc = load_boc(name: "account")
      result = test_client.request(
        "boc.get_boc_depth",
        TonSdk::Boc::ParamsOfGetBocDepth.new(boc: boc)
      )

      expect(result.depth).to eq(8)
    end

    it "#get_code_from_tvc" do
      result = test_client.request(
        "boc.get_code_from_tvc",
        TonSdk::Boc::ParamsOfGetCodeFromTvc.new(
          tvc: "te6ccgECHAEABDkAAgE0BgEBAcACAgPPIAUDAQHeBAAD0CAAQdgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAIm/wD0pCAiwAGS9KDhiu1TWDD0oQkHAQr0pCD0oQgAAAIBIAwKAej/fyHTAAGOJoECANcYIPkBAXDtRND0BYBA9A7yitcL/wHtRyJvde1XAwH5EPKo3u1E0CDXScIBjhb0BNM/0wDtRwFvcQFvdgFvcwFvcu1Xjhj0Be1HAW9ycG9zcG92yIAgz0DJ0G9x7Vfi0z8B7UdvEyG5IAsAYJ8wIPgjgQPoqIIIG3dAoLneme1HIW9TIO1XMJSANPLw4jDTHwH4I7zyudMfAfFAAQIBIBgNAgEgEQ4BCbqLVfP4DwH67UdvYW6OO+1E0CDXScIBjhb0BNM/0wDtRwFvcQFvdgFvcwFvcu1Xjhj0Be1HAW9ycG9zcG92yIAgz0DJ0G9x7Vfi3u1HbxaS8jOX7Udxb1btV+IA+ADR+CO1H+1HIG8RMAHIyx/J0G9R7VftR28SyPQA7UdvE88LP+1HbxYQABzPCwDtR28RzxbJ7VRwagIBahUSAQm0ABrWwBMB/O1Hb2FujjvtRNAg10nCAY4W9ATTP9MA7UcBb3EBb3YBb3MBb3LtV44Y9AXtRwFvcnBvc3BvdsiAIM9AydBvce1X4t7tR29lIG6SMHDecO1HbxKAQPQO8orXC/+68uBk+AD6QNEgyMn7BIED6HCBAIDIcc8LASLPCgBxz0D4KBQAjs8WJM8WI/oCcc9AcPoCcPoCgEDPQPgjzwsfcs9AIMki+wBfBTDtR28SyPQA7UdvE88LP+1HbxbPCwDtR28RzxbJ7VRwatswAQm0ZfaLwBYB+O1Hb2FujjvtRNAg10nCAY4W9ATTP9MA7UcBb3EBb3YBb3MBb3LtV44Y9AXtRwFvcnBvc3BvdsiAIM9AydBvce1X4t7R7UdvEdcLH8iCEFDL7ReCEIAAAACxzwsfIc8LH8hzzwsB+CjPFnLPQPglzws/gCHPQCDPNSLPMbwXAHiWcc9AIc8XlXHPQSHN4iDJcfsAWyHA/44e7UdvEsj0AO1HbxPPCz/tR28WzwsA7UdvEc8Wye1U3nFq2zACASAbGQEJu3MS5FgaAPjtR29hbo477UTQINdJwgGOFvQE0z/TAO1HAW9xAW92AW9zAW9y7VeOGPQF7UcBb3Jwb3Nwb3bIgCDPQMnQb3HtV+Le+ADR+CO1H+1HIG8RMAHIyx/J0G9R7VftR28SyPQA7UdvE88LP+1HbxbPCwDtR28RzxbJ7VRwatswAMrdcCHXSSDBII4rIMAAjhwj0HPXIdcLACDAAZbbMF8H2zCW2zBfB9sw4wTZltswXwbbMOME2eAi0x80IHS7II4VMCCCEP////+6IJkwIIIQ/////rrf35bbMF8H2zDgIyHxQAFfBw=="
        )
      )

      expect(result.code).to eq("te6ccgECFgEAA/8AAib/APSkICLAAZL0oOGK7VNYMPShAwEBCvSkIPShAgAAAgEgBgQB6P9/IdMAAY4mgQIA1xgg+QEBcO1E0PQFgED0DvKK1wv/Ae1HIm917VcDAfkQ8qje7UTQINdJwgGOFvQE0z/TAO1HAW9xAW92AW9zAW9y7VeOGPQF7UcBb3Jwb3Nwb3bIgCDPQMnQb3HtV+LTPwHtR28TIbkgBQBgnzAg+COBA+iogggbd0Cgud6Z7Uchb1Mg7VcwlIA08vDiMNMfAfgjvPK50x8B8UABAgEgEgcCASALCAEJuotV8/gJAfrtR29hbo477UTQINdJwgGOFvQE0z/TAO1HAW9xAW92AW9zAW9y7VeOGPQF7UcBb3Jwb3Nwb3bIgCDPQMnQb3HtV+Le7UdvFpLyM5ftR3FvVu1X4gD4ANH4I7Uf7UcgbxEwAcjLH8nQb1HtV+1HbxLI9ADtR28Tzws/7UdvFgoAHM8LAO1HbxHPFsntVHBqAgFqDwwBCbQAGtbADQH87UdvYW6OO+1E0CDXScIBjhb0BNM/0wDtRwFvcQFvdgFvcwFvcu1Xjhj0Be1HAW9ycG9zcG92yIAgz0DJ0G9x7Vfi3u1Hb2UgbpIwcN5w7UdvEoBA9A7yitcL/7ry4GT4APpA0SDIyfsEgQPocIEAgMhxzwsBIs8KAHHPQPgoDgCOzxYkzxYj+gJxz0Bw+gJw+gKAQM9A+CPPCx9yz0AgySL7AF8FMO1HbxLI9ADtR28Tzws/7UdvFs8LAO1HbxHPFsntVHBq2zABCbRl9ovAEAH47UdvYW6OO+1E0CDXScIBjhb0BNM/0wDtRwFvcQFvdgFvcwFvcu1Xjhj0Be1HAW9ycG9zcG92yIAgz0DJ0G9x7Vfi3tHtR28R1wsfyIIQUMvtF4IQgAAAALHPCx8hzwsfyHPPCwH4KM8Wcs9A+CXPCz+AIc9AIM81Is8xvBEAeJZxz0AhzxeVcc9BIc3iIMlx+wBbIcD/jh7tR28SyPQA7UdvE88LP+1HbxbPCwDtR28RzxbJ7VTecWrbMAIBIBUTAQm7cxLkWBQA+O1Hb2FujjvtRNAg10nCAY4W9ATTP9MA7UcBb3EBb3YBb3MBb3LtV44Y9AXtRwFvcnBvc3BvdsiAIM9AydBvce1X4t74ANH4I7Uf7UcgbxEwAcjLH8nQb1HtV+1HbxLI9ADtR28Tzws/7UdvFs8LAO1HbxHPFsntVHBq2zAAyt1wIddJIMEgjisgwACOHCPQc9ch1wsAIMABltswXwfbMJbbMF8H2zDjBNmW2zBfBtsw4wTZ4CLTHzQgdLsgjhUwIIIQ/////7ogmTAgghD////+ut/fltswXwfbMOAjIfFAAV8H")
    end

    it "#parse_message" do
      pr1 = TonSdk::Boc::ParamsOfParse.new(boc: "te6ccgEBAQEAWAAAq2n+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE/zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzSsG8DgAAAAAjuOu9NAL7BxYpA")

      expect { |b| TonSdk::Boc.parse_message(@c_ctx.context, pr1, &b) }.to yield_control
      expect { |b| TonSdk::Boc.parse_message(@c_ctx.context, pr1, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Boc.parse_message(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.parsed["id"]).to eq "dfd47194f3058ee058bfbfad3ea40cbbd9ad17ca77cd0904d4d9f18a48c2fbca"
      expect(@res.result.parsed["src"]).to eq "-1:0000000000000000000000000000000000000000000000000000000000000000"
      expect(@res.result.parsed["dst"]).to eq "-1:3333333333333333333333333333333333333333333333333333333333333333"
    end

    it "#parse_account" do
      pr1 = TonSdk::Boc::ParamsOfParse.new(boc: File.read("spec/data/boc/parse_account1.txt"))

      expect { |b| TonSdk::Boc.parse_account(@c_ctx.context, pr1, &b) }.to yield_control
      expect { |b| TonSdk::Boc.parse_account(@c_ctx.context, pr1, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Boc.parse_account(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.parsed["id"]).to eq "0:2bb4a0e8391e7ea8877f4825064924bd41ce110fce97e939d3323999e1efbb13"
      expect(@res.result.parsed["last_trans_lt"]).to eq "0x20eadff7e03"
      expect(@res.result.parsed["balance"]).to eq "0x958a26eb8e7a18d"
    end

    it "#parse_transaction" do
      pr1 = TonSdk::Boc::ParamsOfParse.new(boc: "te6ccgECBwEAAZQAA7V75gA6WK5sEDTiHFGnH9ILOy2irjKLWTkWQMyMogsg40AAACDribjoE3gOAbYNpCaX4uLeXPQHt2Kw/Jp2OKkR2s+BASyeQM6wAAAg64IXyBX2DobAABRrMENIBQQBAhUEQojmJaAYazBCEQMCAFvAAAAAAAAAAAAAAAABLUUtpEnlC4z33SeGHxRhIq/htUa7i3D8ghbwxhQTn44EAJxC3UicQAAAAAAAAAAAdwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgnJAnYEvIQY6SnQKc3lXk6x1Z/lyplGFRbwAuNtVBi9EeceU3Ojl0F3EkRdylowY5x2qlgHNv4lNZUjhq0WqrLMNAQGgBgC3aADLL4ChL2HyLHwOLub5Mep87W3xdnMW8BpxKyVoGe3RPQAvmADpYrmwQNOIcUacf0gs7LaKuMotZORZAzIyiCyDjQ5iWgAGFFhgAAAEHXC9CwS+wdDGKTmMFkA=")

      expect { |b| TonSdk::Boc.parse_transaction(@c_ctx.context, pr1, &b) }.to yield_control
      expect { |b| TonSdk::Boc.parse_transaction(@c_ctx.context, pr1, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Boc.parse_transaction(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.parsed["id"]).to eq "d6315dbb2a741a2765da250bea4a186adf942469369c703c57c2050e2d6e9fe3"
      expect(@res.result.parsed["lt"]).to eq "0x20eb89b8e81"
      expect(@res.result.parsed["now"]).to eq 1600186476
    end

    it "#parse_block" do
      pr1 = TonSdk::Boc::ParamsOfParse.new(boc: File.read("spec/data/boc/parse_block1.txt"))

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
        id: "zerostate:-1",
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
      pr1 = TonSdk::Boc::ParamsOfGetBlockchainConfig.new(
        block_boc: File.read("spec/data/boc/get_blockchain_config1.txt")
      )

      expect { |b| TonSdk::Boc.get_blockchain_config(@c_ctx.context, pr1, &b) }.to yield_control
      expect { |b| TonSdk::Boc.get_blockchain_config(@c_ctx.context, pr1, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Boc.get_blockchain_config(@c_ctx.context, pr1) { |a| @res = a }
      expect(@res.success?).to eq true

      cont_boc = File.read("spec/data/boc/get_blockchain_config2.txt")
      expect(@res.result.config_boc).to eq cont_boc
    end

    context "code_salt" do
      let(:code_no_salt) { 'te6ccgECGAEAAmMAAgaK2zUXAQQkiu1TIOMDIMD/4wIgwP7jAvILFAMCDgKE7UTQ10nDAfhmIds80wABn4ECANcYIPkBWPhC+RDyqN7TPwH4QyG58rQg+COBA+iogggbd0CgufK0+GPTHwHbPPI8BgQDSu1E0NdJwwH4ZiLQ1wsDqTgA3CHHAOMCIdcNH/K8IeMDAds88jwTEwQDPCCCEDKVn7a64wIgghBgeXU+uuMCIIIQaLVfP7rjAg8HBQIiMPhCbuMA+Ebyc9H4ANs88gAGEAE+7UTQ10nCAYqOFHDtRND0BYBA9A7yvdcL//hicPhj4hICdjD4RvLgTNTR2zwhjicj0NMB+kAwMcjPhyDOjQQAAAAAAAAAAAAAAAAOB5dT6M8WzMlw+wCRMOLjAPIACBACMvhBiMjPjits1szOyTCBAIbIy/8B0AHJ2zwXCQIWIYs4rbNYxwWKiuILCgEIAds8yQwBJgHU1DAS0Ns8yM+OK2zWEszPEckMAWbViy9KQNcm9ATTCTEg10qR1I6A4osvShjXJjAByM+L0pD0AIAgzwsJz4vShswSzMjPEc4NAQSIAQ4AAAOEMPhG8uBM+EJu4wDT/9HbPCGOKCPQ0wH6QDAxyM+HIM6NBAAAAAAAAAAAAAAAAAspWftozxbL/8lw+wCRMOLbPPIAEhEQABz4Q/hCyMv/yz/Pg8ntVAAgIMECkXGYUwCltf/wHKjiMQAe7UTQ0//TP9MAMdH4Y/hiAAr4RvLgTAIK9KQg9KEWFQAUc29sIDAuNTEuMAAqoAAAABwgwQKRcZhTAKW1//AcqOIxAAwg+GHtHtk=' }
      let(:code_salt) { 'te6ccgEBAQEAJAAAQ4AGPqCXQ2drhdqhLLt3rJ80LxA65YMTwgWLLUmt9EbElFA=' }

      it "#get_code_salt" do
        params = TonSdk::Boc::ParamsOfGetCodeSalt.new(code: code_no_salt)
        TonSdk::Boc.get_code_salt(@c_ctx.context, params) { |r| @response = r }

        expect(@response.success?).to eq(true)
        expect(@response.result.salt).to eq(nil)
      end

      it "#set_code_salt" do
        params = TonSdk::Boc::ParamsOfSetCodeSalt.new(code: code_no_salt, salt: code_salt)
        TonSdk::Boc.set_code_salt(@c_ctx.context, params) { |r| @response = r }
        code_with_salt = @response.result.code

        expect(@response.success?).to eq(true)
        expect(code_with_salt).not_to eq(code_no_salt)

        #get_code_salt
        params = TonSdk::Boc::ParamsOfGetCodeSalt.new(code: code_with_salt)
        TonSdk::Boc.get_code_salt(@c_ctx.context, params) { |r| @response = r }

        expect(@response.success?).to eq(true)
        expect(@response.result.salt).to eq(code_salt)
      end
    end

    it "#tvc_encode" do
      check_encode_tvc = Proc.new do |tvc, decoded|
        result = test_client.request(
          "boc.decode_tvc",
          TonSdk::Boc::ParamsOfDecodeTvc.new(tvc: tvc)
        )

        expect(result.to_json).to eq(decoded.to_json)

        result = test_client.request(
          "boc.encode_tvc",
          TonSdk::Boc::ParamsOfEncodeTvc.new(
            code: result.code,
            data: result.data,
            library: result.library,
            split_depth: result.split_depth,
            tick: result.tick,
            tock: result.tock
          )
        )

        expect(result.tvc).to eq(tvc)
      end

      tvc = load_tvc(name: "t24_initdata")
      decoded = TonSdk::Boc::ResultOfDecodeTvc.new(
        code: "te6ccgECEAEAAYkABCSK7VMg4wMgwP/jAiDA/uMC8gsNAgEPAoTtRNDXScMB+GYh2zzTAAGfgQIA1xgg+QFY+EL5EPKo3tM/AfhDIbnytCD4I4ED6KiCCBt3QKC58rT4Y9MfAds88jwFAwNK7UTQ10nDAfhmItDXCwOpOADcIccA4wIh1w0f8rwh4wMB2zzyPAwMAwIoIIIQBoFGw7rjAiCCEGi1Xz+64wIIBAIiMPhCbuMA+Ebyc9H4ANs88gAFCQIW7UTQ10nCAYqOgOILBgFccO1E0PQFcSGAQPQOk9cLB5Fw4vhqciGAQPQPjoDf+GuAQPQO8r3XC//4YnD4YwcBAogPA3Aw+Eby4Ez4Qm7jANHbPCKOICTQ0wH6QDAxyM+HIM6AYs9AXgHPkhoFGw7LB8zJcPsAkVvi4wDyAAsKCQAq+Ev4SvhD+ELIy//LP8+DywfMye1UAAj4SvhLACztRNDT/9M/0wAx0wfU0fhr+Gr4Y/hiAAr4RvLgTAIK9KQg9KEPDgAUc29sIDAuNTEuMAAA",
        code_depth: 7,
        code_hash: "0ad23f96d7b1c1ce78dae573ac8cdf71523dc30f36316b5aaa5eb3cc540df0e0",
        data: "te6ccgEBAgEAKAABAcABAEPQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAg",
        data_depth: 1,
        data_hash: "55a703465a160dce20481375de2e5b830c841c2787303835eb5821d62d65ca9d",
        library: nil,
        split_depth: nil,
        tick: nil,
        tock: nil,
        compiler_version: "sol 0.51.0"
      )

      check_encode_tvc.call(tvc, decoded)

      tvc = load_boc(name: "state_init_lib")
      decoded = TonSdk::Boc::ResultOfDecodeTvc.new(
        code: "te6ccgEBBAEAhwABFP8A9KQT9LzyyAsBAgEgAwIA36X//3aiaGmP6f/o5CxSZ4WPkOeF/+T2qmRnxET/s2X/wQgC+vCAfQFANeegZLh9gEB354V/wQgD39JAfQFANeegZLhkZ82JA6Mrm6RBCAOt5or9AUA156BF6kMrY2N5YQO7e5NjIQxni2S4fYB9gEAAAtI=",
        code_depth: 2,
        code_hash: "45910e27fe37d8dcf1fac777ebb3bda38ae1ea8389f81bfb1bc0079f3f67ef5b",
        data: "te6ccgEBAQEAJgAASBHvVgMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==",
        data_depth: 0,
        data_hash: "97bfef744b0d45f78b901e2997fb55f6dbc1d396a8d2f8f4c3a5468c010db67a",
        library: "te6ccgEBBgEAYAACAWIEAQFCv0EkKSBepm1vIATt+lcPb1az6F5ZuqG++8c7faXVW9xhAgEEEjQDAARWeAFCv1ou71BWd19blXL/OtY90qcdH7KByhd6Xhx0cw7MsuUTBQAPq6yrrausq6g=",
        split_depth: nil,
        tick: true,
        tock: true,
        compiler_version: nil
      )

      check_encode_tvc.call(tvc, decoded)
    end

    it "#get_compiler_version" do
      tvc = load_tvc(name: "t24_initdata")
      code = test_client.request(
        "boc.decode_tvc",
        TonSdk::Boc::ParamsOfDecodeTvc.new(tvc: tvc)
      ).code

      result = test_client.request(
        "boc.get_compiler_version",
        TonSdk::Boc::ParamsOfGetCompilerVersion.new(code: code)
      )

      expect(result.version).to eq("sol 0.51.0")
    end
  end
end
