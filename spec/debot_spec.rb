require 'spec_helper'

xdescribe EverSdk::Debot do

  # TODO in the main repository 'debot' is still unstable, as of 15 jan 2021
  # finish the tests once 'debot' has become stable

  context "methods of debot" do
    it "#start" do
      pr1 = EverSdk::Debot::ParamsOfStart.new("abc")
      expect { |b| EverSdk::Debot.start(@c_ctx.context, pr1, &b) }.to yield_control
      EverSdk::Debot.start(@c_ctx.context, pr1) { |a| @res = a }

      # expect(@res.success?).to eq true
    end

    it "#fetch" do
    end

    it "#execute" do
    end

    it "#remove" do
    end
  end
end
