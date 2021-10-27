require 'json'

require_relative './kw_struct.rb'
require_relative './interop.rb'
require_relative './types.rb'
require_relative './helper.rb'

require_relative './config.rb'
require_relative './client.rb'
require_relative './utils.rb'
require_relative './crypto.rb'
require_relative './abi.rb'
require_relative './boc.rb'
require_relative './net.rb'
require_relative './tvm.rb'
require_relative './processing.rb'
require_relative './debot.rb'


module TonSdk
  class ClientContext
    attr_reader :context

    def initialize(cfg_json)
      cfg_json_tc_str = Interop::TcStringData::from_string(cfg_json)
      ptr = Interop::tc_create_context(cfg_json_tc_str)
      ctx_tc_str = Interop::tc_read_string(ptr)
      if (ctx_tc_str != nil) && (ctx_tc_str[:len] > 0)
        cont_str = ctx_tc_str[:content].read_string(ctx_tc_str[:len])
        ctx_json = JSON.parse(cont_str)
        ctx_val = ctx_json["result"]
        if ctx_val != nil
          @context = ctx_val
          @requests = Concurrent::Hash.new()
          ObjectSpace.define_finalizer(self, self.class.finalize(@context))
        else
          raise SdkError.new(message: "unable to create context: #{ctx_json}")
        end

        Interop::tc_destroy_string(ptr)
      else
        raise SdkError.new("unable to create context")
      end
    end

    def self.finalize(ctx)
      Proc.new do
        if (ctx != nil) && (ctx > 0)
          Interop::tc_destroy_context(ctx)
        end
      end
    end
  end
end
