require_relative './examples_helper.rb'

# TODO

cont_json = File.read("#{EXAMPLES_DATA_DIR}/contracts/abi_v2/Transfer.abi.json")
abi1 = TonSdk::Abi::Abi.new(
  type_: :contract,
  value: TonSdk::Abi::AbiContract.from_json(JSON.parse(cont_json))
)

pr_s = TonSdk::Abi::ParamsOfEncodeMessageBody.new(
  abi: abi1,
  call_set: TonSdk::Abi::CallSet.new(
    function_name: "transfer",
    input: {
      "comment": "howdy!!!1"
    }
  ),
  is_internal: true,
  signer: nil
)

TonSdk::Abi::encode_message_body(@graphql_c_ctx, pr_s) do |res|
  if res.success?
    cont_json2 = File.read("#{EXAMPLES_DATA_DIR}/contracts/abi_v2/SetcodeMultisigWallet.abi.json")
    abi2 = TonSdk::Abi::Abi.new(
      type_: :contract,
      value: TonSdk::Abi::AbiContract.from_json(JSON.parse(cont_json2))
    )

    enc_pr_s = TonSdk::Abi::ParamsOfEncodeMessage.new(
      abi: abi2,
      address: sen_addr,
      call_set: TonSdk::Abi::CallSet.new(
        function_name: "sendTransaction",
        input: {
          "dest": rec_addr,
          "value": 12345000,
          "bounce": false,
          "flags": 3,
          "payload": res.result
        }
      ),
      signer: TonSdk::Abi::Signer.new(type_: :keys, keys: keys)
    )

    pr_s2 = ParamsOfProcessMessage.new(
      message_encode_params: enc_pr_s,
      send_events: true
    )

    cb = Proc.new do |a|
      puts "message: #{a}"
    end

    TonSdk::Processing::process_message(@graphql_c_ctx, pr_s2, cb) do |res2|
      if res2.success?
        puts res2.result
      end
    end

  end
end
