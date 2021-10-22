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
          type: Helper.sym_to_capitalized_case_str(@type_)
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

    FunctionHeader = Struct.new(:expire, :time, :pubkey, keyword_init: true)

    CallSet = Struct.new(:function_name, :header, :input, keyword_init: true) do
      def initialize(function_name:, header: nil, input: nil)
        super
      end

      def to_h
        {
          function_name: function_name,
          header: header.to_h,
          input: input
        }
      end
    end

    DeploySet = Struct.new(:tvc, :workchain_id, :initial_data, :initial_pubkey, keyword_init: true) do
      def initialize(tvc:, workchain_id: nil, initial_data: nil, initial_pubkey: nil)
        super
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
          type: Helper.sym_to_capitalized_case_str(@type_)
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

    STATIC_INIT_SOURCE_TYPES = [:message, :state_init, :tvc]
    StateInitSource = Struct.new(
      :type_,
      :source,
      :code,
      :data,
      :library,
      :tvc,
      :public_key,
      :init_params,
      keyword_init: true
    ) do
      def initialize(
        type_:,
        source: nil,
        code: nil,
        data: nil,
        library: nil,
        tvc: nil,
        public_key: nil,
        init_params: nil
      )
        unless STATIC_INIT_SOURCE_TYPES.include?(type_)
          raise ArgumentError.new("unknown type: #{type_}; known types: #{STATIC_INIT_SOURCE_TYPES}")
        end
        super
      end

      def to_h
        h1 = {
          type: Helper.sym_to_capitalized_case_str(@type_)
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
          raise ArgumentError.new("unknown type: #{@type_}; known types: #{STATIC_INIT_SOURCE_TYPES}")
        end

        h1.merge(h2)
      end
    end

    StateInitParams = Struct.new(:abi, :value, keyword_init: true) do
      def initialize(abi:, value:)
        super
      end
    end


    MESSAGE_SOURCE_TYPES = [:encoded, :encoding_params]
    MessageSource = Struct.new(
      :type_,
      :message,
      :abi,
      :address,
      :deploy_set,
      :call_set,
      :signer,
      :processing_try_index,
      keyword_init: true
    ) do
      def initialize(
        type_:,
        message: nil,
        abi:  nil,
        address: nil,
        deploy_set: nil,
        call_set: nil,
        signer:  nil,
        processing_try_index: 0
      )
        unless MESSAGE_SOURCE_TYPES.include?(type_)
          raise ArgumentError.new("unknown type: #{type_}; known types: #{MESSAGE_SOURCE_TYPES}")
        end

        super
      end

      def to_h
        h1 = {
          type: Helper.sym_to_capitalized_case_str(@type_)
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

    ParamsOfEncodeMessageBody = Struct.new(:abi, :call_set, :is_internal, :signer, :processing_try_index, keyword_init: true) do
      def initialize(abi:, call_set:, is_internal:, signer:, processing_try_index: 0)
        super
      end
    end

    ResultOfEncodeMessageBody = Struct.new(:body, :data_to_sign, keyword_init: true) do
      def initialize(body:, data_to_sign: nil)
        super
      end
    end

    ParamsOfAttachSignatureToMessageBody = Struct.new(:abi, :public_key, :message, :signature, keyword_init: true) do
      def initialize(abi:, public_key:, message:, signature:)
        super
      end
    end

    ResultOfAttachSignatureToMessageBody = Struct.new(:body)

    ParamsOfEncodeMessage = Struct.new(
      :abi,
      :address,
      :deploy_set,
      :call_set,
      :signer,
      :processing_try_index,
      keyword_init: true
    ) do
      def initialize(
        abi:,
        address: nil,
        deploy_set: nil,
        call_set: nil,
        signer:,
        processing_try_index: 0
      )
        super
      end

      def to_h
        {
          abi: abi.to_h,
          address: address,
          deploy_set: deploy_set&.to_h,
          call_set: call_set&.to_h,
          signer: signer.to_h,
          processing_try_index: processing_try_index
        }
      end
    end

    ResultOfEncodeMessage = Struct.new(:message, :data_to_sign, :address, :message_id, keyword_init: true) do
      def initialize(message:, data_to_sign: nil, address:, message_id:)
        super
      end
    end

    ParamsOfAttachSignature = Struct.new(:abi, :public_key, :message, :signature, keyword_init: true) do
      def initialize(abi:, public_key:, message:, signature:)
        super
      end

      def to_h
        {
          abi: abi&.to_h,
          public_key: public_key,
          message: message,
          signature: signature
        }
      end
    end

    ResultOfAttachSignature = Struct.new(:message, :message_id, keyword_init: true) do
      def initialize(message:, message_id:)
        super
      end
    end

    ParamsOfDecodeMessage = Struct.new(:abi, :message, keyword_init: true) do
      def initialize(abi:, message:)
        super
      end

      def to_h
        {
          abi: abi&.to_h,
          message: message
        }
      end
    end

    class DecodedMessageBody
      MESSAGE_BODY_TYPE_VALUES = [:input, :output, :internal_output, :event]
      attr_reader :body_type, :name, :value, :header

      def initialize(body_type:, name:, value: nil, header: nil)
        unless MESSAGE_BODY_TYPE_VALUES.include?(body_type)
          raise ArgumentError.new("unknown body_type: #{body_type}; known ones: #{MESSAGE_BODY_TYPE_VALUES}")
        end

        @body_type = body_type
        @name = name
        @value = value
        @header = header
      end

      def to_h
        {
          body_type: Helper.sym_to_capitalized_case_str(@body_type),
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
          raise ArgumentError.new("unknown body_type: #{s}; known ones: #{MESSAGE_BODY_TYPE_VALUES}")
        end
      end
    end

    ParamsOfDecodeMessageBody = Struct.new(:abi, :body, :is_internal, keyword_init: true) do
      def initialize(abi:, body:, is_internal:)
        super
      end

      def to_h
        {
          abi: abi&.to_h,
          body: body,
          is_internal: is_internal
        }
      end
    end

    ParamsOfEncodeAccount = Struct.new(:state_init, :balance, :last_trans_lt, :last_paid, keyword_init: true) do
      def initialize(state_init:, balance: nil, last_trans_lt: nil, last_paid: nil)
        super
      end
    end

    ResultOfEncodeAccount = Struct.new(:account, :id_, keyword_init: true) do
      def initialize(account:, id_:)
        super
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
      attr_reader :abi_version, :version, :header, :functions, :events, :data, :fields

      def initialize(
        abi_version: nil,
        version: nil,
        header: [],
        functions: [],
        events: [],
        data: [],
        fields: []
      )
        @abi_version = abi_version
        @version = version
        @header = header
        @functions = functions
        @events = events
        @data = data
        @fields = fields
      end

      def to_h
        {
          abi_version: @abi_version,
          :"ABI version" => @abi_version, #TODO
          version: @version,
          header: @header,
          functions: @functions&.map(&:to_h),
          events: @events&.map(&:to_h),
          data: @data&.map(&:to_h),
          fields: @fields&.map(&:to_h)
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

        fl_s = if j["fields"].nil?
          []
        else
          j["fields"].compact.map {|x| AbiParam.from_json(x) }
        end

        self.new(
          abi_version: j["ABI version"],
          version: j["version"],
          header: j["header"],
          functions: fn_s,
          events: ev_s,
          data: dt_s,
          fields: fl_s
        )
      end
    end

    ParamsOfEncodeInternalMessage = Struct.new(
      :abi,
      :address,
      :src_address,
      :deploy_set,
      :call_set,
      :value,
      :bounce,
      :enable_ihr,
      keyword_init: true
    ) do
      def initialize(
        abi: nil,
        address: nil,
        src_address: nil,
        deploy_set: nil,
        call_set: nil,
        value:,
        bounce: nil,
        enable_ihr: nil
      )
        super
      end
    end

    ResultOfEncodeInternalMessage = Struct.new(
      :message,
      :address,
      :message_id,
      keyword_init: true
    ) do
      def initialize(message:, address:, message_id:)
        super
      end
    end

    ParamsOfDecodeAccountData = Struct.new(:abi, :data, keyword_init: true) do
      def to_h
        {
          abi: abi&.to_h,
          data: data
        }
      end
    end

    ResultOfDecodeData = Struct.new(:data)

    ParamsOfUpdateInitialData = Struct.new(
      :data,
      :abi,
      :initial_data,
      :initial_pubkey,
      :boc_cache,
      keyword_init: true
    ) do
      def to_h
        {
          data: data,
          abi: abi&.to_h,
          initial_data: initial_data,
          initial_pubkey: initial_pubkey,
          boc_cache: boc_cache&.to_h
        }
      end
    end

    ResultOfUpdateInitialData = Struct.new(:data)

    ParamsOfDecodeInitialData = Struct.new(:data, :abi, keyword_init: true) do
      def to_h
        {
          data: data,
          abi: abi&.to_h
        }
      end
    end

    ResultOfDecodeInitialData = Struct.new(:initial_pubkey, :initial_data, keyword_init: true)

    #
    # functions
    #

    def self.encode_message_body(ctx, params)
      Interop::request_to_native_lib(ctx, "abi.encode_message_body", params) do |resp|
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

    def self.attach_signature_to_message_body(ctx, params)
      Interop::request_to_native_lib(ctx, "abi.attach_signature_to_message_body", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfAttachSignatureToMessageBody.new(resp.result["body"])
          )
        else
          yield resp
        end
      end
    end

    def self.encode_message(ctx, params)
      Interop::request_to_native_lib(ctx, "abi.encode_message", params) do |resp|
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

    def self.attach_signature(ctx, params)
      Interop::request_to_native_lib(ctx, "abi.attach_signature", params) do |resp|
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

    def self.decode_message(ctx, params)
      Interop::request_to_native_lib(ctx, "abi.decode_message", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: DecodedMessageBody.from_json(resp.result)
          )
        else
          yield resp
        end
      end
    end

    def self.decode_message_body(ctx, params)
      Interop::request_to_native_lib(ctx, "abi.decode_message_body", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: DecodedMessageBody.from_json(resp.result)
          )
        else
          yield resp
        end
      end
    end

    def self.encode_account(ctx, params)
      Interop::request_to_native_lib(ctx, "abi.encode_account", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfEncodeAccount.new(
              account: resp.result["account"],
              id_: resp.result["id"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.encode_internal_message(ctx, params)
      Interop::request_to_native_lib(ctx, "abi.encode_internal_message", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfEncodeInternalMessage.new(
              message: resp.result["message"],
              address: resp.result["address"],
              message_id: resp.result["message_id"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.decode_account_data(ctx, params)
      Interop::request_to_native_lib(ctx, "abi.decode_account_data", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfDecodeData.new(
              resp.result["data"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.update_initial_data(ctx, params)
      Interop::request_to_native_lib(ctx, "abi.update_initial_data", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfUpdateInitialData.new(
              resp.result["data"]
            )
          )
        else
          yield resp
        end
      end
    end

    def self.decode_initial_data(ctx, params)
      Interop::request_to_native_lib(ctx, "abi.decode_initial_data", params) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfDecodeInitialData.new(
              initial_pubkey: resp.result["initial_pubkey"],
              initial_data: resp.result["initial_data"]
            )
          )
        else
          yield resp
        end
      end
    end
  end
end
