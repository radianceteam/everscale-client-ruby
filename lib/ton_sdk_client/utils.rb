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

    ParamsOfConvertAddress = KwStruct.new(:address, :output_format) do
      def to_h
        {
          address: address,
          output_format: output_format.to_h
        }
      end
    end

    ResultOfConvertAddress = KwStruct.new(:address)
    ParamsOfCalcStorageFee = KwStruct.new(:account, :period)
    ResultOfCalcStorageFee = KwStruct.new(:fee)

    ParamsOfCompressZstd = KwStruct.new(:uncompressed, :level)
    ResultOfCompressZstd = KwStruct.new(:compressed)

    ParamsOfDecompressZstd = KwStruct.new(:compressed)
    ResultOfDecompressZstd = KwStruct.new(:decompressed)

    ParamsOfGetAddressType = KwStruct.new(:address)
    ResultOfGetAddressType = KwStruct.new(:address_type)


    #
    # functions
    #

    def self.convert_address(ctx, params)
      Interop::request_to_native_lib(ctx, "utils.convert_address", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfConvertAddress.new(address: resp.result["address"])
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
            result: ResultOfCalcStorageFee.new(fee: resp.result["fee"])
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
            result: ResultOfCompressZstd.new(compressed: resp.result["compressed"])
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
            result: ResultOfDecompressZstd.new(decompressed: resp.result["decompressed"])
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
            result: ResultOfGetAddressType.new(address_type: resp.result["address_type"])
          )
        else
          yield resp
        end
      end
    end
  end
end
