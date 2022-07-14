module EverSdk
  module Debot

    #
    # types
    #

    module ErrorCode
      START_FAILED = 801
      FETCH_FAILED = 802
      EXECUTION_FAILED = 803
      INVALID_HANDLE = 804
      INVALID_JSON_PARAMS = 805
      INVALID_FUNCTION_ID = 806
      INVALID_ABI = 807
      GET_METHOD_FAILED = 808
      INVALID_MSG = 809
      EXTERNAL_CALL_FAILED = 810
      BROWSER_CALLBACK_FAILED = 811
      OPERATION_REJECTED = 812
      DEBOT_NO_CODE = 813
    end

    DebotAction = KwStruct.new(:description, :name, :action_type, :to, :attributes, :misc) do
      def to_h
        {
          description: description,
          name: name,
          action_type: action_type,
          to: to,
          attributes: attributes,
          misc: misc
        }
      end

      def self.from_json(j)
        return if j.nil?

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

    DebotInfo = KwStruct.new(
      :name,
      :version,
      :publisher,
      :caption,
      :author,
      :support,
      :hello,
      :language,
      :dabi,
      :icon,
      :interfaces,
      :dabi_version
    ) do
      def initialize(
        name: nil,
        version: nil,
        publisher: nil,
        caption: nil,
        author: nil,
        support: nil,
        hello: nil,
        language: nil,
        dabi: nil,
        icon: nil,
        interfaces: [],
        dabi_version: nil
      )
        super
      end
    end

    class DebotActivity
      attr_reader :type, :msg, :dst, :out, :fee, :setcode, :signkey, :signing_box_handle
    end

    Spending = KwStruct.new(:amount, :dst)

    ParamsOfInit = KwStruct.new(:address)

    RegisteredDebot = KwStruct.new(:debot_handle, :debot_abi, :info) do
      def to_h
        {
          debot_handle: debot_handle,
          debot_abi: debot_abi,
          info: info.to_h
        }
      end
    end

    class ParamsOfAppDebotBrowser
      private_class_method :new

      TYPE_VALUES = [
        :log,
        :switch,
        :switch_completed,
        :show_action,
        :input,
        :get_signing_box,
        :invoke_debot,
        :send,
        :approve
      ]

      attr_reader :type, :msg, :context_id, :action, :prompt, :debot_addr, :message, :activity

      def self.new_with_type_log(msg)
        @type = :log
        @msg = msg
      end

      def self.new_with_type_switch(context_id)
        @type = :switch
        @context_id = context_id
      end

      def self.new_with_type_switch_completed
        @type = :switch_completed
      end

      def self.new_with_type_show_action(action)
        @type = :show_action
        @action = action
      end

      def self.new_with_type_input(prompt)
        @type = :input
        @prompt = prompt
      end

      def self.new_with_type_get_signing_box
        @type = :get_signing_box
      end

      def self.new_with_type_invoke_debot(debot_addr, action)
        @type = :invoke_debot
        @debot_addr = debot_addr
        @action = action
      end

      def self.new_with_type_send(message)
        @type = :send
        @message = message
      end

      def self.new_with_type_approve(activity)
        @type = :approve
        @activity = activity
      end

      def to_h
        {
          type: Helper.sym_to_capitalized_case_str(type),
          msg: msg,
          context_id: context_id,
          action: action,
          prompt: prompt,
          debot_addr: debot_addr,
          message: message
        }
      end

      def self.from_json(j)
        return nil if j.nil?

        tp = self.parse_type(j["type"])
        case tp
        when :log
          self.new_with_type_log(j["msg"])

        when :switch
          self.new_with_type_switch(j["context_id"])

        when :switch_completed
          self.new_with_type_switch_completed

        when :show_action
          self.new_with_type_show_action(DebotAction.from_json(j["action"]))

        when :input
          self.new_with_type_input(j["prompt"])

        when :get_signing_box
          self.new_with_type_get_signing_box

        when :invoke_debot
          self.new_with_type_invoke_debot(j["debot_addr"], DebotAction.from_json(j["action"]))

        when :send
          self.new_with_type_send(j["message"])

        when :approve
          self.new_with_type_send(DebotActivity.from_json(j["activity"]))

        else
          raise ArgumentError.new("no handler for type: #{tp}")
        end
      end

      private

      def self.parse_type(type_str)
        parsed_type = Helper.capitalized_case_str_to_snake_case_sym(type_str)

        unless TYPE_VALUES.include?(type_str)
          raise ArgumentError.new("type #{type_str} is unknown; known types: #{TYPE_VALUES}")
        end

        parsed_type
      end
    end

    class ResultOfAppDebotBrowser
      private_class_method :new

      attr_reader :type, :value, :signing_box, :is_approved

      def self.new_with_type_input(a)
        @type = :input
        @value = a
      end

      def self.new_with_type_get_signing_box(a)
        @type = :get_signing_box
        @signing_box = signing_box
      end

      def self.new_with_type_invoke_debot
        @type = :invoke_debot
      end

      def self.new_with_type_approve(a)
        @type = :approve
        @is_approved = a
      end
    end

    ParamsOfStart = KwStruct.new(:debot_handle)

    ParamsOfFetch = KwStruct.new(:address)

    ResultOfFetch = KwStruct.new(:info)

    ParamsOfExecute = KwStruct.new(:debot_handle, :action) do
      def to_h
        {
          debot_handle: debot_handle,
          action: action.to_h
        }
      end
    end

    ParamsOfSend = KwStruct.new(:debot_handle, :message)

    ParamsOfRemove = KwStruct.new(:debot_handle)

    #
    # functions
    #

    def self.init(ctx, params, app_browser_obj = nil)
      Interop::request_to_native_lib(
        ctx,
        "debot.init",
        params
      ) do |resp|
        if resp.success?
          debot_info = resp.result["info"].transform_keys(&:to_sym)
          debot_info[:dabi_version] = debot_info.delete(:dabiVersion)
          yield NativeLibResponseResult.new(
            result: RegisteredDebot.new(
              debot_handle: resp.result["debot_handle"],
              debot_abi: resp.result["debot_abi"],
              info: DebotInfo.new(**debot_info)
            )
          )
        else
          yield resp
        end
      end
    end

    def self.start(ctx, params)
      Interop::request_to_native_lib(
        ctx,
        "debot.start",
        params,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end

    def self.fetch(ctx, params)
      Interop::request_to_native_lib(
        ctx,
        "debot.fetch",
        params,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          debot_info = resp.result["info"].transform_keys(&:to_sym)
          debot_info[:dabi_version] = debot_info.delete(:dabiVersion)
          yield NativeLibResponseResult.new(
            result: ResultOfFetch.new(
              info: DebotInfo.new(**debot_info)
            )
          )
        else
          yield resp
        end
      end
    end

    def self.execute(ctx, params)
      Interop::request_to_native_lib(ctx, "debot.execute", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end

    def self.remove(ctx, params)
      Interop::request_to_native_lib(ctx, "debot.remove", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end

    def self.send(ctx, params)
      Interop::request_to_native_lib(ctx, "debot.send", params) do |resp|
        if resp.success?
          yield NativeLibResponseResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end
  end
end
