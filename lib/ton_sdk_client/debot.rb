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

    RegisteredDebot = Struct.new(:debot_handle) do
      def to_h = { debot_handle: @debot_handle }
    end

    class ParamsOfAppDebotBrowser

      # todo remove?
      TYPE_VALUES = [
        :log,
        :switch,
        :switch_completed,
        :show_action,
        :input,
        :get_signing_box,
        :invoke_debot,
        :send
      ]

      attr_reader :type_, :msg, :context_id, :action, :prompt, :debot_addr, :message

      def new_with_type_log(msg)
        @type_ = :log
        @msg = msg
      end

      def new_with_type_switch(context_id)
        @type_ = :switch
        @context_id = context_id
      end

      def new_with_type_switch_completed
        @type_ = :switch_completed
      end

      def new_with_type_show_action(action)
        @type_ = :show_action
        @action = action
      end

      def new_with_type_input(prompt)
        @type_ = :input
        @prompt = prompt
      end

      def new_with_type_get_signing_box
        @type_ = :get_signing_box
      end

      def new_with_type_invoke_debot(debot_addr, action)
        @type_ = :invoke_debot
        @debot_addr = debot_addr
        @action = action
      end

      def new_with_type_send(message)
        @type_ = :send
        @message = message
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

      def self.parse_type(type_str)
        types_str = TYPE_VALUES.map(Helper.capitalized_case_str_to_snake_case_sym)
        unless types_str.include?(type_str)
          raise ArgumentError.new("type #{type_str} is unknown; known types: #{types_str}")
        end

        Helper.capitalized_case_str_to_snake_case_sym(type_str)
      end
    end

    class ResultOfAppDebotBrowser
      attr_reader :type_, :value, :signing_box, :is_approved

      def new_with_type_input(a)
        @type_ = :input
        @value = a
      end

      def new_with_type_get_signing_box(a)
        @type_ = :get_signing_box
        @signing_box = signing_box
      end

      def new_with_type_invoke_debot
        @type_ = :invoke_debot
      end

      def new_with_type_approve(a)
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
      :key,
      :author,
      :support,
      :hello,
      :language,
      :dabi,
      :icon,
      :interfaces,
      keyword_init: true
    )

    ResultOfFetch = Struct.new(:info)


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