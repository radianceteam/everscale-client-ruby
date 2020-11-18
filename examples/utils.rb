require_relative './examples_helper.rb'

account_id = "fcb91a3a3816d0f7b8c2c76108b8a9bc5a6b7a55bd79f8ab101c52db29232260"

p1 = TonSdk::Utils::ParamsOfConvertAddress.new(
  address: account_id,
  output_format: TonSdk::Utils::AddressStringFormat.new(type_: :hex)
)
TonSdk::Utils.convert_address(@c_ctx.context, p1) do |res|
  if res.success?
    puts "convert_address"
    puts "  source: #{account_id}"
    puts "  result: #{res.result.address}"
  end
end
