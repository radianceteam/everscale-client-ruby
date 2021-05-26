module TonSdk
  ClientConfig = Struct.new(:network, :crypto, :abi, :boc, keyword_init: true) do
    def to_h
      {
        network: @network&.to_h,
        crypto: @crypto&.to_h,
        abi: @abi&.to_h,
        boc: @boc&.to_h
      }
    end
  end

  class NetworkConfig
    DEFAULT_NETWORK_RETRIES_COUNT = 5
    DEFAULT_MAX_RECONNECT_TIMEOUT = 120000
    DEFAULT_RECONNECT_TIMEOUT = 1000
    DEFAULT_MESSAGE_RETRIES_COUNT = 5

    DEFAULT_MESSAGE_PROCESSING_TIMEOUT = 40000
    DEFAULT_WAIT_TIMEOUT = 40000
    DEFAULT_OUT_OF_SYNC_THRESHOLD = 15000
    DEFAULT_SENDING_ENDPOINT_COUNT = 2
    DEFAULT_MAX_LATENCY = 60000
    DEFAULT_LATENCY_DETECTION_INTERVAL = 60000

    attr_reader :server_address, :endpoints, :network_retries_count,
      :message_retries_count, :message_processing_timeout,
      :wait_for_timeout, :out_of_sync_threshold, :reconnect_timeout,
      :max_reconnect_timeout,
      :sending_endpoint_count,
      :latency_detection_interval,
      :max_latency,
      :access_key

    def initialize(
      server_address: "",
      endpoints: [],
      network_retries_count: DEFAULT_NETWORK_RETRIES_COUNT,
      max_reconnect_timeout: DEFAULT_MAX_RECONNECT_TIMEOUT,
      reconnect_timeout: DEFAULT_RECONNECT_TIMEOUT,
      message_retries_count: DEFAULT_MESSAGE_RETRIES_COUNT,
      message_processing_timeout: DEFAULT_MESSAGE_PROCESSING_TIMEOUT,
      wait_for_timeout: DEFAULT_WAIT_TIMEOUT,
      out_of_sync_threshold: DEFAULT_OUT_OF_SYNC_THRESHOLD,
      sending_endpoint_count: DEFAULT_SENDING_ENDPOINT_COUNT,
      latency_detection_interval: DEFAULT_LATENCY_DETECTION_INTERVAL,
      max_latency: DEFAULT_MAX_LATENCY,
      access_key: nil
    )
      @server_address = server_address
      @endpoints = endpoints
      @network_retries_count = network_retries_count
      @max_reconnect_timeout = max_reconnect_timeout
      @reconnect_timeout = reconnect_timeout
      @message_retries_count = message_retries_count
      @message_processing_timeout = message_processing_timeout
      @wait_for_timeout = wait_for_timeout
      @out_of_sync_threshold = out_of_sync_threshold
      @sending_endpoint_count = sending_endpoint_count
      @latency_detection_interval = latency_detection_interval
      @max_latency = max_latency
      @access_key = access_key
    end

    def to_h
      {
        server_address: @server_address,
        endpoints: @endpoints,
        network_retries_count: @network_retries_count,
        max_reconnect_timeout: @max_reconnect_timeout,
        reconnect_timeout: @reconnect_timeout,
        message_retries_count: @message_retries_count,
        message_processing_timeout: @message_processing_timeout,
        wait_for_timeout: @wait_for_timeout,
        out_of_sync_threshold: @out_of_sync_threshold,
        sending_endpoint_count: @sending_endpoint_count,
        latency_detection_interval: @latency_detection_interval,
        max_latency: @max_latency,
        access_key: @access_key
      }
    end
  end

  CryptoConfig = Struct.new(:mnemonic_dictionary, :mnemonic_word_count, :hdkey_derivation_path, keyword_init: true) do
    def to_h
      {
        mnemonic_dictionary: @mnemonic_dictionary,
        mnemonic_word_count: @mnemonic_word_count,
        hdkey_derivation_path: @hdkey_derivation_path
      }
    end
  end

  class AbiConfig
    DEFAULT_EXPIRATION_TIMEOUT = 40000
    DEFAULT_TIMEOUT_GROW_FACTOR = 1.5

    attr_reader :workchain, :message_expiration_timeout, :message_expiration_timeout_grow_factor

    def initialize(
      workchain: nil,
      message_expiration_timeout: DEFAULT_EXPIRATION_TIMEOUT,
      message_expiration_timeout_grow_factor: DEFAULT_TIMEOUT_GROW_FACTOR
    )
      @workchain = workchain
      @message_expiration_timeout = message_expiration_timeout
      @message_expiration_timeout_grow_factor = message_expiration_timeout_grow_factor
    end

    def to_h
      {
        workchain: @workchain,
        message_expiration_timeout: @message_expiration_timeout,
        message_expiration_timeout_grow_factor: @message_expiration_timeout_grow_factor
      }
    end
  end
end
