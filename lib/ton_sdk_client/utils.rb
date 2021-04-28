module TonSdk
  module Utils

    #
    # types
    #

    class AddressStringFormat
      TYPES = [:account_id, :hex, :base64]
      attr_reader :type_, :url, :test_, :bounce

      def initialize(type_:, url: nil, test_: nil, bounce: nil)
        unless TYPES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end

        @type_ = type_
        if @type_ == :base64
          @url = url
          @test_ = test_
          @bounce = bounce
        end
      end

      def to_h
        {
          type: Helper.sym_to_capitalized_case_str(@type_),
          url: @url,
          test: @test_,
          bounce: @bounce
        }
      end
    end

    ParamsOfConvertAddress = Struct.new(:address, :output_format)
      def to_h
        {
          address: @address,
          output_format: @output_format.to_h
        }
      end
    end

    ResultOfConvertAddress = Struct.new(:address)

    ParamsOfCalcStorageFee = Struct.new(:account, :period)
      def to_h
        {
          account: @account,
          period: @period
        }
      end
    end

    ResultOfCalcStorageFee = Struct.new(:fee)

    class ParamsOfCompressZstd
      attr_reader :uncompressed, :level

      def initialize(uncompressed:, level: nil)
        @uncompressed = uncompressed
        @level = level
      end

      def to_h
        {
          uncompressed: @uncompressed,
          level: @level
        }
      end
    end

    ResultOfCompressZstd = Struct.new(:compressed)

    class ParamsOfDecompressZstd = Struct.new(:compressed)
      def to_h = { compressed: @compressed }
    end

    ResultOfDecompressZstd = Struct.new(:decompressed)


    #
    # functions
    #

    def self.convert_address(ctx, prm)
      Interop::request_to_native_lib(ctx, "utils.convert_address", prm.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: Utils::ResultOfConvertAddress.new(resp.result["address"])
          )
        else
          yield resp
        end
      end
    end

    def self.calc_storage_fee(ctx, prm)
      Interop::request_to_native_lib(ctx, "utils.calc_storage_fee", prm.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: Utils::ResultOfCalcStorageFee.new(resp.result["fee"])
          )
        else
          yield resp
        end
      end
    end

    def self.compress_zstd(ctx, prm)
      Interop::request_to_native_lib(ctx, "utils.compress_zstd", prm.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: Utils::ResultOfCompressZstd.new(resp.result["compressed"])
          )
        else
          yield resp
        end
      end
    end

    def self.decompress_zstd(ctx, prm)
      Interop::request_to_native_lib(ctx, "utils.decompress_zstd", prm.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: Utils::ParamsOfDecompressZstd.new(resp.result["decompressed"])
          )
        else
          yield resp
        end
      end
    end
  end
end