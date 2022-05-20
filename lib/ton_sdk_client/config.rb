module TonSdk
  CryptoConfig = KwStruct.new(:mnemonic_dictionary, :mnemonic_word_count, :hdkey_derivation_path)
  BocConfig = KwStruct.new(:cache_max_size)
  NetworkConfig = KwStruct.new(
    :server_address,
    :endpoints,
    :network_retries_count,
    :max_reconnect_timeout,
    :reconnect_timeout,
    :message_retries_count,
    :message_processing_timeout,
    :wait_for_timeout,
    :out_of_sync_threshold,
    :sending_endpoint_count,
    :latency_detection_interval,
    :max_latency,
    :query_timeout,
    :queries_protocol,
    :access_key
  ) do
    def initialize(
      server_address: "",
      endpoints: [],
      network_retries_count: 5,
      max_reconnect_timeout: 120000,
      reconnect_timeout: 1000,
      message_retries_count: 5,
      message_processing_timeout: 40000,
      wait_for_timeout: 40000,
      out_of_sync_threshold: 15000,
      sending_endpoint_count: 2,
      latency_detection_interval: 60000,
      max_latency: 60000,
      query_timeout: 60000,
      queries_protocol: nil,
      access_key: nil
    )
      super
    end
  end

  module NetworkQueriesProtocol
    HTTP = "HTTP".freeze
    WS = "WS".freeze
  end

  AbiConfig = KwStruct.new(
    :workchain,
    :message_expiration_timeout,
    :message_expiration_timeout_grow_factor
  ) do
    def initialize(
      workchain: nil,
      message_expiration_timeout: 40000,
      message_expiration_timeout_grow_factor: 1.5
    )
      super
    end
  end

  ClientConfig = KwStruct.new(:network, :crypto, :abi, :boc) do
    def to_h
      res = super.to_h

      {
        network: res[:network]&.to_h,
        crypto: res[:crypto]&.to_h,
        abi: res[:abi]&.to_h,
        boc: res[:boc]&.to_h
      }
    end
  end
end
