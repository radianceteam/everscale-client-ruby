require_relative './examples_helper.rb'

# 1
account = File.read(File.join(EXAMPLES_DATA_DIR, "tvm", "encoded_account.txt"))
pr1 = TonSdk::Tvm::ParamsOfRunGet.new(
  account: account,
  function_name: "participant_list"
)

TonSdk::Tvm.run_get(@c_ctx.context, pr1) do |res|
  if res.success?
    puts "success1 #{res.result}"
  else
    puts "error1: #{res.error}"
  end
end

# 2
elector_address = "-1:3333333333333333333333333333333333333333333333333333333333333333"
input = elector_address.split(':')[1]

pr2 = TonSdk::Tvm::ParamsOfRunGet.new(
  account: account,
  function_name: "compute_returned_stake",
  input:  "0x#{input}"
)

TonSdk::Tvm.run_get(@c_ctx.context, pr2) do |res|
  if res.success?
    puts "success2 #{res.result.output}"
  else
    puts "error2: #{res.error}"
  end
end


# 3
pr3 = TonSdk::Tvm::ParamsOfRunGet.new(
  account: account,
  function_name: "past_elections"
)

TonSdk::Tvm.run_get(@c_ctx.context, pr3) do |res|
  if res.success?

    val = res.result.output[0][0][0]
    puts "success3 #{val}"

    is_eq = val == "1588268660"
    puts "output3 == 1588268660 ? #{is_eq}"
  else
    puts "error3: #{res.error}"
  end
end


# required, to keep the main thread alive
loop do
  puts "[*] to interrupt the loop press Ctrl+C\r\n"
  sleep 1
end