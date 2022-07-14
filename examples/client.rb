require_relative './examples_helper.rb'


EverSdk::Client.version(@c_ctx.context) do |res|
  if res.success?
    puts "version: #{res.result.version}"
  else
    puts "error: #{res.error}"
  end
end

EverSdk::Client.get_api_reference(@c_ctx.context) do |res|
  if res.success?
    puts "\r\n"
    puts "get_api_reference (first #{PRINT_RESULT_MAX_LEN} chars):\r\n"
    short_res = cut_off_long_string(res.result.api)
    puts short_res
  else
    puts "error: #{res.error}"
  end
end

EverSdk::Client.build_info(@c_ctx.context) do |res|
  if res.success?
    puts "build_info build_number: #{res.result.build_number}"
    puts "build_info dependencies:"
    res.result.dependencies.each do |x|
      puts "    #{x.name}, #{x.git_commit}"
    end
  else
    puts "error: #{res.error}"
  end
end
