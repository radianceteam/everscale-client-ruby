require_relative './examples_helper.rb'

# TODO

WALLET_ADDRESS =  "0:2bb4a0e8391e7ea8877f4825064924bd41ce110fce97e939d3323999e1efbb13"
GIVER_ADDRESS = "0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94"


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
      "comment": "howdy!!!1".bytes.map { |x| '%02X' % (x & 0xFF) }.join
    }
  ),
  is_internal: true,
  signer: TonSdk::Abi::Signer.new(type_: :none)
)

TonSdk::Abi::encode_message_body(@graphql_c_ctx.context, pr_s) do |res|
  if res.success?
    cont_json2 = File.read("#{EXAMPLES_DATA_DIR}/contracts/abi_v2/SetcodeMultisigWallet.abi.json")
    abi2 = TonSdk::Abi::Abi.new(
      type_: :contract,
      value: TonSdk::Abi::AbiContract.from_json(JSON.parse(cont_json2))
    )

    keys = nil
    TonSdk::Crypto::generate_random_sign_keys(@c_ctx.context) do |res|
      if res.success?
        keys = res.result
      end
    end
    sleep(0.1) until keys

    enc_pr_s = TonSdk::Abi::ParamsOfEncodeMessage.new(
      abi: abi2,
      # address: GIVER_ADDRESS,
      address: WALLET_ADDRESS,

      call_set: TonSdk::Abi::CallSet.new(
        function_name: "sendTransaction",
        input: {
          # "dest": WALLET_ADDRESS,
          "dest": GIVER_ADDRESS,

          "value": 12345,
          "bounce": false,
          "flags": 3,
          "payload": res.result.body
        }
      ),
      signer: TonSdk::Abi::Signer.new(type_: :keys, keys: keys)
    )

    pr_s2 = ParamsOfProcessMessage.new(
      message_encode_params: enc_pr_s,

      # send_events: true
      send_events: false
    )

    cb = Proc.new do |a|
      puts "message: #{a}"
    end

    TonSdk::Processing::process_message(@graphql_c_ctx.context, pr_s2, cb) do |res2|
      if res2.success?
        puts "process_message result: #{res2.result}"
      else
        puts "error process_message #{res2.error}"
      end
    end


  else
    puts "error encode_message_body #{res.error}"
  end
end
