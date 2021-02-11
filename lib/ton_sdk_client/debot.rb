module TonSdk

  # NOTE
  # as of 3 feb 2021, in the main repository this module is still unstable
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

      def to_h = { address: @address }
    end

    class RegisteredDebot
      attr_reader :debot_handle

      def initialize(a)
        @debot_handle = a
      end

      def to_h = { debot_handle: @debot_handle }
    end

    class ParamsOfAppDebotBrowser
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

      def initialize(
        type_:,
        msg: nil,
        context_id: nil,
        action: nil,
        prompt: nil,
        debot_addr: nil,
        message: nil
      )
        unless TYPE_VALUES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPE_VALUES}")
        end
        @type_ = type_
        @msg = msg
        @context_id = context_id
        @action = action
        @prompt = prompt
        @debot_addr = debot_addr
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

      def to_h = { address: @address }
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

    class ParamsOfSend
      attr_reader :debot_handle, :source, :func_id, :params

      def initialize(debot_handle:, source:, func_id:, params:)
        @debot_handle = debot_handle
        @source = source
        @func_id = func_id
        @params = params
      end

      def to_h
        {
          debot_handle: @debot_handle,
          source: @source,
          func_id: @func_id,
          params: @params
        }
      end
    end

    #
    # functions
    #

    def self.start(ctx, params, app_browser_obj)
      # TODO
      # 1) the handlers in 'start' and 'fetch' are identical
      # verify that it works and get rid of repetition

      # 2) this all can be replaced with 'app_browser_obj.request(...)' and 
      # 'app_browser_obj.notify(...)' calls, possibly

      app_resp_handler = Proc.new do |data|
        req_data = data["request_data"]
        case data["type"]
        when "Log"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          app_browser_obj.log(new_obj.msg)

        when "Switch"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          app_browser_obj.switch_to(new_obj.context_id)

        when "SwitchCompleted"
          app_browser_obj.switch_completed()

        when "ShowAction"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          app_browser_obj.show_action(new_obj.action)

        when "Input"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          # TODO possibly in a new thread or fiber
          app_req_res = begin
            res = app_browser_obj.input(new_obj.prompt)
            Client::AppRequestResult(type_: :ok, result: ResultOfAppDebotBrowser.new(type_: :input, value: res))
          rescue Exception => e
            Client::AppRequestResult(type_: :error, text: e.message)
          end

          params = Client::ParamsOfResolveAppRequest.new(
            app_request_id: data["app_request_id"],
            result: app_req_res
          )
          TonSdk::Client.resolve_app_request(c_ctx, params)

        when "GetSigningBox"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          # TODO possibly in a new thread or fiber
          app_req_res = begin
            res = app_browser_obj.get_signing_box()
            Client::AppRequestResult(type_: :ok, result: ResultOfAppDebotBrowser.new(type_: :get_signing_box, signing_box: res))
          rescue Exception => e
            Client::AppRequestResult(type_: :error, text: e.message)
          end

          params = Client::ParamsOfResolveAppRequest.new(
            app_request_id: data["app_request_id"],
            result: app_req_res
          )
          TonSdk::Client.resolve_app_request(c_ctx, params)

        when "InvokeDebot"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          # TODO possibly in a new thread or fiber
          app_req_res = begin
            res = app_browser_obj.invoke_debot(new_obj.debot_addr, new_obj.action)
            Client::AppRequestResult(type_: :ok, result: ResultOfAppDebotBrowser.new(type_: :invoke_debot))
          rescue Exception => e
            Client::AppRequestResult(type_: :error, text: e.message)
          end

          params = Client::ParamsOfResolveAppRequest.new(
            app_request_id: data["app_request_id"],
            result: app_req_res
          )
          TonSdk::Client.resolve_app_request(c_ctx, params)

        else
          # TODO log 'unknown option'
        end
      end

      Interop::request_to_native_lib(
        ctx,
        "debot.start",
        params.to_h.to_json,
        debot_app_response_handler: app_resp_handler,
        is_single_thread_only: false
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

    def self.fetch(ctx, params, app_browser_obj)
      # TODO
      # 1) the handlers in 'start' and 'fetch' are identical
      # verify that it works and get rid of repetition

      # 2) this all can be replaced with 'app_browser_obj.request(...)' and 
      # 'app_browser_obj.notify(...)' calls, possibly

      app_resp_handler = Proc.new do |data|
        req_data = data["request_data"]
        case data["type"]
        when "Log"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          app_browser_obj.log(new_obj.msg)

        when "Switch"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          app_browser_obj.switch_to(new_obj.context_id)

        when "SwitchCompleted"
          app_browser_obj.switch_completed()

        when "ShowAction"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          app_browser_obj.show_action(new_obj.action)

        when "Input"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          # TODO possibly in a new thread or fiber
          app_req_res = begin
            res = app_browser_obj.input(new_obj.prompt)
            Client::AppRequestResult(type_: :ok, result: ResultOfAppDebotBrowser.new(type_: :input, value: res))
          rescue Exception => e
            Client::AppRequestResult(type_: :error, text: e.message)
          end

          params = Client::ParamsOfResolveAppRequest.new(
            app_request_id: data["app_request_id"],
            result: app_req_res
          )
          TonSdk::Client.resolve_app_request(c_ctx, params)

        when "GetSigningBox"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          # TODO possibly in a new thread or fiber
          app_req_res = begin
            res = app_browser_obj.get_signing_box()
            Client::AppRequestResult(type_: :ok, result: ResultOfAppDebotBrowser.new(type_: :get_signing_box, signing_box: res))
          rescue Exception => e
            Client::AppRequestResult(type_: :error, text: e.message)
          end

          params = Client::ParamsOfResolveAppRequest.new(
            app_request_id: data["app_request_id"],
            result: app_req_res
          )
          TonSdk::Client.resolve_app_request(c_ctx, params)

        when "InvokeDebot"
          new_obj = ParamsOfAppDebotBrowser.from_json(data)
          # TODO possibly in a new thread or fiber
          app_req_res = begin
            res = app_browser_obj.invoke_debot(new_obj.debot_addr, new_obj.action)
            Client::AppRequestResult(type_: :ok, result: ResultOfAppDebotBrowser.new(type_: :invoke_debot))
          rescue Exception => e
            Client::AppRequestResult(type_: :error, text: e.message)
          end

          params = Client::ParamsOfResolveAppRequest.new(
            app_request_id: data["app_request_id"],
            result: app_req_res
          )
          TonSdk::Client.resolve_app_request(c_ctx, params)

        else
          # TODO log 'unknown option'
        end
      end

      Interop::request_to_native_lib(
        ctx,
        "debot.fetch",
        params.to_h.to_json,
        debot_app_response_handler: app_resp_handler,
        is_single_thread_only: false
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