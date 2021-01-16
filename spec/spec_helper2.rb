require 'base64'

CONTRACTS_PATH = "data/contracts"
TESTS_DATA_DIR = "spec/data/"
ASYNC_OPERATION_TIMEOUT_SECONDS = 5
GIVER_ADDRESS = "0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94"
AMOUNT_FROM_GIVER = 500000000

module AbiVersion
  V1 = "abi_v1"
  V2 = "abi_v2"
end

def get_now_for_async_operation() = Process.clock_gettime(Process::CLOCK_MONOTONIC)

def get_timeout_for_async_operation() = Process.clock_gettime(Process::CLOCK_MONOTONIC) + ASYNC_OPERATION_TIMEOUT_SECONDS

def b64_from_hex(hex_digest) = [[hex_digest].pack("H*")].pack("m0")

def load_abi(name:, abi_version:)
  cont_json = File.read("#{TESTS_DATA_DIR}/contracts/#{abi_version}/#{name}.abi.json")
  TonSdk::Abi::Abi.new(
    type_: :contract,
    value: TonSdk::Abi::AbiContract.from_json(JSON.parse(cont_json))
  )
end

def load_tvc(name:, abi_version:)
  tvc_cont_bin = IO.binread("#{TESTS_DATA_DIR}/contracts/#{abi_version}/#{name}.tvc")
  Base64::strict_encode64(tvc_cont_bin)
end

def get_grams_from_giver(ctx, to_address)
  abi = load_abi(name: "Giver", abi_version: AbiVersion::V1)
  input = {
    "dest": to_address,
    "amount": AMOUNT_FROM_GIVER
  }.to_json

  par_enc_msg = TonSdk::Abi::ParamsOfEncodeMessage.new(
    address: GIVER_ADDRESS,
    abi: abi,
    call_set: TonSdk::Abi::CallSet.new(
      function_name: "sendGrams",
      input: input,
    ),
    signer: TonSdk::Abi::Signer.new(type_: :none)
  )

  pr_s = TonSdk::Processing::ParamsOfProcessMessage.new(
    message_encode_params: par_enc_msg,
    send_events: false
  )

  TonSdk::Processing::process_message(ctx, pr_s) do |res|
    if res.success?
      res.result.out_messages.map do |msg|
        # TODO
        Boc.parse_message(ctx, TonSdk::Boc::ParamsOfParse.new(msg))
      end
    else
      raise SdkError.new(message: res.error)
    end
  end
end
