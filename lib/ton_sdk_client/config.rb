module TonSdk
  class ClientConfig
    attr_reader :network, :crypto, :abi

    def initialize(network: nil, crypto: nil, abi: nil)
      if network.nil? && crypto.nil? && abi.nil?
        raise ArgumentError.new("all 3 arguments may not be nil")
      end

      @network = network
      @crypto = crypto
      @abi = abi
    end

    def to_h
      {
        network: @network.nil? ? nil : @network.to_h,
        crypto: @crypto.nil? ? nil : @crypto.to_h,
        abi: @abi.nil? ? nil : @abi.to_h
      }
    end
  end

  class NetworkConfig
    DEFAULT_RETRIES_COUNT = 5
    DEFAULT_PROCESSING_TIMEOUT = 40000
    DEFAULT_WAIT_TIMEOUT = 40000
    DEFAULT_OUT_OF_SYNC_THRESHOLD = 15000

    attr_reader :server_address, :message_retries_count, :message_processing_timeout,
      :wait_for_timeout, :out_of_sync_threshold, :access_key

    def initialize(
      server_address: "",
      message_retries_count: DEFAULT_RETRIES_COUNT,
      message_processing_timeout: DEFAULT_PROCESSING_TIMEOUT,
      wait_for_timeout: DEFAULT_WAIT_TIMEOUT,
      out_of_sync_threshold: DEFAULT_OUT_OF_SYNC_THRESHOLD
    )
      @server_address = server_address
      @message_retries_count = message_retries_count
      @message_processing_timeout = message_processing_timeout
      @wait_for_timeout = wait_for_timeout
      @out_of_sync_threshold = out_of_sync_threshold
    end

    def to_h
      {
        server_address: @server_address,
        message_retries_count: @message_retries_count,
        message_processing_timeout: @message_processing_timeout,
        wait_for_timeout: @wait_for_timeout,
        out_of_sync_threshold: @out_of_sync_threshold,
        access_key: @access_key
      }
    end
  end

  class CryptoConfig
    attr_reader :fish_param

    def initialize(a)
      @fish_param = a
    end

    def to_h
      {
        fish_param: @fish_param
      }
    end
  end

  class AbiConfig
    DEFAULT_EXPIRATION_TIMEOUT = 40000
    DEFAULT_TIMEOUT_GROW_FACTOR = 1.5

    attr_reader :message_expiration_timeout, :message_expiration_timeout_grow_factor

    def initialize(message_expiration_timeout: DEFAULT_EXPIRATION_TIMEOUT,
      message_expiration_timeout_grow_factor: DEFAULT_TIMEOUT_GROW_FACTOR
    )
      @message_expiration_timeout = message_expiration_timeout
      @message_expiration_timeout_grow_factor = message_expiration_timeout_grow_factor
    end

    def to_h
      {
        message_expiration_timeout: @message_expiration_timeout,
        message_expiration_timeout_grow_factor: @message_expiration_timeout_grow_factor
      }
    end
  end
end
