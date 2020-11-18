module TonSdk
  class ResultOfConvertAddress
    attr_reader :address

    def initialize(a)
      @address = a
    end
  end

  class SdkError < StandardError
    attr_reader :code, :message, :data

    def initialize(code: nil, message: nil, data: nil)
      @code = code
      @message = message
      @data = data
    end
  end

  class NativeLibResponsetResult
    attr_reader :result, :error

    def initialize(result: nil, error: nil)
      if !result.nil? && !error.nil?
        raise ArgumentError.new('only either argument, result or error, should be specified')
      end

      @result = result
      @error = error
      self
    end

    def success?
      !@result.nil?
    end

    def failure?
      !@error.nil?
    end
  end
end