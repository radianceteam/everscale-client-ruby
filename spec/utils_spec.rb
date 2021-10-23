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
  end
end
