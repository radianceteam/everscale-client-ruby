require 'spec_helper'

describe TonSdk::Utils do
  context "methods of utils" do
    it "#convert_address" do
      account_id = "fcb91a3a3816d0f7b8c2c76108b8a9bc5a6b7a55bd79f8ab101c52db29232260"
      hex = "-1:fcb91a3a3816d0f7b8c2c76108b8a9bc5a6b7a55bd79f8ab101c52db29232260"
      hex_workchain0 = "0:fcb91a3a3816d0f7b8c2c76108b8a9bc5a6b7a55bd79f8ab101c52db29232260"
      base64 = "Uf/8uRo6OBbQ97jCx2EIuKm8Wmt6Vb15+KsQHFLbKSMiYG+9"
      base64url = "kf_8uRo6OBbQ97jCx2EIuKm8Wmt6Vb15-KsQHFLbKSMiYIny"

      # 1
      pr1 = TonSdk::Utils::ParamsOfConvertAddress.new(
        address: account_id,
        output_format: TonSdk::Utils::AddressStringFormat.new(type_: :hex)
      )

      expect { |b| TonSdk::Utils.convert_address(@c_ctx.context, pr1, &b) }.to yield_control
      expect { |b| TonSdk::Utils.convert_address(@c_ctx.context, pr1, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Utils.convert_address(@c_ctx.context, pr1) { |a| @res1 = a }
      expect(@res1.success?).to eq true
      expect(@res1.result.address).to eq hex_workchain0


      # 2
      pr2 = TonSdk::Utils::ParamsOfConvertAddress.new(
        address: account_id,
        output_format: TonSdk::Utils::AddressStringFormat.new(type_: :account_id)
      )

      expect { |b| TonSdk::Utils.convert_address(@c_ctx.context, pr2, &b) }.to yield_control
      expect { |b| TonSdk::Utils.convert_address(@c_ctx.context, pr2, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Utils.convert_address(@c_ctx.context, pr2) { |a| @res2 = a }
      expect(@res2.success?).to eq true
      expect(@res2.result.address).to eq account_id

      # 3
      pr3 = TonSdk::Utils::ParamsOfConvertAddress.new(
        address: hex,
        output_format: TonSdk::Utils::AddressStringFormat.new(
          type_: :base64,
          bounce: false,
          test_: false,
          url: false
        )
      )

      expect { |b| TonSdk::Utils.convert_address(@c_ctx.context, pr3, &b) }.to yield_control
      expect { |b| TonSdk::Utils.convert_address(@c_ctx.context, pr3, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Utils.convert_address(@c_ctx.context, pr3) { |a| @res3 = a }
      expect(@res3.success?).to eq true
      expect(@res3.result.address).to eq base64

      # 4
      pr4 = TonSdk::Utils::ParamsOfConvertAddress.new(
        address: base64,
        output_format: TonSdk::Utils::AddressStringFormat.new(
          type_: :base64,
          bounce: true,
          test_: true,
          url: true
        )
      )

      expect { |b| TonSdk::Utils.convert_address(@c_ctx.context, pr4, &b) }.to yield_control
      expect { |b| TonSdk::Utils.convert_address(@c_ctx.context, pr4, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      TonSdk::Utils.convert_address(@c_ctx.context, pr4) { |a| @res4 = a }
      expect(@res4.success?).to eq true
      expect(@res4.result.address).to eq base64url

      # 5
      pr5 = TonSdk::Utils::ParamsOfConvertAddress.new(
        address: base64,
        output_format: TonSdk::Utils::AddressStringFormat.new(type_: :hex)
      )
      TonSdk::Utils.convert_address(@c_ctx.context, pr5) { |a| @res5 = a }

      expect(@res5.result.address).to eq(hex)
    end

    it "#calc_storage_fee" do
      account = File.read("spec/data/boc/parse_account1.txt")
      params = TonSdk::Utils::ParamsOfCalcStorageFee.new(
        account: account,
        period: 1000
      )
      TonSdk::Utils.calc_storage_fee(@c_ctx.context, params) { |r| @response = r }

      expect(@response.result.fee).to eq("330")
    end

    it "#compression" do
      uncompressed = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
      params = TonSdk::Utils::ParamsOfCompressZstd.new(
        uncompressed: Base64.strict_encode64(uncompressed),
        level: 21
      )
      TonSdk::Utils.compress_zstd(@c_ctx.context, params) { |r| @response = r }

      expect(@response.result.compressed).to eq("KLUv/QCAdQgAJhc5GJCnsA2AIm2tVzjno88mHb3Ttx9b8fXHHDAAMgAyAMUsVo6Pi3rPTDF2WDl510aHTwt44hrUxbn5oF6iUfiUiRbQhYo/PSM2WvKYt/hMIOQmuOaY/bmJQoRky46EF+cEd+Thsep5Hloo9DLCSwe1vFwcqIHycEKlMqBSo+szAiIBhkukH5kSIVlFukEWNF2SkIv6HBdPjFAjoUliCPjzKB/4jK91X95rTAKoASkPNqwUEw2Gkscdb3lR8YRYOR+P0sULCqzPQ8mQFJWnBSyP25mWIY2bFEUSJiGsWD+9NBqLhIAGDggQkLMbt5Y1aDR4uLKqwJXmQFPg/XTXIL7LCgspIF1YYplND4Uo")

      params = TonSdk::Utils::ParamsOfDecompressZstd.new(compressed: @response.result.compressed)
      TonSdk::Utils.decompress_zstd(@c_ctx.context, params) { |r| @response = r }
      decompressed = Base64.strict_decode64(@response.result.decompressed)

      expect(decompressed).to eq(uncompressed)
    end

    it "#get_address_type" do
      ["", "   ", "123456", "abcdef"].each do |address|
        params = TonSdk::Utils::ParamsOfGetAddressType.new(address: address)
        TonSdk::Utils.get_address_type(@c_ctx.context, params) { |r| @response = r }

        expect(@response.failure?).to eq(true)
      end

      [
        "-1:7777777777777777777777777777777777777777777777777777777777777777",
        "0:919db8e740d50bf349df2eea03fa30c385d846b991ff5542e67098ee833fc7f7"
      ].each do |address|
        params = TonSdk::Utils::ParamsOfGetAddressType.new(address: address)
        TonSdk::Utils.get_address_type(@c_ctx.context, params) { |r| @response = r }

        expect(@response.result.address_type).to eq("Hex")
      end

      [
        "7777777777777777777777777777777777777777777777777777777777777777",
        "919db8e740d50bf349df2eea03fa30c385d846b991ff5542e67098ee833fc7f7"
      ].each do |address|
        params = TonSdk::Utils::ParamsOfGetAddressType.new(address: address)
        TonSdk::Utils.get_address_type(@c_ctx.context, params) { |r| @response = r }

        expect(@response.result.address_type).to eq("AccountId")
      end

      [
        "EQCRnbjnQNUL80nfLuoD+jDDhdhGuZH/VULmcJjugz/H9wam",
        "EQCRnbjnQNUL80nfLuoD+jDDhdhGuZH/VULmcJjugz/H9wam",
        "UQCRnbjnQNUL80nfLuoD+jDDhdhGuZH/VULmcJjugz/H91tj",
        "UQCRnbjnQNUL80nfLuoD-jDDhdhGuZH_VULmcJjugz_H91tj"
      ].each do |address|
        params = TonSdk::Utils::ParamsOfGetAddressType.new(address: address)
        TonSdk::Utils.get_address_type(@c_ctx.context, params) { |r| @response = r }

        expect(@response.result.address_type).to eq("Base64")
      end
    end
  end
end
