module EverSdk
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

  class NativeLibResponseResult
    attr_reader :result, :error

    def initialize(result: nil, error: nil)
      if !result.nil? && !error.nil?
        raise ArgumentError.new('only either argument, result or error, should be specified')
      elsif !result.nil?
        @result = result
      elsif !error.nil?
        @error = SdkError.new(
          code: error["code"],
          message: error["message"],
          data: error["data"]
        )
      else
        # Some methods like unsubscribe will trigger this error. Should be refactored
        raise ArgumentError.new('some arguments are wrong; provide either result or error')
      end

      self
    end

    def success? = !@result.nil?
    def failure? = !@error.nil?
  end
end
