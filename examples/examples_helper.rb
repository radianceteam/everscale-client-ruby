require 'base64'
require_relative '../lib/ever_sdk_client.rb'

PRINT_RESULT_MAX_LEN = 500
EXAMPLES_DATA_DIR = "examples/data"

def cut_off_long_string(s)
  s2 = s[0..PRINT_RESULT_MAX_LEN]
  "#{s2} ...<cut off>"
end

cfg = EverSdk::ClientConfig.new(
  network: EverSdk::NetworkConfig.new(
    endpoints: ["net.ton.dev"]
  )
)
@c_ctx = EverSdk::ClientContext.new(cfg.to_h.to_json)

graphql_cfg = EverSdk::ClientConfig.new(
  network: EverSdk::NetworkConfig.new(
    endpoints: ["net.ton.dev/graphql"]
  )
)
@graphql_c_ctx = EverSdk::ClientContext.new(graphql_cfg.to_h.to_json)
