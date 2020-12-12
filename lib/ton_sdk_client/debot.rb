module TonSdk
  module Debot

    # TODO


    class DebotAction
      attr_reader :description, :name, :action_type, :to, :attributes, :misc

      def initialize
      end

      def to_h
      end
    end

    class ParamsOfStart
      attr_reader :address

      def initialize
      end

      def to_h
      end
    end

    class RegisteredDebot
      attr_reader :debot_handle

      def initialize
      end

      def to_h
      end
    end

    class ParamsOfAppDebotBrowser
      attr_reader :type_, :msg, :context_id, :action, :prompt, :debot_addr

      def initialize
      end

      def to_h
      end
    end

    class ResultOfAppDebotBrowser
      attr_reader :type_, :value, :signing_box

      def initialize
      end

      def to_h
      end
    end

    class ParamsOfFetch
      attr_reader :address

      def initialize
      end

      def to_h
      end
    end

    class ParamsOfExecute
      attr_reader :debot_handle, :action

      def initialize
      end

      def to_h
      end
    end






    #
    # methods
    #
    def self.start(ctx, pr_s)
      Interop::request_to_native_lib(ctx, "debot.start", pr_s.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ""
          )
        else
          yield resp
        end
      end
    end

    def self.fetch(ctx, pr_s)
      Interop::request_to_native_lib(ctx, "debot.fetch", pr_s.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ""
          )
        else
          yield resp
        end
      end
    end


    def self.execute(ctx, pr_s)
      Interop::request_to_native_lib(ctx, "debot.execute", pr_s.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ""
          )
        else
          yield resp
        end
      end
    end


    def self.remove(ctx, pr_s)
      Interop::request_to_native_lib(ctx, "debot.remove", pr_s.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ""
          )
        else
          yield resp
        end
      end
    end
  end
end