require_relative './examples_helper.rb'


TonSdk::Client.version(@c_ctx.context) do |res|
  if res.success?
    puts "version: #{res.result.version}"
  else
    puts "error: #{res.error}"
  end
end

TonSdk::Client.get_api_reference(@c_ctx.context) do |res|
  if res.success?
    puts "\r\n"
    puts "get_api_reference (first #{PRINT_RESULT_MAX_LEN} chars):\r\n"
    puts "#{res.result.api.to_s[0..PRINT_RESULT_MAX_LEN]}"
  else
    puts "error: #{res.error}"
  end
end

TonSdk::Client.build_info(@c_ctx.context) do |res|
  if res.success?
    puts "build_info build_number: #{res.result.build_number}"
    puts "build_info dependencies"
    res.result.dependencies.each do |x|
      puts "    #{x.name}, #{x.git_commit}"
    end
  else
    puts "error: #{res.error}"
  end
end