require 'spec_helper'
require 'json'
require 'base64'

describe EverSdk::Abi do
  context "methods of abi" do
    it "#encode_v2" do
      abi = load_abi(name: "Events")
      tvc = load_tvc(name: "Events")
      keys = EverSdk::Crypto::KeyPair.new(
        public_: "4c7c408ff1ddebb8d6405ee979c716a14fdd6cc08124107a61d3c25597099499",
        secret: "cc8929d635719612a9478b9cd17675a39cfad52d8959e8a177389b8c0b9122a7"
      )
      time = 1599458364291
      expire = 1599458404
      signing_box = test_client.request("crypto.get_signing_box", keys)

      # check deploy params

      signing = EverSdk::Abi::Signer.new(type_: :external, public_key: keys.public_)
      deploy_params = EverSdk::Abi::ParamsOfEncodeMessage.new(
        abi: abi,
        deploy_set: EverSdk::Abi::DeploySet.new(
          tvc: tvc
        ),
        call_set: EverSdk::Abi::CallSet.new(
          function_name: "constructor",
          header: EverSdk::Abi::FunctionHeader.new(
            pubkey: keys.public_,
            time: time,
            expire: expire
          )
        ),
        signer: signing
      )
      unsigned = test_client.request("abi.encode_message", deploy_params)

      expect(unsigned.message).to eq "te6ccgECFwEAA2gAAqeIAAt9aqvShfTon7Lei1PVOhUEkEEZQkhDKPgNyzeTL6YSEZTHxAj/Hd67jWQF7peccWoU/dbMCBJBB6YdPCVZcJlJkAAAF0ZyXLg19VzGRotV8/gGAQEBwAICA88gBQMBAd4EAAPQIABB2mPiBH+O713GsgL3S844tQp+62YECSCD0w6eEqy4TKTMAib/APSkICLAAZL0oOGK7VNYMPShCQcBCvSkIPShCAAAAgEgDAoByP9/Ie1E0CDXScIBjhDT/9M/0wDRf/hh+Gb4Y/hijhj0BXABgED0DvK91wv/+GJw+GNw+GZ/+GHi0wABjh2BAgDXGCD5AQHTAAGU0/8DAZMC+ELiIPhl+RDyqJXTAAHyeuLTPwELAGqOHvhDIbkgnzAg+COBA+iogggbd0Cgud6S+GPggDTyNNjTHwH4I7zyudMfAfAB+EdukvI83gIBIBINAgEgDw4AvbqLVfP/hBbo417UTQINdJwgGOENP/0z/TANF/+GH4Zvhj+GKOGPQFcAGAQPQO8r3XC//4YnD4Y3D4Zn/4YeLe+Ebyc3H4ZtH4APhCyMv/+EPPCz/4Rs8LAMntVH/4Z4AgEgERAA5biABrW/CC3Rwn2omhp/+mf6YBov/ww/DN8Mfwxb30gyupo6H0gb+j8IpA3SRg4b3whXXlwMnwAZGT9ghBkZ8KEZ0aCBAfQAAAAAAAAAAAAAAAAACBni2TAgEB9gBh8IWRl//wh54Wf/CNnhYBk9qo//DPAAxbmTwqLfCC3Rwn2omhp/+mf6YBov/ww/DN8Mfwxb2uG/8rqaOhp/+/o/ABkRe4AAAAAAAAAAAAAAAAIZ4tnwOfI48sYvRDnhf/kuP2AGHwhZGX//CHnhZ/8I2eFgGT2qj/8M8AIBSBYTAQm4t8WCUBQB/PhBbo4T7UTQ0//TP9MA0X/4Yfhm+GP4Yt7XDf+V1NHQ0//f0fgAyIvcAAAAAAAAAAAAAAAAEM8Wz4HPkceWMXohzwv/yXH7AMiL3AAAAAAAAAAAAAAAABDPFs+Bz5JW+LBKIc8L/8lx+wAw+ELIy//4Q88LP/hGzwsAye1UfxUABPhnAHLccCLQ1gIx0gAw3CHHAJLyO+Ah1w0fkvI84VMRkvI74cEEIoIQ/////byxkvI84AHwAfhHbpLyPN4="
      expect(unsigned.data_to_sign).to eq "KCGM36iTYuCYynk+Jnemis+mcwi3RFCke95i7l96s4Q="

      signature = test_client.sign_detached(data: unsigned.data_to_sign, keys: keys)

      expect(signature).to eq("6272357bccb601db2b821cb0f5f564ab519212d242cf31961fe9a3c50a30b236012618296b4f769355c0e9567cd25b366f3c037435c498c82e5305622adbc70e")

      signed = test_client.request(
        "abi.attach_signature",
        EverSdk::Abi::ParamsOfAttachSignature.new(
          abi: abi,
          public_key: keys.public_,
          message: unsigned.message,
          signature: signature
        )
      )

      expect(signed.message).to eq("te6ccgECGAEAA6wAA0eIAAt9aqvShfTon7Lei1PVOhUEkEEZQkhDKPgNyzeTL6YSEbAHAgEA4bE5Gr3mWwDtlcEOWHr6slWoyQlpIWeYyw/00eKFGFkbAJMMFLWnu0mq4HSrPmktmzeeAboa4kxkFymCsRVt44dTHxAj/Hd67jWQF7peccWoU/dbMCBJBB6YdPCVZcJlJkAAAF0ZyXLg19VzGRotV8/gAQHAAwIDzyAGBAEB3gUAA9AgAEHaY+IEf47vXcayAvdLzji1Cn7rZgQJIIPTDp4SrLhMpMwCJv8A9KQgIsABkvSg4YrtU1gw9KEKCAEK9KQg9KEJAAACASANCwHI/38h7UTQINdJwgGOENP/0z/TANF/+GH4Zvhj+GKOGPQFcAGAQPQO8r3XC//4YnD4Y3D4Zn/4YeLTAAGOHYECANcYIPkBAdMAAZTT/wMBkwL4QuIg+GX5EPKoldMAAfJ64tM/AQwAao4e+EMhuSCfMCD4I4ED6KiCCBt3QKC53pL4Y+CANPI02NMfAfgjvPK50x8B8AH4R26S8jzeAgEgEw4CASAQDwC9uotV8/+EFujjXtRNAg10nCAY4Q0//TP9MA0X/4Yfhm+GP4Yo4Y9AVwAYBA9A7yvdcL//hicPhjcPhmf/hh4t74RvJzcfhm0fgA+ELIy//4Q88LP/hGzwsAye1Uf/hngCASASEQDluIAGtb8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFvfSDK6mjofSBv6PwikDdJGDhvfCFdeXAyfABkZP2CEGRnwoRnRoIEB9AAAAAAAAAAAAAAAAAAIGeLZMCAQH2AGHwhZGX//CHnhZ/8I2eFgGT2qj/8M8ADFuZPCot8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFva4b/yupo6Gn/7+j8AGRF7gAAAAAAAAAAAAAAAAhni2fA58jjyxi9EOeF/+S4/YAYfCFkZf/8IeeFn/wjZ4WAZPaqP/wzwAgFIFxQBCbi3xYJQFQH8+EFujhPtRNDT/9M/0wDRf/hh+Gb4Y/hi3tcN/5XU0dDT/9/R+ADIi9wAAAAAAAAAAAAAAAAQzxbPgc+Rx5YxeiHPC//JcfsAyIvcAAAAAAAAAAAAAAAAEM8Wz4HPklb4sEohzwv/yXH7ADD4QsjL//hDzws/+EbPCwDJ7VR/FgAE+GcActxwItDWAjHSADDcIccAkvI74CHXDR+S8jzhUxGS8jvhwQQighD////9vLGS8jzgAfAB+EdukvI83g==")

      deploy_params.signer = EverSdk::Abi::Signer.new(type_: :keys, keys: keys)
      signed = test_client.request("abi.encode_message", deploy_params)

      expect(signed.message).to eq("te6ccgECGAEAA6wAA0eIAAt9aqvShfTon7Lei1PVOhUEkEEZQkhDKPgNyzeTL6YSEbAHAgEA4bE5Gr3mWwDtlcEOWHr6slWoyQlpIWeYyw/00eKFGFkbAJMMFLWnu0mq4HSrPmktmzeeAboa4kxkFymCsRVt44dTHxAj/Hd67jWQF7peccWoU/dbMCBJBB6YdPCVZcJlJkAAAF0ZyXLg19VzGRotV8/gAQHAAwIDzyAGBAEB3gUAA9AgAEHaY+IEf47vXcayAvdLzji1Cn7rZgQJIIPTDp4SrLhMpMwCJv8A9KQgIsABkvSg4YrtU1gw9KEKCAEK9KQg9KEJAAACASANCwHI/38h7UTQINdJwgGOENP/0z/TANF/+GH4Zvhj+GKOGPQFcAGAQPQO8r3XC//4YnD4Y3D4Zn/4YeLTAAGOHYECANcYIPkBAdMAAZTT/wMBkwL4QuIg+GX5EPKoldMAAfJ64tM/AQwAao4e+EMhuSCfMCD4I4ED6KiCCBt3QKC53pL4Y+CANPI02NMfAfgjvPK50x8B8AH4R26S8jzeAgEgEw4CASAQDwC9uotV8/+EFujjXtRNAg10nCAY4Q0//TP9MA0X/4Yfhm+GP4Yo4Y9AVwAYBA9A7yvdcL//hicPhjcPhmf/hh4t74RvJzcfhm0fgA+ELIy//4Q88LP/hGzwsAye1Uf/hngCASASEQDluIAGtb8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFvfSDK6mjofSBv6PwikDdJGDhvfCFdeXAyfABkZP2CEGRnwoRnRoIEB9AAAAAAAAAAAAAAAAAAIGeLZMCAQH2AGHwhZGX//CHnhZ/8I2eFgGT2qj/8M8ADFuZPCot8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFva4b/yupo6Gn/7+j8AGRF7gAAAAAAAAAAAAAAAAhni2fA58jjyxi9EOeF/+S4/YAYfCFkZf/8IeeFn/wjZ4WAZPaqP/wzwAgFIFxQBCbi3xYJQFQH8+EFujhPtRNDT/9M/0wDRf/hh+Gb4Y/hi3tcN/5XU0dDT/9/R+ADIi9wAAAAAAAAAAAAAAAAQzxbPgc+Rx5YxeiHPC//JcfsAyIvcAAAAAAAAAAAAAAAAEM8Wz4HPklb4sEohzwv/yXH7ADD4QsjL//hDzws/+EbPCwDJ7VR/FgAE+GcActxwItDWAjHSADDcIccAkvI74CHXDR+S8jzhUxGS8jvhwQQighD////9vLGS8jzgAfAB+EdukvI83g==")

      deploy_params.signer = EverSdk::Abi::Signer.new(type_: :signing_box, handle: signing_box.handle)
      signed_with_box = test_client.request("abi.encode_message", deploy_params)

      expect(signed_with_box.message).to eq("te6ccgECGAEAA6wAA0eIAAt9aqvShfTon7Lei1PVOhUEkEEZQkhDKPgNyzeTL6YSEbAHAgEA4bE5Gr3mWwDtlcEOWHr6slWoyQlpIWeYyw/00eKFGFkbAJMMFLWnu0mq4HSrPmktmzeeAboa4kxkFymCsRVt44dTHxAj/Hd67jWQF7peccWoU/dbMCBJBB6YdPCVZcJlJkAAAF0ZyXLg19VzGRotV8/gAQHAAwIDzyAGBAEB3gUAA9AgAEHaY+IEf47vXcayAvdLzji1Cn7rZgQJIIPTDp4SrLhMpMwCJv8A9KQgIsABkvSg4YrtU1gw9KEKCAEK9KQg9KEJAAACASANCwHI/38h7UTQINdJwgGOENP/0z/TANF/+GH4Zvhj+GKOGPQFcAGAQPQO8r3XC//4YnD4Y3D4Zn/4YeLTAAGOHYECANcYIPkBAdMAAZTT/wMBkwL4QuIg+GX5EPKoldMAAfJ64tM/AQwAao4e+EMhuSCfMCD4I4ED6KiCCBt3QKC53pL4Y+CANPI02NMfAfgjvPK50x8B8AH4R26S8jzeAgEgEw4CASAQDwC9uotV8/+EFujjXtRNAg10nCAY4Q0//TP9MA0X/4Yfhm+GP4Yo4Y9AVwAYBA9A7yvdcL//hicPhjcPhmf/hh4t74RvJzcfhm0fgA+ELIy//4Q88LP/hGzwsAye1Uf/hngCASASEQDluIAGtb8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFvfSDK6mjofSBv6PwikDdJGDhvfCFdeXAyfABkZP2CEGRnwoRnRoIEB9AAAAAAAAAAAAAAAAAAIGeLZMCAQH2AGHwhZGX//CHnhZ/8I2eFgGT2qj/8M8ADFuZPCot8ILdHCfaiaGn/6Z/pgGi//DD8M3wx/DFva4b/yupo6Gn/7+j8AGRF7gAAAAAAAAAAAAAAAAhni2fA58jjyxi9EOeF/+S4/YAYfCFkZf/8IeeFn/wjZ4WAZPaqP/wzwAgFIFxQBCbi3xYJQFQH8+EFujhPtRNDT/9M/0wDRf/hh+Gb4Y/hi3tcN/5XU0dDT/9/R+ADIi9wAAAAAAAAAAAAAAAAQzxbPgc+Rx5YxeiHPC//JcfsAyIvcAAAAAAAAAAAAAAAAEM8Wz4HPklb4sEohzwv/yXH7ADD4QsjL//hDzws/+EbPCwDJ7VR/FgAE+GcActxwItDWAjHSADDcIccAkvI74CHXDR+S8jzhUxGS8jvhwQQighD////9vLGS8jzgAfAB+EdukvI83g==")

      # check run params

      address = "0:05beb555e942fa744fd96f45a9ea9d0a8248208ca12421947c06e59bc997d309"
      run_params = EverSdk::Abi::ParamsOfEncodeMessage.new(
        address: address,
        abi: abi,
        call_set: EverSdk::Abi::CallSet.new(
          function_name: "returnValue",
          header: EverSdk::Abi::FunctionHeader.new(
            time: time,
            expire: expire
          ),
          input: {id: "0"}
        ),
        signer: signing
      )
      body_params = EverSdk::Abi::ParamsOfEncodeMessageBody.new(
        abi: abi,
        call_set: run_params.call_set,
        is_internal: false,
        signer: signing
      )
      extract_body = Proc.new do |message|
        unsigned_parsed = test_client.request(
          "boc.parse_message",
          EverSdk::Boc::ParamsOfParse.new(boc: message)
        )
        unsigned_parsed.parsed["body"]
      end

      unsigned_message = "te6ccgEBAgEAeAABpYgAC31qq9KF9Oifst6LU9U6FQSQQRlCSEMo+A3LN5MvphIFMfECP8d3ruNZAXul5xxahT91swIEkEHph08JVlwmUmQAAAXRnJcuDX1XMZBW+LBKAQBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
      signed_message = "te6ccgEBAwEAvAABRYgAC31qq9KF9Oifst6LU9U6FQSQQRlCSEMo+A3LN5MvphIMAQHhrd/b+MJ5Za+AygBc5qS/dVIPnqxCsM9PvqfVxutK+lnQEKzQoRTLYO6+jfM8TF4841bdNjLQwIDWL4UVFdxIhdMfECP8d3ruNZAXul5xxahT91swIEkEHph08JVlwmUmQAAAXRnJcuDX1XMZBW+LBKACAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
      data_to_sign = "i4Hs3PB12QA9UBFbOIpkG3JerHHqjm4LgvF4MA7TDsY="

      # encoding unsigned and attaching the signature

      unsigned = test_client.request("abi.encode_message", run_params)

      expect(unsigned.message).to eq(unsigned_message)
      expect(unsigned.data_to_sign).to eq(data_to_sign)

      unsigned_body = extract_body.call(unsigned.message)
      unsigned_body_encoded = test_client.request("abi.encode_message_body", body_params)

      expect(unsigned_body_encoded.body).to eq(unsigned_body)
      expect(unsigned_body_encoded.data_to_sign).to eq(unsigned.data_to_sign)

      signature = test_client.sign_detached(data: unsigned.data_to_sign, keys: keys)

      expect(signature).to eq("5bbfb7f184f2cb5f019400b9cd497eeaa41f3d5885619e9f7d4fab8dd695f4b3a02159a1422996c1dd7d1be67898bc79c6adba6c65a18101ac5f0a2a2bb8910b")

      signed = test_client.request(
        "abi.attach_signature",
        EverSdk::Abi::ParamsOfAttachSignature.new(
          abi: abi,
          public_key: keys.public_,
          message: unsigned.message,
          signature: signature
        )
      )

      expect(signed.message).to eq(signed_message)

      signed_body = extract_body.call(signed.message)
      signed = test_client.request(
        "abi.attach_signature_to_message_body",
        EverSdk::Abi::ParamsOfAttachSignatureToMessageBody.new(
          abi: abi,
          public_key: keys.public_,
          message: unsigned_body_encoded.body,
          signature: signature
        )
      )

      expect(signed.body).to eq(signed_body)

      # encoding signed

      run_params.signer = EverSdk::Abi::Signer.new(type_: :keys, keys: keys)
      signed = test_client.request(
        "abi.encode_message",
        run_params
      )

      expect(signed.message).to eq(signed_message)

      body_params.signer = EverSdk::Abi::Signer.new(type_: :keys, keys: keys)
      signed = test_client.request(
        "abi.encode_message_body",
        body_params
      )

      expect(signed.body).to eq(signed_body)

      run_params.signer = EverSdk::Abi::Signer.new(type_: :signing_box, handle: signing_box.handle)
      signed = test_client.request(
        "abi.encode_message",
        run_params
      )

      expect(signed.message).to eq(signed_message)

      body_params.signer = EverSdk::Abi::Signer.new(type_: :signing_box, handle: signing_box.handle)
      signed = test_client.request(
        "abi.encode_message_body",
        body_params
      )

      expect(signed.body).to eq(signed_body)

      run_params.signer = EverSdk::Abi::Signer.new(type_: :none)
      no_pubkey = test_client.request(
        "abi.encode_message",
        run_params
      )

      expect(no_pubkey.message).to eq("te6ccgEBAQEAVQAApYgAC31qq9KF9Oifst6LU9U6FQSQQRlCSEMo+A3LN5MvphIAAAAC6M5Llwa+q5jIK3xYJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB")

      body_params.signer = EverSdk::Abi::Signer.new(type_: :none)
      no_pubkey_body = test_client.request(
        "abi.encode_message_body",
        body_params
      )

      expect(no_pubkey_body.body).to eq(extract_body.call(no_pubkey.message))
    end

    it "#decode_v2" do
      abi = load_abi(name: "Events")

      decode_events = Proc.new do |message|
        result = test_client.request(
          "abi.decode_message",
          EverSdk::Abi::ParamsOfDecodeMessage.new(
            abi: abi,
            message: message
          )
        )
        parsed = test_client.request(
          "boc.parse_message",
          EverSdk::Boc::ParamsOfParse.new(
            boc: message
          )
        )
        body = parsed.parsed["body"]
        result_body = test_client.request(
          "abi.decode_message_body",
          EverSdk::Abi::ParamsOfDecodeMessageBody.new(
            abi: abi,
            body: body,
            is_internal: parsed.parsed["msg_type_name"] == "Internal"
          )
        )
        expect(result.to_h).to eq(result_body.to_h)
        result
      end

      match_events = Proc.new do |expected, actual|
        expect(expected.to_h.to_json).to eq(actual.to_h.to_json)
      end

      expected = EverSdk::Abi::DecodedMessageBody.new(
        body_type: :input,
        name: "returnValue",
        value: {id: '0x0000000000000000000000000000000000000000000000000000000000000000'},
        header: EverSdk::Abi::FunctionHeader.new(
          expire: 1599458404,
          time: 1599458364291,
          pubkey: "4c7c408ff1ddebb8d6405ee979c716a14fdd6cc08124107a61d3c25597099499"
        )
      )

      match_events.call(expected, decode_events.call("te6ccgEBAwEAvAABRYgAC31qq9KF9Oifst6LU9U6FQSQQRlCSEMo+A3LN5MvphIMAQHhrd/b+MJ5Za+AygBc5qS/dVIPnqxCsM9PvqfVxutK+lnQEKzQoRTLYO6+jfM8TF4841bdNjLQwIDWL4UVFdxIhdMfECP8d3ruNZAXul5xxahT91swIEkEHph08JVlwmUmQAAAXRnJcuDX1XMZBW+LBKACAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="))

      expected = EverSdk::Abi::DecodedMessageBody.new(
        body_type: :event,
        name: "EventThrown",
        value: {id: '0x0000000000000000000000000000000000000000000000000000000000000000'}
      )

      match_events.call(expected, decode_events.call("te6ccgEBAQEAVQAApeACvg5/pmQpY4m61HmJ0ne+zjHJu3MNG8rJxUDLbHKBu/AAAAAAAAAMJL6z6ro48sYvAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABA"))

      result = test_client.request(
        "abi.decode_message_body",
        EverSdk::Abi::ParamsOfDecodeMessageBody.new(
          abi: abi,
          body: "te6ccgEBAgEAlgAB4a3f2/jCeWWvgMoAXOakv3VSD56sQrDPT76n1cbrSvpZ0BCs0KEUy2Duvo3zPExePONW3TYy0MCA1i+FFRXcSIXTHxAj/Hd67jWQF7peccWoU/dbMCBJBB6YdPCVZcJlJkAAAF0ZyXLg19VzGQVviwSgAQBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
          is_internal: false
        )
      )
      expected = EverSdk::Abi::DecodedMessageBody.new(
        body_type: :input,
        name: "returnValue",
        value: {id: '0x0000000000000000000000000000000000000000000000000000000000000000'},
        header: EverSdk::Abi::FunctionHeader.new(
          expire: 1599458404,
          time: 1599458364291,
          pubkey: "4c7c408ff1ddebb8d6405ee979c716a14fdd6cc08124107a61d3c25597099499"
        )
      )

      match_events.call(expected, result)

      expected = EverSdk::Abi::DecodedMessageBody.new(
        body_type: :output,
        name: "returnValue",
        value: {value0: '0x0000000000000000000000000000000000000000000000000000000000000000'}
      )

      match_events.call(expected, decode_events.call("te6ccgEBAQEAVQAApeACvg5/pmQpY4m61HmJ0ne+zjHJu3MNG8rJxUDLbHKBu/AAAAAAAAAMKr6z6rxK3xYJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABA"))
    end

    it "#decode_update_initial_data" do
      initdata_abi_json = File.read("#{TESTS_DATA_DIR}/contracts/abi_v2/t24_initdata.abi.json")
      abi = EverSdk::Abi::Abi.new(
        type_: :json,
        value: EverSdk::Abi::AbiContract.from_json(JSON.parse(initdata_abi_json)).to_h.to_json
      )
      initdata_tvc = File.read("#{TESTS_DATA_DIR}/contracts/abi_v2/t24_initdata.tvc", mode: "rb")
      tvc = Base64.strict_encode64(initdata_tvc)

      # Get and decode contract initial data
      params = EverSdk::Boc::ParamsOfDecodeTvc.new(tvc: tvc)
      EverSdk::Boc.decode_tvc(@c_ctx.context, params) { |r| @response = r }
      data = @response.result.data
      params = EverSdk::Abi::ParamsOfDecodeInitialData.new(data: data, abi: abi)
      EverSdk::Abi.decode_initial_data(@c_ctx.context, params) { |r| @response = r }
      decoded = @response.result

      expect(decoded.initial_pubkey).to eq('00' * 32)
      expect(decoded.initial_data).to eq({})

      encode_initial_data = 'te6ccgEBBwEARwABAcABAgPPoAQCAQFIAwAWc29tZSBzdHJpbmcCASAGBQADHuAAQQiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIoA=='

      # Update initial data
      initial_data = {'a': "123", 's': 'some string'}
      initial_pubkey = '22' * 32
      params = EverSdk::Abi::ParamsOfUpdateInitialData.new(
        data: data, abi: abi, initial_data: initial_data, initial_pubkey: initial_pubkey
      )
      EverSdk::Abi.update_initial_data(@c_ctx.context, params) { |r| @response = r }
      data_updated = @response.result.data

      expect(data_updated).to eq(encode_initial_data)

      result = test_client.request(
        "abi.encode_initial_data",
        EverSdk::Abi::ParamsOfEncodeInitialData.new(
          abi: abi,
          initial_data: initial_data,
          initial_pubkey: initial_pubkey,
          boc_cache: nil
        )
      )

      expect(result.data).to eq(encode_initial_data)

      # Decode updated data
      params = EverSdk::Abi::ParamsOfDecodeInitialData.new(data: data_updated, abi: abi)
      EverSdk::Abi.decode_initial_data(@c_ctx.context, params) { |r| @response = r }
      decoded = @response.result

      expect(decoded.initial_data['a']).to eq(initial_data[:a])
      expect(decoded.initial_data['s']).to eq(initial_data[:s])
      expect(decoded.initial_pubkey).to eq(initial_pubkey)
    end

    it "test_decode_account_data" do
      abi = EverSdk::Abi::Abi.new(type_: :json, value: '{
	"ABI version": 2,
	"version": "2.1",
	"header": ["time"],
	"functions": [],
	"data": [],
	"events": [],
	"fields": [
		{"name":"__pubkey","type":"uint256"},
		{"name":"__timestamp","type":"uint64"},
		{"name":"fun","type":"uint32"},
		{"name":"opt","type":"optional(bytes)"},
        {
            "name":"big",
            "type":"optional(tuple)",
            "components":[
                {"name":"value0","type":"uint256"},
                {"name":"value1","type":"uint256"},
                {"name":"value2","type":"uint256"},
                {"name":"value3","type":"uint256"}
            ]
        },
		{"name":"a","type":"bytes"},
		{"name":"b","type":"bytes"},
		{"name":"length","type":"uint256"}
	]
}')
      data = "te6ccgEBBwEA8AAEWeix2Dmr4nsqu51KKUOpFDqcfirgZ5m9JN7B16iJGuXdAAABeqRZIJYAAAAW4AYEAwEBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPAgAAABRJIGxpa2UgaXQuAcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIFAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKSGVsbG8="

      decoded = test_client.request(
        "abi.decode_account_data",
        EverSdk::Abi::ParamsOfDecodeAccountData.new(abi: abi, data: data)
      ).data

      expect(decoded).to eq({
                              "__pubkey" => "0xe8b1d839abe27b2abb9d4a2943a9143a9c7e2ae06799bd24dec1d7a8891ae5dd",
                              "__timestamp" => "1626254942358",
                              "fun" => "22",
                              "opt" => "48656c6c6f",
                              "big" => {
                                "value0" => "0x0000000000000000000000000000000000000000000000000000000000000002",
                                "value1" => "0x0000000000000000000000000000000000000000000000000000000000000008",
                                "value2" => "0x0000000000000000000000000000000000000000000000000000000000000002",
                                "value3" => "0x0000000000000000000000000000000000000000000000000000000000000000"
                              },
                              "a" => "49206c696b652069742e",
                              "b" => "",
                              "length" => "0x000000000000000000000000000000000000000000000000000000000000000f"
                            })
    end

    it "test_decode_boc" do
      boc = "te6ccgEBAgEAEgABCQAAAADAAQAQAAAAAAAAAHs="

      params = [
        EverSdk::Abi::AbiParam.new(
          name: "a",
          type_: "uint32"
        ),
        EverSdk::Abi::AbiParam.new(
          name: "b",
          type_: "ref(int64)"
        ),
        EverSdk::Abi::AbiParam.new(
          name: "c",
          type_: "bool"
        )
      ]

      decoded = test_client.request(
        "abi.decode_boc",
        EverSdk::Abi::ParamsOfDecodeBoc.new(
          boc: boc,
          params: params,
          allow_partial: false
        )
      ).data

      expect(decoded).to eq({"a"=>"0", "b"=>"123", "c"=>true})

      decoded = test_client.request(
        "abi.decode_boc",
        EverSdk::Abi::ParamsOfDecodeBoc.new(
          boc: boc,
          params: params[0..1],
          allow_partial: true
        )
      ).data

      expect(decoded).to eq({"a"=>"0", "b"=>"123"})
    end
  end
end
