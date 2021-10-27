require_relative './examples_helper.rb'

class RegisterSigningBoxParamsMock
  attr_reader :public_, :private_

  def initialize(public_:, private_:)
    @public_ = public_
    @private_ = private_
  end

  def request(req)
    t = req["type"]
    case t
    when "GetPublicKey"
      res = TonSdk::Crypto::ResultOfAppSigningBox.new(
        type_: :get_public_key,
        public_key: @public_
      )

      [:success, res]
    else
      [:error, "request type #{t} isn't supported"]
    end
  end

  def notify = puts("notify")

  def to_h
    {
      public: @public_,
      private: @private_
    }
  end
end


TonSdk::Crypto.generate_random_sign_keys(@c_ctx.context) do |res|
  if res.success?
    puts "random sign keys:"
    puts "  public: #{res.result.public_}"
    puts "  secret: #{res.result.secret}"
    puts "\r\n"
    @res = res
  else
    puts "generate_random_sign_keys error #{res.error}"
  end
end

sleep(1)

reg_sb_mock = RegisterSigningBoxParamsMock.new(
  public_: @res.result.public_,
  private_: @res.result.secret
)

TonSdk::Crypto.register_signing_box(@c_ctx.context, app_obj: reg_sb_mock) do |res|
  if res.success?
    sb_handle = res.result.handle
    puts "signinx box handle: #{sb_handle}"

    TonSdk::Crypto.signing_box_get_public_key(
      @c_ctx.context,
      TonSdk::Crypto::RegisteredSigningBox.new(handle: sb_handle)
    ) do |res2|
      if res2.success?
        puts "signing_box_get_public_key: #{res2.result}"
      else
        puts "signing_box_get_public_key error #{res2.error}"
      end
    end
  else
    puts "register_signing_box error #{res.error}"
  end
end

sleep(1)
