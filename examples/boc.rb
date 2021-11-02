require_relative './examples_helper.rb'

a1 = "te6ccgEBAQEAWAAAq2n+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE/zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzSsG8DgAAAAAjuOu9NAL7BxYpA"
TonSdk::Boc.parse_message(@c_ctx.context, TonSdk::Boc::ParamsOfParse.new(boc: a1)) do |res|
  if res.success?
    puts "boc_parse_message: #{res.result.parsed}\r\n"
  else
    puts "error boc_parse_message: #{res.error}\r\n"
  end
end

a2 = "te6ccgECBwEAAZQAA7V75gA6WK5sEDTiHFGnH9ILOy2irjKLWTkWQMyMogsg40AAACDribjoE3gOAbYNpCaX4uLeXPQHt2Kw/Jp2OKkR2s+BASyeQM6wAAAg64IXyBX2DobAABRrMENIBQQBAhUEQojmJaAYazBCEQMCAFvAAAAAAAAAAAAAAAABLUUtpEnlC4z33SeGHxRhIq/htUa7i3D8ghbwxhQTn44EAJxC3UicQAAAAAAAAAAAdwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgnJAnYEvIQY6SnQKc3lXk6x1Z/lyplGFRbwAuNtVBi9EeceU3Ojl0F3EkRdylowY5x2qlgHNv4lNZUjhq0WqrLMNAQGgBgC3aADLL4ChL2HyLHwOLub5Mep87W3xdnMW8BpxKyVoGe3RPQAvmADpYrmwQNOIcUacf0gs7LaKuMotZORZAzIyiCyDjQ5iWgAGFFhgAAAEHXC9CwS+wdDGKTmMFkA="
TonSdk::Boc.parse_transaction(@c_ctx.context, TonSdk::Boc::ParamsOfParse.new(boc: a2)) do |res|
  if res.success?
    puts "boc_parse_transaction: (first #{PRINT_RESULT_MAX_LEN} chars): \r\n#{res.result.parsed.to_s[0..PRINT_RESULT_MAX_LEN]}\r\n\r\n"
  end
end


a3 = File.read(File.join(EXAMPLES_DATA_DIR, "boc", "boc3.txt"))
TonSdk::Boc.parse_block(@c_ctx.context, TonSdk::Boc::ParamsOfParse.new(boc: a3)) do |res|
  if res.success?
    puts "boc_parse_block: (first #{PRINT_RESULT_MAX_LEN} chars): \r\n#{res.result.parsed.to_s[0..PRINT_RESULT_MAX_LEN]}\r\n\r\n"
  end
end

a4 = File.read(File.join(EXAMPLES_DATA_DIR, "boc", "block_boc.txt"))
TonSdk::Boc.get_blockchain_config(@c_ctx.context, TonSdk::Boc::ParamsOfGetBlockchainConfig.new(block_boc: a4)) do |res|
  if res.success?
    puts "boc_get_blockchain_config: (first #{PRINT_RESULT_MAX_LEN} chars):\r\n#{res.result.config_boc.to_s[0..PRINT_RESULT_MAX_LEN]}"
  end
end
