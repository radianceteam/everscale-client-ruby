require_relative './examples_helper.rb'

EverSdk::Crypto.factorize(
  @c_ctx.context,
  EverSdk::Crypto::ParamsOfFactorize.new(composite: "17ED48941A08F981")
) do |res|
  if res.success?
    puts 'factorize:'
    puts "  #{res.result.factors}"
  else
    puts "  error: #{res.error}"
  end
end
