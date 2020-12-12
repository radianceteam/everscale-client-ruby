require_relative './examples_helper.rb'


cont_json = File.read("#{EXAMPLES_DATA_DIR}/contracts/abi_v2/Transfer.abi.json")
abi1 = TonSdk::Abi::Abi.new(
  type_: :contract,
  value: TonSdk::Abi::AbiContract.from_json(JSON.parse(cont_json))
)

signing = TonSdk::Abi::Signer.new(type_: :external, public_key: keys.public_)
pr1 = TonSdk::Abi::ParamsOfEncodeMessage.new(
  abi: abi1,
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







cont_json = File.read("#{EXAMPLES_DATA_DIR}/contracts/abi_v2/Events.abi.json")
abi1 = TonSdk::Abi::Abi.new(
  type_: :contract,
  value: TonSdk::Abi::AbiContract.from_json(JSON.parse(cont_json))
)

tvc1_cont_bin = IO.binread("#{EXAMPLES_DATA_DIR}/contracts/abi_v2/Events.tvc")
tvc1 = Base64::strict_encode64(tvc1_cont_bin)


TonSdk::Crypto::generate_random_sign_keys(@c_ctx.context) do |res|
  if res.success?
    @keys = res.result
  end
end
