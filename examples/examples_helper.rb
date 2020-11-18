require 'base64'
require_relative '../lib/ton_sdk_client.rb'

PRINT_RESULT_MAX_LEN = 500
EXAMPLES_DATA_DIR = "examples/data"

cfg = TonSdk::ClientConfig.new(
  network: TonSdk::NetworkConfig.new(
    server_address: "net.ton.dev"
  )
)

@c_ctx = TonSdk::ClientContext.new(cfg.to_h.to_json)
