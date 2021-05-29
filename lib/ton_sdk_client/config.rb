module TonSdk
  CryptoConfig = Struct.new(:mnemonic_dictionary, :mnemonic_word_count, :hdkey_derivation_path, keyword_init: true)
  BocConfig = Struct.new(:cache_max_size)
  NetworkConfig = Struct.new(
    :server_address,
    :endpoints,
    :network_retries_count,
    :message_retries_count,
    :message_processing_timeout,
    :wait_for_timeout,
    :out_of_sync_threshold,
    :reconnect_timeout,
    :max_reconnect_timeout,
    :sending_endpoint_count,
    :latency_detection_interval,
    :max_latency,
    :access_key,
    keyword_init: true
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
      access_key: nil
    )
      super
    end
  end

  AbiConfig = Struct.new(
    :workchain,
    :message_expiration_timeout,
    :message_expiration_timeout_grow_factor,
    keyword_init: true
  ) do
    def initialize(
      workchain: nil,
      message_expiration_timeout: 40000,
      message_expiration_timeout_grow_factor: 1.5
    )
      super
    end
  end

  ClientConfig = Struct.new(:network, :crypto, :abi, :boc, keyword_init: true) do
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
