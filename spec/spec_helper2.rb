require 'base64'

CONTRACTS_PATH = "data/contracts"
TESTS_DATA_DIR = "spec/data"
ASYNC_OPERATION_TIMEOUT_SECONDS = 5
GIVER_ADDRESS = "0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94"
AMOUNT_FROM_GIVER = 500000000

module AbiVersion
  V1 = "abi_v1"
  V2 = "abi_v2"
end

class TestClient
  def initialize(config: nil)
    @config = config || default_config
  end

  def client_config
    @_client_config ||= EverSdk::ClientConfig.new(config)
  end

  def client_context
    @_client_context ||= EverSdk::ClientContext.new(client_config.to_h.to_json)
  end

  def sign_detached(data:, keys:)
    sign_keys = request(
      "crypto.nacl_sign_keypair_from_secret_key",
      EverSdk::Crypto::ParamsOfNaclSignKeyPairFromSecret.new(secret: keys.secret.dup)
    )
    result = request(
      "crypto.nacl_sign_detached",
      EverSdk::Crypto::ParamsOfNaclSignDetached.new(unsigned: data, secret: sign_keys.secret.dup)
    )
    result.signature
  end

  def request(function_name, params)
    klass_name = function_name.split(".").first
    method_ = function_name.split(".").last
    klass = Kernel.const_get("EverSdk::#{klass_name.capitalize}")
    klass.send(method_, client_context.context, params) { |r| @response = r }
    response = @response
    @response = nil

    return if response.nil?

    if response.success?
      response.result
    else
      response.error.message
    end
  end

  # Workaround for singlethreaded requests
  def request_no_params(function_name, **args)
    klass_name = function_name.split(".").first
    method_ = function_name.split(".").last
    klass = Kernel.const_get("EverSdk::#{klass_name.capitalize}")
    klass.send(method_, client_context.context, **args) { |r| @response = r }
    response = @response
    @response = nil
    if response.success?
      response.result
    else
      response.error.message
    end
  end

  private

  attr_reader :config

  def default_config
    {
      network: EverSdk::NetworkConfig.new(
        endpoints: ["net.ton.dev"]
      )
    }
  end
end

def test_client
  @_test_client ||= TestClient.new
end

def get_now_for_async_operation = Process.clock_gettime(Process::CLOCK_MONOTONIC)

def get_timeout_for_async_operation = Process.clock_gettime(Process::CLOCK_MONOTONIC) + ASYNC_OPERATION_TIMEOUT_SECONDS

def load_abi(name:, version: AbiVersion::V2)
  cont_json = File.read("#{TESTS_DATA_DIR}/contracts/#{version}/#{name}.abi.json")
  EverSdk::Abi::Abi.new(
    type_: :contract,
    value: EverSdk::Abi::AbiContract.from_json(JSON.parse(cont_json))
  )
end

def load_tvc(name:, version: AbiVersion::V2)
  tvc_cont_bin = IO.binread("#{TESTS_DATA_DIR}/contracts/#{version}/#{name}.tvc")
  Base64::strict_encode64(tvc_cont_bin)
end

def load_boc(name:)
  Base64.strict_encode64(IO.binread("#{TESTS_DATA_DIR}/boc/#{name}.boc"))
end

def get_grams_from_giver(ctx, to_address)
  abi = load_abi(name: "Giver", version: AbiVersion::V1)
  par_enc_msg = EverSdk::Abi::ParamsOfEncodeMessage.new(
    address: GIVER_ADDRESS,
    abi: abi,
    call_set: EverSdk::Abi::CallSet.new(
      function_name: "sendGrams",
      input: {
        dest: to_address,
        amount: AMOUNT_FROM_GIVER
      },
    ),
    signer: EverSdk::Abi::Signer.new(type_: :none)
  )

  params = EverSdk::Processing::ParamsOfProcessMessage.new(
    message_encode_params: par_enc_msg,
    send_events: false
  )

  EverSdk::Processing::process_message(ctx, params) do |res|
    if res.success?
      res.result.out_messages.map do |msg|
        Boc.parse_message(ctx, EverSdk::Boc::ParamsOfParse.new(msg))
      end
    else
      raise EverSdk::SdkError.new(message: res.error.message)
    end
  end
end
