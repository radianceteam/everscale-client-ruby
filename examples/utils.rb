require_relative './examples_helper.rb'

account_id = "fcb91a3a3816d0f7b8c2c76108b8a9bc5a6b7a55bd79f8ab101c52db29232260"

p1 = EverSdk::Utils::ParamsOfConvertAddress.new(
  address: account_id,
  output_format: EverSdk::Utils::AddressStringFormat.new(type_: :hex)
)
EverSdk::Utils.convert_address(@c_ctx.context, p1) do |res|
  if res.success?
    puts "convert_address"
    puts "\tsource: #{account_id}"
    puts "\tresult: #{res.result.address}"
  end
end
