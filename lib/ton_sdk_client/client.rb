require 'json'
require_relative './interop.rb'

module TonSdk
  module Client

    #
    # types
    #

    module ErrorCode
      NOT_IMPLEMENTED = 1
      INVALID_HEX = 2
      INVALID_BASE64 = 3
      INVALID_ADDRESS = 4
      CALLBACK_PARAMS_CANT_BE_CONVERTED_TO_JSON = 5
      WEBSOCKET_CONNECT_ERROR = 6
      WEBSOCKET_RECEIVE_ERROR = 7
      WEBSOCKET_SEND_ERROR = 8
      HTTP_CLIENT_CREATE_ERROR = 9
      HTTP_REQUEST_CREATE_ERROR = 10
      HTTP_REQUEST_SEND_ERROR = 11
      HTTP_REQUEST_PARSE_ERROR = 12
      CALLBACKNOTREGISTERED = 13
      NET_MODULE_NOT_INIT = 14
      INVALID_CONFIG = 15
      CANNOT_CREATE_RUNTIME = 16
      INVALID_CONTEXT_HANDLE = 17
      CANNOT_SERIALIZE_RESULT = 18
      CANNOT_SERIALIZE_ERROR = 19
      CANNOT_CONVERT_JS_VALUE_TO_JSON = 20
      CANNOT_RECEIVE_SPAWNED_RESULT = 21
      SET_TIMER_ERROR = 22
      INVALID_PARAMS = 23
      CONTRACTS_ADDRESS_CONVERSION_FAILED = 24
      UNKNOWN_FUNCTION = 25
      APP_REQUEST_ERROR = 26
      NO_SUCH_REQUEST = 27
      CANNOT_SEND_REQUEST_RESULT = 28
      CANNOT_RECEIVE_REQUEST_RESULT = 29
      CANNOT_PARSE_REQUEST_RESULT = 30
      UNEXPECTED_CALLBACK_RESPONSE = 31
      CANNOT_PARSE_NUMBER = 32
      INTERNAL_ERROR = 33
      INVALID_HANDLE = 34
    end

    ResultOfVersion = KwStruct.new(:version)
    ResultOfGetApiReference = KwStruct.new(:api)

    BuildInfoDependency = KwStruct.new(:name, :git_commit) do
      def self.from_json(j)
        return nil if j.nil?

        self.new(
          j["name"],
          j["git_commit"]
        )
      end
    end

    ResultOfBuildInfo = KwStruct.new(:build_number, :dependencies)
    ParamsOfAppRequest = KwStruct.new(:app_request_id, :request_data)

    class AppRequestResult
      TYPES = [:ok, :error]
      attr_reader :type_, :text, :result

      def initialize(type_:, result: nil, text: nil)
        unless TYPES.include?(type_)
          raise ArgumentError.new("type #{type_} is unknown; known types: #{TYPES}")
        end
        @type_ = type_

        if !result.nil? && !text.nil?
          raise ArgumentError.new("both 'result' and 'text' may not contain values at the same time")
        end

        if @type_ == :ok
          @result = result
        elsif @type_ == :error
          @text = text
        end
      end

      def to_h
        {
          type: Helper.sym_to_capitalized_case_str(@type_),

          # may be either one instead?
          result: @result,
          text: @text
        }
      end
    end

    ParamsOfResolveAppRequest = KwStruct.new(:app_request_id, :result) do
      def to_h
        {
          app_request_id: @app_request_id,
          result: @result.to_h
        }
      end
    end


    #
    # functions
    #


    # returns a version of TON
    # params:
    # +ctx+:: +ClientContext+ object
    def self.version(ctx)
      Interop::request_to_native_lib(ctx, "client.version") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfVersion.new(version: resp.result["version"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_api_reference(ctx)
      Interop::request_to_native_lib(ctx, "client.get_api_reference") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGetApiReference.new(api: resp.result["api"])
          )
        else
          yield resp
        end
      end
    end

    def self.build_info(ctx)
      Interop::request_to_native_lib(ctx, "client.build_info") do |resp|
        if resp.success?
          dp_s = resp.result["dependencies"].map { |x| BuildInfoDependency.from_json(x) }
          yield NativeLibResponsetResult.new(
            result: ResultOfBuildInfo.new(
              build_number: resp.result["build_number"],
              dependencies: dp_s
            )
          )
        else
          yield resp
        end
      end
    end

    def self.resolve_app_request(ctx, params)
      Interop::request_to_native_lib(ctx, "client.resolve_app_request", params) do |resp|
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
