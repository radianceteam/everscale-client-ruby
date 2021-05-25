module TonSdk

  # NOTE
  # as of 28 apr 2021, in the main repository this module is still unstable
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
    end

    DebotAction = Struct.new(:description, :name, :action_type, :to, :attributes, :misc, keyword_init: true) do
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

    ParamsOfStart = Struct.new(:debot_handle) do
      def to_h = { debot_handle: @debot_handle }
    end

    RegisteredDebot = Struct.new(:debot_handle, :debot_abi, :info) do
      def to_h = {
        debot_handle: @debot_handle,
        debot_abi: @debot_abi,
        info: @info.to_h
      }
    end

    class ParamsOfAppDebotBrowser
      private_class_method :new

      # todo remove?
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

      attr_reader :type_, :msg, :context_id, :action, :prompt, :debot_addr, :message, :activity

      def self.new_with_type_log(msg)
        @type_ = :log
        @msg = msg
      end

      def self.new_with_type_switch(context_id)
        @type_ = :switch
        @context_id = context_id
      end

      def self.new_with_type_switch_completed
        @type_ = :switch_completed
      end

      def self.new_with_type_show_action(action)
        @type_ = :show_action
        @action = action
      end

      def self.new_with_type_input(prompt)
        @type_ = :input
        @prompt = prompt
      end

      def self.new_with_type_get_signing_box
        @type_ = :get_signing_box
      end

      def self.new_with_type_invoke_debot(debot_addr, action)
        @type_ = :invoke_debot
        @debot_addr = debot_addr
        @action = action
      end

      def self.new_with_type_send(message)
        @type_ = :send
        @message = message
      end

      def self.new_with_type_approve(activity)
        @type_ = :approve
        @activity = activity
      end

      def to_h
        {
          type: Helper.sym_to_capitalized_case_str(@type_),
          msg: @msg,
          context_id: @context_id,
          action: @action,
          prompt: @prompt,
          debot_addr: @debot_addr,
          message: @message
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
        types_str = TYPE_VALUES.map(Helper.capitalized_case_str_to_snake_case_sym)
        unless types_str.include?(type_str)
          raise ArgumentError.new("type #{type_str} is unknown; known types: #{types_str}")
        end

        Helper.capitalized_case_str_to_snake_case_sym(type_str)
      end
    end

    class ResultOfAppDebotBrowser
      private_class_method :new

      attr_reader :type_, :value, :signing_box, :is_approved

      def self.new_with_type_input(a)
        @type_ = :input
        @value = a
      end

      def self.new_with_type_get_signing_box(a)
        @type_ = :get_signing_box
        @signing_box = signing_box
      end

      def self.new_with_type_invoke_debot
        @type_ = :invoke_debot
      end

      def self.new_with_type_approve(a)
        @type_ = :approve
        @is_approved = a
      end
    end

    ParamsOfFetch = Struct.new(:address) do
      def to_h = { address: @address }
    end

    ParamsOfExecute = Struct.new(:debot_handle, :action) do
      def to_h
        {
          debot_handle: @debot_handle,
          action: @action.to_h
        }
      end
    end

    ParamsOfSend = Struct.new(:debot_handle, :message) do
      def to_h
        {
          debot_handle: @debot_handle,
          message: @message
        }
      end
    end

    ParamsOfInit = Struct.new(:address)

    DebotInfo = Struct.new(
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
      keyword_init: true
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
        interfaces: []
      )
        super
      end
    end

    ResultOfFetch = Struct.new(:info)

    Spending = Struct.new(:amount, :dst)

    class DebotActivity
      private_class_method :new

      attr_reader :type_, :msg, :dst, :out, :fee, :setcode, :signkey, :signing_box_handle

      def self.new_with_type_transaction(msg:, dst:, out:, fee:, setcode:, signkey:, signing_box_handle:)
        @type_ = :transaction
        @msg = msg
        @dst = dst
        @out = out
        @fee = fee
        @setcode = setcode
        @signkey = signkey
        @signing_box_handle = signing_box_handle
      end

      def self.from_json(j)
        # todo
      end
    end



    #
    # functions
    #

    def self.init(ctx, params, app_browser_obj)
      Interop::request_to_native_lib(ctx, "debot.init", params.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: nil
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
        params.to_h.to_json,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
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
        params.to_h.to_json,
        is_single_thread_only: false
      ) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            # TODO: parse DebotInfo
            result: ResultOfFetch.new(resp.result["info"])
          )
        else
          yield resp
        end
      end
    end

    def self.execute(ctx, params)
      Interop::request_to_native_lib(ctx, "debot.execute", params.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end

    def self.remove(ctx, params)
      Interop::request_to_native_lib(ctx, "debot.remove", params.to_h.to_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: nil
          )
        else
          yield resp
        end
      end
    end

    def self.send(ctx, params)
      Interop::request_to_native_lib(ctx, "debot.send", params.to_h.to_json) do |resp|
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