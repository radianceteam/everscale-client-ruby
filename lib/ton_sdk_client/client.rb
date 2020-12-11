require 'json'
require_relative './interop.rb'

module TonSdk
  class Client
    class ResultOfVersion
      attr_reader :version

      def initialize(a)
        @version = a
      end
    end

    class ResultOfGetApiReference
      attr_reader :api

      def initialize(a)
        @api = a
      end
    end

    class ResultOfBuildInfo
      attr_reader :build_info

      def initialize(a)
        @build_info = a
      end
    end

    class BuildInfoDependency
      attr_reader :name, :git_commit

      def initialize(name:, git_commit:)
        @name = name
        @git_commit = git_commit
      end

      def self.from_json(j)
        return nil if j.nil?

        self.new(
          name: j["name"],
          git_commit: j["git_commit"]
        )
      end
    end

    class ResultOfBuildInfo
      attr_reader :build_number, :dependencies

      def initialize(build_number:, dependencies:)
        @build_number = build_number
        @dependencies = dependencies
      end
    end

    class AppRequestResult
      attr_reader :type_, :text

      # TODO - 2 constructors
      def initialize(type_:, text:)
        @type_ = type_
        @text = text
      end

      def to_h
        {
          type: @type_,
          text: @text
        }
      end
    end

    class ParamsOfResolveAppRequest
      attr_reader :app_request_id, :result

      def initialize(app_request_id:, result:)
        @app_request_id = app_request_id
        @result = result
      end

      def to_h
        {
          app_request_id: @app_request_id,
          result: @result.to_h
        }
      end
    end












    #
    # methods
    #

    def self.version(ctx)
      Interop::request_to_native_lib(ctx, "client.version", "") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfVersion.new(resp.result["version"])
          )
        else
          yield resp
        end
      end
    end

    def self.get_api_reference(ctx)
      Interop::request_to_native_lib(ctx, "client.get_api_reference", "") do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ResultOfGetApiReference.new(resp.result["api"])
          )
        else
          yield resp
        end
      end
    end

    def self.build_info(ctx)
      Interop::request_to_native_lib(ctx, "client.build_info", "") do |resp|
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








    def self.resolve_app_request(ctx, pr_s)
      pr_json = pr_s.to_h.to_json
      Interop::request_to_native_lib(ctx, "client.resolve_app_request", pr_json) do |resp|
        if resp.success?
          yield NativeLibResponsetResult.new(
            result: ""
          )
          )
        else
          yield resp
        end
      end
    end
  end
end