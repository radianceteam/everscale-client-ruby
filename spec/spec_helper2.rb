require 'base64'

CONTRACTS_PATH = "data/contracts"
TESTS_DATA_DIR = "spec/data/"
ASYNC_OPERATION_TIMEOUT_SECONDS = 5

def get_now_for_async_operation
  Process.clock_gettime(Process::CLOCK_MONOTONIC)
end

def get_timeout_for_async_operation
  Process.clock_gettime(Process::CLOCK_MONOTONIC) + ASYNC_OPERATION_TIMEOUT_SECONDS
end

def b64_from_hex(hex_digest)
  [[hex_digest].pack("H*")].pack("m0")
end
