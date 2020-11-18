require 'spec_helper'
require 'json'

describe TonSdk::Abi do
  context "methods of abi" do
    it "#encode_v2" do
      cont_json = File.read("#{TESTS_DATA_DIR}/contracts/abi_v2/Events.abi.json")
      abi1 = TonSdk::Abi::Abi.new(
        type_: :contract,
        value: TonSdk::Abi::AbiContract.from_json(JSON.parse(cont_json))
      )
      keys = TonSdk::Crypto::KeyPair.new(
        public_: "4c7c408ff1ddebb8d6405ee979c716a14fdd6cc08124107a61d3c25597099499",
        secret: "cc8929d635719612a9478b9cd17675a39cfad52d8959e8a177389b8c0b9122a7"
      )
      time1 = 1599458364291
      expire1 = 1599458404

      tvc1_cont_bin = IO.binread("#{TESTS_DATA_DIR}/contracts/abi_v2/Events.tvc")
      tvc1 = Base64::strict_encode64(tvc1_cont_bin)

      signing = TonSdk::Abi::Signer.new(type_: :external, public_key: keys.public_)
      pr1 = TonSdk::Abi::ParamsOfEncodeMessage.new(
        abi: abi1,
        deploy_set: TonSdk::Abi::DeploySet.new(
          tvc: tvc1
        ),
        call_set: TonSdk::Abi::CallSet.new(
          function_name: "constructor",
          header: TonSdk::Abi::FunctionHeader.new(
            pubkey: keys.public_,
            time: time1,
            expire: expire1,
          ),
        ),
        signer: signing
      )

      expect { |b| TonSdk::Abi.encode_message(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Abi.encode_message(@c_ctx.context, pr1) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.result.message).to eq "te6ccgECFwEAA2gAAqeIAAt9aqvShfTon7Lei1PVOhUEkEEZQkhDKPgNyzeTL6YSEZTHxAj/Hd67jWQF7peccWoU/dbMCBJBB6YdPCVZcJlJkAAAF0ZyXLg19VzGRotV8/gGAQEBwAICA88gBQMBAd4EAAPQIABB2mPiBH+O713GsgL3S844tQp+62YECSCD0w6eEqy4TKTMAib/APSkICLAAZL0oOGK7VNYMPShCQcBCvSkIPShCAAAAgEgDAoByP9/Ie1E0CDXScIBjhDT/9M/0wDRf/hh+Gb4Y/hijhj0BXABgED0DvK91wv/+GJw+GNw+GZ/+GHi0wABjh2BAgDXGCD5AQHTAAGU0/8DAZMC+ELiIPhl+RDyqJXTAAHyeuLTPwELAGqOHvhDIbkgnzAg+COBA+iogggbd0Cgud6S+GPggDTyNNjTHwH4I7zyudMfAfAB+EdukvI83gIBIBINAgEgDw4AvbqLVfP/hBbo417UTQINdJwgGOENP/0z/TANF/+GH4Zvhj+GKOGPQFcAGAQPQO8r3XC//4YnD4Y3D4Zn/4YeLe+Ebyc3H4ZtH4APhCyMv/+EPPCz/4Rs8LAMntVH/4Z4AgEgERAA5biABrW/CC3Rwn2omhp/+mf6YBov/ww/DN8Mfwxb30gyupo6H0gb+j8IpA3SRg4b3whXXlwMnwAZGT9ghBkZ8KEZ0aCBAfQAAAAAAAAAAAAAAAAACBni2TAgEB9gBh8IWRl//wh54Wf/CNnhYBk9qo//DPAAxbmTwqLfCC3Rwn2omhp/+mf6YBov/ww/DN8Mfwxb2uG/8rqaOhp/+/o/ABkRe4AAAAAAAAAAAAAAAAIZ4tnwOfI48sYvRDnhf/kuP2AGHwhZGX//CHnhZ/8I2eFgGT2qj/8M8AIBSBYTAQm4t8WCUBQB/PhBbo4T7UTQ0//TP9MA0X/4Yfhm+GP4Yt7XDf+V1NHQ0//f0fgAyIvcAAAAAAAAAAAAAAAAEM8Wz4HPkceWMXohzwv/yXH7AMiL3AAAAAAAAAAAAAAAABDPFs+Bz5JW+LBKIc8L/8lx+wAw+ELIy//4Q88LP/hGzwsAye1UfxUABPhnAHLccCLQ1gIx0gAw3CHHAJLyO+Ah1w0fkvI84VMRkvI74cEEIoIQ/////byxkvI84AHwAfhHbpLyPN4="
    end

    it "#decode_v2" do
      ev_cont_json = File.read("#{TESTS_DATA_DIR}/contracts/abi_v2/Events.abi.json")
      abi1 = TonSdk::Abi::Abi.new(
        type_: :contract,
        value: TonSdk::Abi::AbiContract.from_json(JSON.parse(ev_cont_json))
      )

      pr1 = TonSdk::Abi::ParamsOfDecodeMessage.new(
        abi: abi1,
        message: "te6ccgEBAwEAvAABRYgAC31qq9KF9Oifst6LU9U6FQSQQRlCSEMo+A3LN5MvphIMAQHhrd/b+MJ5Za+AygBc5qS/dVIPnqxCsM9PvqfVxutK+lnQEKzQoRTLYO6+jfM8TF4841bdNjLQwIDWL4UVFdxIhdMfECP8d3ruNZAXul5xxahT91swIEkEHph08JVlwmUmQAAAXRnJcuDX1XMZBW+LBKACAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
      )
      expect { |b| TonSdk::Abi.decode_message(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Abi.decode_message(@c_ctx.context, pr1) { |a| @res1 = a }

      # 1
      expected1 = TonSdk::Abi::DecodedMessageBody.new(
        body_type: :input,
        name: "returnValue",
        value: {id: "0x0"},
        header: TonSdk::Abi::FunctionHeader.new(
          expire: 1599458404,
          time: 1599458364291,
          pubkey: "4c7c408ff1ddebb8d6405ee979c716a14fdd6cc08124107a61d3c25597099499",
        )
      )

      expect(@res1.success?).to eq true
      expect(@res1.result.body_type).to eq expected1.body_type
      expect(@res1.result.name).to eq expected1.name
      expect(@res1.result.value[:id]).to eq expected1.value["id"]
      expect(@res1.result.header.expire).to eq expected1.header.expire
      expect(@res1.result.header.time).to eq expected1.header.time
      expect(@res1.result.header.pubkey).to eq expected1.header.pubkey

      # 2
      pr2 = TonSdk::Abi::ParamsOfDecodeMessage.new(
        abi: abi1,
        message: "te6ccgEBAQEAVQAApeACvg5/pmQpY4m61HmJ0ne+zjHJu3MNG8rJxUDLbHKBu/AAAAAAAAAMJL6z6ro48sYvAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABA"
      )
      expect { |b| TonSdk::Abi.decode_message(@c_ctx.context, pr2, &b) }.to yield_control
      TonSdk::Abi.decode_message(@c_ctx.context, pr2) { |a| @res2 = a }

      expected2 = TonSdk::Abi::DecodedMessageBody.new(
        body_type: :event,
        name: "EventThrown",
        value: {id: "0x0"},
      )

      expect(@res2.success?).to eq true
      expect(@res2.result.body_type).to eq expected2.body_type
      expect(@res2.result.name).to eq expected2.name
      expect(@res2.result.value[:id]).to eq expected2.value["id"]
      expect(@res2.result.header).to eq expected2.header


      # 3
      pr3 = TonSdk::Abi::ParamsOfDecodeMessageBody.new(
        abi: abi1,
        body: "te6ccgEBAgEAlgAB4a3f2/jCeWWvgMoAXOakv3VSD56sQrDPT76n1cbrSvpZ0BCs0KEUy2Duvo3zPExePONW3TYy0MCA1i+FFRXcSIXTHxAj/Hd67jWQF7peccWoU/dbMCBJBB6YdPCVZcJlJkAAAF0ZyXLg19VzGQVviwSgAQBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
        is_internal: false
      )
      expect { |b| TonSdk::Abi.decode_message_body(@c_ctx.context, pr3, &b) }.to yield_control
      TonSdk::Abi.decode_message_body(@c_ctx.context, pr3) { |a| @res3 = a }

      expected3 = TonSdk::Abi::DecodedMessageBody.new(
        body_type: :input,
        name: "returnValue",
        value: {id: "0x0"},
        header: TonSdk::Abi::FunctionHeader.new(
          expire: 1599458404,
          time: 1599458364291,
          pubkey: "4c7c408ff1ddebb8d6405ee979c716a14fdd6cc08124107a61d3c25597099499",
        )
      )

      expect(@res3.success?).to eq true
      expect(@res3.result.body_type).to eq expected3.body_type
      expect(@res3.result.name).to eq expected3.name
      expect(@res3.result.value[:id]).to eq expected3.value["id"]
      expect(@res3.result.header.expire).to eq expected3.header.expire
      expect(@res3.result.header.time).to eq expected3.header.time
      expect(@res3.result.header.pubkey).to eq expected3.header.pubkey


      # 4
      pr4 = TonSdk::Abi::ParamsOfDecodeMessage.new(
        abi: abi1,
        message: "te6ccgEBAQEAVQAApeACvg5/pmQpY4m61HmJ0ne+zjHJu3MNG8rJxUDLbHKBu/AAAAAAAAAMKr6z6rxK3xYJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABA",
      )
      expect { |b| TonSdk::Abi.decode_message(@c_ctx.context, pr4, &b) }.to yield_control
      TonSdk::Abi.decode_message(@c_ctx.context, pr4) { |a| @res4 = a }

      expected4 = TonSdk::Abi::DecodedMessageBody.new(
        body_type: :output,
        name: "returnValue",
        value: {"value0": "0x0"},
      )

      expect(@res4.success?).to eq true
      expect(@res4.result.body_type).to eq expected4.body_type
      expect(@res4.result.name).to eq expected4.name
      expect(@res4.result.value[:value0]).to eq expected4.value["value0"]
      expect(@res4.result.header).to eq expected4.header
    end
  end
end