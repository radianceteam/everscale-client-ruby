require 'spec_helper'

describe TonSdk::Debot do
  context "methods of debot" do
    it "#start" do
      pr1 = TonSdk::Debot::ParamsOfStart.new("abc")
      expect { |b| TonSdk::Debot.start(@c_ctx.context, pr1, &b) }.to yield_control
      TonSdk::Debot.start(@c_ctx.context, pr1) { |a| @res = a }

      # expect(@res.success?).to eq true
      # expect(@res.error).to eq "123"
    end

    it "#fetch" do
    end

    it "#execute" do
    end

    it "#remove" do
    end
  end
end