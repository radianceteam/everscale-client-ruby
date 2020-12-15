module TonSdk
  module Abi

    #
    # types
    #

    class Abi
      TYPES = [:contract, :json, :handle, :serialized]
      attr_reader :type_, :value

      def initialize(type_:, value:)
        unless TYPES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end
        @type_ = type_
        @value = value
      end

      def to_h
        h1 = {
          type: Helper.sym_to_capitalized_camel_case_str(@type_)
        }

        h2 = case @type_
        when :contract, :serialized
          {
            value: @value.to_h
          }
        when :json, :handle
          {
            value: @value
          }
        else
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end

        h1.merge(h2)
      end
    end

    class FunctionHeader
      attr_reader :expire, :time, :pubkey

      def initialize(expire: nil, time: nil, pubkey: nil)
        @expire = expire
        @time = time
        @pubkey = pubkey
      end

      def to_h
        {
          expire: @expire,
          time: @time,
          pubkey: @pubkey
        }
      end
    end

    class CallSet
      attr_reader :function_name, :header, :input

      def initialize(function_name:, header: nil, input: nil)
        @function_name = function_name
        @header = header
        @input = input
      end

      def to_h
        {
          function_name: @function_name,
          header: @header.nil? ? nil : @header.to_h,
          input: @input
        }
      end
    end

    class DeploySet
      attr_reader :tvc, :workchain_id, :initial_data

      def initialize(tvc:, workchain_id: nil, initial_data: nil)
        @tvc = tvc
        @workchain_id = workchain_id
        @initial_data = initial_data
      end

      def to_h
        {
          tvc: @tvc,
          workchain_id: @workchain_id,
          initial_data: @initial_data
        }
      end
    end

    class Signer
      TYPES = [:none, :external, :keys, :signing_box]
      attr_reader :type_, :public_key, :keys, :handle

      def initialize(type_:, public_key: nil, keys: nil, handle: nil)
        unless TYPES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end

        @type_ = type_
        @public_key = public_key
        @keys = keys
        @handle = handle
      end

      def to_h
        h1 = {
          type: Helper.sym_to_capitalized_camel_case_str(@type_)
        }

        h2 = case @type_
        when :none
          { }
        when :external
        {
          public_key: @public_key
        }
        when :keys
          {
            keys: @keys.to_h
          }
        when :signing_box
          {
            handle: @handle
          }
        end

        h1.merge(h2)
      end
    end

    class StateInitSource
      TYPES = [:message, :state_init, :tvc]
      attr_reader :type_, :source, :code, :data, :library, :tvc, :public_key, :init_params

      def initialize(type_:, source: nil, code: nil, data: nil, library: nil, tvc: nil,
          public_key: nil, init_params: nil)
        unless TYPES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end

        @type_ = type_
        @source = source
        @code = code
        @data = data
        @library = library
        @tvc = tvc
        @public_key = public_key
        @init_params = init_params
      end

      def to_h
        h1 = {
          type: Helper.sym_to_capitalized_camel_case_str(@type_)
        }

        h2 = case @type_
        when :message
          {
            source: @source.to_h
          }
        when :state_init
          {
            code: @code,
            data: @data,
            library: @library
          }
        when :tvc
          {
            public_key: @public_key,
            init_params: @init_params.to_h
          }
        else
          raise ArgumentError.new("type #{@type_} is unknown; known types: #{TYPES}")
        end

        h1.merge(h2)
      end
    end

    class StateInitParams
      attr_reader :abi, :value

      def initialize(abi:, value:)
        @abi = abi
        @value = value
      end

      def to_h
        {
          abi: abi.to_h,
          value: @value
        }
      end
    end

    class MessageSource
      TYPES = [:encoded, :encoding_params]

      attr_reader :type_, :message, :abi, :address, :deploy_set, :call_set,
        :signer, :processing_try_index

      def initialize(type_:, message: nil, abi:  nil, address: nil, deploy_set: nil,
        call_set: nil, signer:  nil, processing_try_index: 0)
        unless TYPES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end

        @type_ = type_
        @message = message
        @abi = abi
        @address = address
        @deploy_set = deploy_set
        @call_set = call_set
        @signer = signer
        @processing_try_index = processing_try_index
      end

      def to_h
        h1 = {
          type: Helper.sym_to_capitalized_camel_case_str(@type_)
        }

        h2 = case @type_
        when :encoded
          {
            message: @message,
            abi: @abi.nil? ? nil : @abi.to_h
          }
        when :encoding_params
          {
            abi: @abi.to_h,
            address: @address,
            deploy_set: @deploy_set.nil? ? nil : @deploy_set.to_h,
            call_set: @call_set.nil? ? nil : @call_set.to_h,
            signer: @signer.to_h,
            processing_try_index: @processing_try_index
          }
        end

        h1.merge(h2)
      end
    end

    class ParamsOfEncodeMessageBody
      attr_reader :abi, :call_set, :is_internal, :signer, :processing_try_index

      def initialize(abi:, call_set:, is_internal:, signer:, processing_try_index: 0)
        @abi = abi
        @call_set = call_set
        @is_internal = is_internal
        @signer = signer
        @processing_try_index = processing_try_index
      end

      def to_h
        {
          abi: @abi.to_h,
          call_set: @call_set.to_h,
          is_internal: @is_internal,
          signer: @singer.to_h,
          processing_try_index: @processing_try_index
        }
      end
    end

    class ResultOfEncodeMessageBody
      attr_reader :body, :data_to_sign

      def initialize(body:, data_to_sign: nil)
        @body = body
        @data_to_sign = data_to_sign
      end
    end

    class ParamsOfAttachSignatureToMessageBody
      attr_reader :abi, :public_key, :message, :signature

      def initialize(abi:, public_key:, message:, signature:)
        @abi = abi
        @public_key = public_key
        @message = message
        @signature = signature
      end

      def to_h
        {
          abi: @abi.to_h,
          public_key: @public_key,
          message: @message,
          signature: @signature
        }
      end
    end

    class ResultOfAttachSignatureToMessageBody
      attr_reader :body

      def initialize(a)
        @body = a
      end
    end

    class ParamsOfEncodeMessage
      attr_reader :abi, :address, :deploy_set, :call_set, :signer, :processing_try_index

      def initialize(abi:, address: nil, deploy_set: nil, call_set: nil, signer:, processing_try_index: 0)
        @abi = abi
        @address = address
        @deploy_set = deploy_set
        @call_set = call_set
        @signer = signer
        @processing_try_index = processing_try_index
      end

      def to_h
        {
          abi: @abi.to_h,
          address: @address,
          deploy_set: @deploy_set.nil? ? nil: @deploy_set.to_h,
          call_set: @call_set.nil? ? nil: @call_set.to_h,
          signer: @signer.to_h,
          processing_try_index: @processing_try_index
        }
      end
    end

    class ResultOfEncodeMessage
      attr_reader :message, :data_to_sign, :address, :message_id

      def initialize(message:, data_to_sign: nil, address:, message_id:)
        @message = message
        @data_to_sign = data_to_sign
        @address = address
        @message_id = message_id
      end
    end

    class ParamsOfAttachSignature
      attr_reader :abi, :public_key, :message, :signature

      def initialize(abi: , public_key: , message: , signature:)
        @abi = abi
        @public_key = public_key
        @message = message
        @signature = signature
      end

      def to_h
        {
          abi: @abi.to_h,
          public_key: @public_key,
          message: @message,
          signature: @signature
        }
      end
    end

    class ResultOfAttachSignature
      attr_reader :message, :message_id

      def initialize(message:, message_id:)
        @message = message
        @message_id = message_id
      end
    end

    class ParamsOfDecodeMessage
      attr_reader :abi, :message

      def initialize(abi:, message:)
        @abi = abi
        @message = message
      end

      def to_h
        {
          abi: @abi.to_h,
          message: @message
        }
      end
    end

    class MessageBodyType
      VALUES = [:input, :output, :internal_output, :event]
    end

    class DecodedMessageBody
      attr_reader :body_type, :name, :value, :header

      def initialize(body_type:, name:, value: nil, header: nil)
        unless MessageBodyType::VALUES.include?(body_type)
          raise ArgumentError.new("body_type #{body_type} is unknown; known ones: #{MessageBodyType::VALUES}")
        end

        @body_type = body_type
        @name = name
        @value = value
        @header = header
      end

      def to_h
        {
          body_type: Helper.sym_to_capitalized_camel_case_str(@body_type),
          name: @name,
          value: @value,
          header: @header
        }
      end

      def self.from_json(j)
        return nil if j.nil?

        hdr = if !j["header"].nil?
          FunctionHeader.new(
            expire: j["header"]["expire"],
            time: j["header"]["time"],
            pubkey: j["header"]["pubkey"]
          )
        else
          nil
        end

        self.new(
          body_type: self.parse_body_type(j["body_type"]),
          name: j["name"],
          value: j["value"],
          header: hdr
        )
      end

      private

      def self.parse_body_type(s)
        case s.downcase
        when 'input'
          :input
        when 'output'
          :output
        when 'internaloutput'
          :internal_output
        when 'event'
          :event
        else
          raise ArgumentError.new("body_type #{s} is unknown; known ones: #{MessageBodyType::VALUES}")
        end
      end
    end

    class ParamsOfDecodeMessageBody
      attr_reader :abi, :body, :is_internal

      def initialize(abi:, body:, is_internal:)
        @abi = abi
        @body = body
        @is_internal = is_internal
      end

      def to_h
        {
          abi: @abi.to_h,
          body: @body,
          is_internal: @is_internal
        }
      end
    end

    class ParamsOfEncodeAccount
      attr_reader :state_init, :balance, :last_trans_lt, :last_paid

      def initialize(state_init:, balance: nil, last_trans_lt: nil, last_paid: nil)
        @state_init = state_init
        @balance = balance
        @last_trans_lt = last_trans_lt
        @last_paid = last_paid
      end

      def to_h
        {
          state_init: @state_init.to_h,
          balance: @balance,
          last_trans_lt: @last_trans_lt,
          last_paid: @last_paid
        }
      end
    end

    class ResultOfEncodeAccount
      attr_reader :account, :id

      def initialize(account: , id:)
        @account = account
        @id = id
      end

      def to_h
        {
          account: @account.to_h,
          id: @id
        }
      end
    end

    class AbiParam
      attr_reader :name, :type_, :components

      def initialize(name:, type_:, components: [])
        @name = name
        @type_ = type_
        @components = components
      end

      def to_h
        cm_h_s = if !@components.nil?
          @components.compact.map(&:to_h)
        end

        {
          name: @name,
          type: @type_,
          components: cm_h_s
        }
      end

      def self.from_json(j)
        return nil if j.nil?

        comp_s = if j["components"].nil?
          []
        else
          j["components"].compact.map do |x|
            # TODO recursive parsing of AbiParam
            self.from_json(x)
          end
        end

        self.new(
          name: j["name"],
          type_: j["type"],
          components: comp_s
        )
      end
    end

    class AbiEvent
      attr_reader :name, :inputs, :id_

      def initialize(name:, inputs:, id_:)
        @name = name
        @inputs = inputs
        @id_ = id_
      end

      def to_h
        in_h_s = if !@inputs.nil?
          @inputs.compact.map(&:to_h)
        else
          []
        end

        {
          name: @name,
          inputs: in_h_s,
          id: @id_
        }
      end

      def self.from_json(j)
        return nil if j.nil?

        inp_s = if j["inputs"].nil?
          []
        else
          j["inputs"].compact.map do |x|
            # TODO recursive parsing of AbiParam
            AbiParam.from_json(x)
          end
        end

        self.new(
          name: j["name"],
          inputs: inp_s,
          id_: j["id"],
        )
      end
    end

    class AbiData
      attr_reader :key, :name, :type_, :components

      def initialize(key:, name:, type_:, components: [])
        @key = key
        @name = name
        @type_ = type_
        @components = components
      end

      def to_h
        cm_h_s = if !@components.nil?
          @components.compact.map(&:to_h)
        end

        {
          key: @key,
          name: @name,
          type: @type_,
          components: cm_h_s
        }
      end

      def self.from_json(j)
        return nil if j.nil?

        comp_s = if j["components"].nil?
          []
        else
          j["components"].compact.map do |x|
            # TODO recursive parsing of AbiParam
            AbiParam.from_json(x)
          end
        end

        self.new(
          key: j["key"],
          name: j["name"],
          type_: j["type"],
          components: comp_s
        )
      end
    end

    class AbiFunction
      attr_reader :name, :inputs, :outputs, :id_

      def initialize(name:, inputs:, outputs:, id_: nil)
        @name = name
        @inputs = inputs
        @outputs = outputs
        @id_ = id_
      end

      def to_h
        in_h_s = if !@inputs.nil?
          @inputs.compact.map(&:to_h)
        else
          []
        end

        ou_h_s = if !@outputs.nil?
          @outputs.compact.map(&:to_h)
        else
          []
        end

        {
          name: @name,
          inputs: in_h_s,
          outputs: ou_h_s,
          id: @id_
        }
      end

      def self.from_json(j)
        return nil if j.nil?

        inp_s = if j["inputs"].nil?
            []
          else
            j["inputs"].compact.map do |x|
              # TODO recursive parsing of AbiParam
              AbiParam.from_json(x)
            end
          end

        out_s = if j["outputs"].nil?
          []
        else
          j["outputs"].compact.map do |x|
            # TODO recursive parsing of AbiParam
            AbiParam.from_json(x)
          end
        end

        self.new(
          name: j["name"],
          inputs: inp_s,
          outputs: out_s,
          id_: j["id"]
        )
      end
    end

    class AbiContract
      attr_reader :abi_version, :header, :functions, :events, :data

      def initialize(abi_version: nil, header: [], functions: [], events: [], data: [])
        @abi_version = abi_version
        @header = header
        @functions = functions
        @events = events
        @data = data
      end

      def to_h
        @header.compact! if !@header.nil?

        fn_h_s = if !@functions.nil?
          @functions.compact.map(&:to_h)
        end

        ev_h_s = if !@events.nil?
          @events.compact.map(&:to_h)
        end

        dt_h_s = if !@data.nil?
          @data.compact.map(&:to_h)
        end

        {
          # abi_version: @abi_version,
          :"ABI version" => @abi_version,
          header: @header,
          functions: fn_h_s,
          events: ev_h_s,
          data: dt_h_s,
        }
      end

      def self.from_json(j)
        return nil if j.nil?

        fn_s = if j["functions"].nil?
          []
        else
          j["functions"].compact.map { |x| AbiFunction.from_json(x) }
        end

        ev_s = if j["events"].nil?
          []
        else
          j["events"].compact.map { |x| AbiEvent.from_json(x) }
        end

        dt_s = if j["data"].nil?
          []
        else
          j["data"].compact.map {|x| AbiData.from_json(x) }
        end

        self.new(
          abi_version: j["ABI version"],
          

          # header: j["header"],
          header: [],


          functions: fn_s,
          events: ev_s,
          data: dt_s
        )
      end
    end



    #
    # functions
    #

    def self.encode_message_body(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "abi.encode_message_body", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfEncodeMessageBody.new(
              body: resp.result["body"],
              data_to_sign: resp.result["data_to_sign"])
            )
        else
          yield resp
        end
      end
    end

    def self.attach_signature_to_message_body(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "abi.attach_signature_to_message_body", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfAttachSignatureToMessageBody.new(resp.result["body"])
          )
        else
          yield resp
        end
      end
    end

    def self.encode_message(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "abi.encode_message", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfEncodeMessage.new(
              message: resp.result["message"],
              data_to_sign: resp.result["data_to_sign"],
              address: resp.result["address"],
              message_id: resp.result["message_id"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.attach_signature(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "abi.attach_signature", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfAttachSignature.new(
              message: resp.result["message"],
              message_id: resp.result["message_id"])
          )
        else
          yield resp
        end
      end
    end

    def self.decode_message(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "abi.decode_message", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: DecodedMessageBody.from_json(resp.result)
          )
        else
          yield resp
        end
      end
    end

    def self.decode_message_body(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "abi.decode_message_body", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: DecodedMessageBody.from_json(resp.result)
          )
        else
          yield resp
        end
      end
    end

    def self.encode_account(ctx, pr1)
      pr_json = pr1.to_h.to_json
      Interop::request_to_native_lib(ctx, "abi.encode_account", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfEncodeAccount.new(
              account: resp.result["account"],
              id: resp.result["id"]
            )
          )
        else
          yield resp
        end
      end
    end
  end
end