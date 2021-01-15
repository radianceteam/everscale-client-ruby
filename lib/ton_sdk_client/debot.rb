module TonSdk

  # NOTE
  # as of 15 jan 2021, in the main repository this module is still unstable
  module Debot

    #
    # types
    #

    module DebotErrorCodes
      DEBOT_START_FAILED = 801
      DEBOT_FETCH_FAILED = 802
      DEBOT_EXECUTION_FAILED = 803
      DEBOT_INVALID_HANDLE = 804
    end

    class DebotAction
      attr_reader :description, :name, :action_type, :to, :attributes, :misc

      def initialize(description:, name:, action_type:, to:, attributes:, misc:)
        @description = description
        @name = name
        @action_type = action_type
        @to = to
        @attributes = attributes
        @misc = misc
      end

      def to_h
        {
          description: @description,
          name: @name,
          action_type: @action_type,
          to: @to,
          attributes: @attributes,
          misc: @misc
        }
      end

      def self.from_json(j)
        return nil if j.nil?

        self.new(
          description: j["description"],
          name: j["name"],
          action_type: j["action_type"],
          to: j["to"],
          attributes: j["attributes"],
          misc: j["misc"]
        )
      end
    end

    class ParamsOfStart
      attr_reader :address

      def initialize(a)
        @address = a
      end

      def to_h() = { address: @address }
    end

    class RegisteredDebot
      attr_reader :debot_handle

      def initialize(a)
        @debot_handle = a
      end

      def to_h() = { debot_handle: @debot_handle }
    end

    class ParamsOfAppDebotBrowser
      TYPE_VALUES = [
        :log,
        :switch,
        :switch_completed,
        :show_action,
        :input,
        :get_signing_box,
        :invoke_debot
      ]
      attr_reader :type_, :msg, :context_id, :action, :prompt, :debot_addr

      def initialize(type_:, msg: nil, context_id: nil, action: nil, prompt: nil, debot_addr: nil)
        unless TYPE_VALUES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPE_VALUES}")
        end
        @type_ = type_
        @msg = msg
        @context_id = context_id
        @action = action
        @prompt = prompt
        @debot_addr = debot_addr
      end

      def to_h
        {
          type: Helper.sym_to_capitalized_camel_case_str(@type_),
          msg: @msg,
          context_id: @context_id,
          action: @action,
          prompt: @prompt,
          debot_addr: @debot_addr
        }
      end

      def self.from_json(j)
        return nil if j.nil?

        self.new(
          type_: self.parse_type(j["type"]),
          msg: j["msg"],
          context_id: j["context_id"],
          action: DebotAction.from_json(j["action"]),
          prompt: j["prompt"],
          debot_addr: j["debot_addr"]
        )
      end

      private

      def self.parse_type(s)
        s_dc = s.downcase()
        case s_dc
        when 'log', 'switch', 'input'
          s_dc.to_sym
        when 'switchcompleted'
          :switch_completed
        when 'showaction'
          :show_action
        when 'getsigningbox'
          :get_signing_box
        when 'invokedebot'
          :invoke_debot
        else
          raise ArgumentError.new("unknown type: #{s}; known ones: #{TYPE_VALUES}")
        end
      end
    end

    class ResultOfAppDebotBrowser
      TYPE_VALUES = [
        :input,
        :get_signing_box,
        :invoke_debot
      ]

      attr_reader :type_, :value, :signing_box

      def initialize(type_:, value: nil, signing_box: nil)
        unless TYPE_VALUES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPE_VALUES}")
        end
        @type_ = type_
        @value = value
        @signing_box = signing_box
      end
    end

    class ParamsOfFetch
      attr_reader :address

      def initialize(a)
        @address = a
      end

      def to_h() = { address: @address }
    end

    class ParamsOfExecute
      attr_reader :debot_handle, :action

      def initialize(debot_handle:, action:)
        @debot_handle = debot_handle
        @action = action
      end

      def to_h
        {
          debot_handle: @debot_handle,
          action: @action.to_h
        }
      end
    end


    #
    # functions
    #

    # TODO app_debot_browser argument
    def self.start(ctx, pr_s, app_browser)
      app_resp_handler = Proc.new do |data|
        case data["request_data"]
        when "Log"
        when "Switch"
        when "SwitchCompleted"
        when "ShowAction"
        when "Input"
        when "GetSigningBox"
        when "InvokeDebot"
        end
      end

      Interop::request_to_native_lib(
        ctx,
        "debot.start",
        pr_s.to_h.to_json,
        debot_app_response_handler: app_resp_handler,
        single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: RegisteredDebot.new(resp.result["debot_handle"])
          )
        else
          yield resp
        end
      end
    end

    # TODO app_debot_browser argument
    def self.fetch(ctx, pr_s, app_browser)

      # TODO use 'custom_response_handler'?







      Interop::request_to_native_lib(ctx, "debot.fetch", pr_s.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: RegisteredDebot.new(resp.result["debot_handle"])
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
            result: nil
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
            result: nil
          )
        else
          yield resp
        end
      end
    end
  end
end