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

    ParamsOfConvertAddress = Struct.new(:address, :output_format, keyword_init: true) do
      def to_h
        {
          address: address,
          output_format: output_format.to_h
        }
      end
    end

    ResultOfConvertAddress = Struct.new(:address)
    ParamsOfCalcStorageFee = Struct.new(:account, :period, keyword_init: true)
    ResultOfCalcStorageFee = Struct.new(:fee)

    ParamsOfCompressZstd = Struct.new(:uncompressed, :level, keyword_init: true)
    ResultOfCompressZstd = Struct.new(:compressed)

    ParamsOfDecompressZstd = Struct.new(:compressed, keyword_init: true)
    ResultOfDecompressZstd = Struct.new(:decompressed)

    ParamsOfGetAddressType = Struct.new(:address)
    ResultOfGetAddressType = Struct.new(:address_type)


    #
    # functions
    #

    def self.convert_address(ctx, params)
      Interop::request_to_native_lib(ctx, "utils.convert_address", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfConvertAddress.new(resp.result["address"])
          )
        else
          yield resp
        end
      end
    end

    def self.calc_storage_fee(ctx, params)
      Interop::request_to_native_lib(ctx, "utils.calc_storage_fee", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfCalcStorageFee.new(resp.result["fee"])
          )
        else
          yield resp
        end
      end
    end

    def self.compress_zstd(ctx, params)
      Interop::request_to_native_lib(ctx, "utils.compress_zstd", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfCompressZstd.new(resp.result["compressed"])
          )
        else
          yield resp
        end
      end
    end

    def self.decompress_zstd(ctx, params)
      Interop::request_to_native_lib(ctx, "utils.decompress_zstd", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfDecompressZstd.new(resp.result["decompressed"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_address_type(ctx, params)
      Interop::request_to_native_lib(ctx, "utils.get_address_type", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGetAddressType.new(resp.result["address_type"])
          )
        else
          yield resp
        end
      end
    end
  end
end
