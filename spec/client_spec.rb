require 'spec_helper'

describe TonSdk::Client do
  context "methods of client" do
    it "#version" do
      expect { |b| TonSdk::Client.version(@c_ctx.context, &b) }.to yield_control
      expect { |b| TonSdk::Client.version(@c_ctx.context, &b) }.to yield_with_args(TonSdk::NativeLibResponsetResult)

      # NOTE
      # rspec isn't capable of validating a result inside a block
      # therefore, a new variable has to be utilized to take a result out
      # of a block and then validate it

      TonSdk::Client.version(@c_ctx.context) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.failure?).to_not eq true
    end

    it "#get_api_reference" do
      TonSdk::Client.get_api_reference(@c_ctx.context) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.failure?).to_not eq true
      expect(@res.result.api).to_not eq ""
    end

    it "#build_info" do
      TonSdk::Client.build_info(@c_ctx.context) { |a| @res = a }

      expect(@res.success?).to eq true
      expect(@res.failure?).to_not eq true
      expect(@res.result.build_info).to_not eq ""
    end
  end
end