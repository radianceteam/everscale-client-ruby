# TON SDK client in Ruby and for Ruby

[![Gem Version](https://badge.fury.io/rb/ton_sdk_client.svg)](https://rubygems.org/gems/ton_sdk_client)
[![TON SDK version](https://img.shields.io/badge/TON%20SDK%20version-1.28.0-green)](https://github.com/tonlabs/TON-SDK/tree/1.28.0)

Ruby gem-client bindings for [TON SDK](https://github.com/tonlabs/TON-SDK) which allows one to communicate with [FreeTON](https://freeton.org) blockchain in Ruby.

Note that there're 2 types of versions:
  * `TonSdk::VERSION` - the version of the gem
  * `TonSdk::NATIVE_SDK_VERSION` - the version of the original SDK

and they may not always match each other.



## Installation

Add this to the `Gemfile` of a project:

```ruby
gem 'ton_sdk_client'
```
and run `bundle install`

Alternatively install it directly

```
gem install ton_sdk_client
```


## Requirements

The gem requires `tonclient` native library, appropriate for one's OS; the download links are at:

https://github.com/tonlabs/TON-SDK/#download-precompiled-binaries

Once downloaded, unpack it into a directory of your choice and then set an environmental variable `TON_CLIENT_NATIVE_LIB_NAME` pointing to the full path of a library.

Also, check out the file `.ruby-version` to see which version has been used to develop the gem. Some older versions of ruby may work as well.

## Examples

The examples are located in the `examples` directory, and they cover most the modules.

And here's a simple minimalistic one:

```ruby
require 'ton_sdk_client'

cfg = TonSdk::ClientConfig.new(
  network: TonSdk::NetworkConfig.new(
    endpoints: ["net.ton.dev"]
  )
)

# first, create a context
c_ctx = TonSdk::ClientContext.new(cfg.to_h.to_json)

# next, call a method of a module you want passing a context to it
TonSdk::Client.version(c_ctx.context) do |res|

  # 'res' is of type TonSdk::NativeLibResponsetResult
  # holds either 'result' or 'error'
  # to check which one it is, use boolean methods:
  # res.success? or res.failure?

  if res.success?
    puts "client_version: #{res.result.version}"
  else
    puts "client_version error: #{res.error}"
  end

end
```

In this case, the method `version()` requires only a `context` object. But most others require an additional 2nd argument appropriate for a certain method.
Note that some methods, such some of the `Processing`, `Net`, `Tvm` modules, will continue to run for some time asyncronously delivering a result to a user, for instance, `Processing.process_message(...)` will do it via a callback

```ruby

  my_callback = Proc.new do |a|

    # will be triggered multiple times, asyncronously
    puts "callback fired: #{a}"
  end

  pr1 = TonSdk::Processing::ParamsOfProcessMessage.new(
    message_encode_params: encode_params,
    send_events: true
  )

  TonSdk::Processing.process_message(@c_ctx.context, pr1, my_callback) do |a|
    # [.......]
  end

```

while other methods will deliver a result relatively fast, without a callback, and terminate.


## Implementation coverage, by modules
- ✅ abi
- ✅ boc
- ✅ client
- ✅ crypto
- ✅ net
- ✅ processing
- ✅ tvm
- ✅ utils
- ✅ debot (unstable)


## Documentation

  * https://docs.ton.dev/86757ecb2/p/7941cd-what-is-ton-os
  * https://github.com/tonlabs/TON-SDK/tree/master/docs
  * https://github.com/tonlabs/TON-SDK/blob/master/tools/api.json

Mind the current version of SDK when reading documentation and examples at https://github.com/tonlabs/TON-SDK


## Using it as a developer

Clone the repository

```
git clone git@github.com:radianceteam/ton-client-ruby.git
cd ton-client-ruby
```

### Install the dependencies
```
gem install ffi
gem install concurrent-ruby
```
There may be other dependencies too, check the `gemspec` file for the full list of them.

Being dependent on the environment and OS, the gem `ffi` may produce errors during installation; should it happen, check out its repository https://github.com/ffi/ffi and search for pointers there.


### Run the tests

[Rspec](https://rspec.info/) is used for the tests, which are located in the `spec` directory. To run all the tests:

```
rspec
```

or run a specific set of the tests:

```
rspec spec/boc_spec.rb
```

## Test coverage, by modules
- ✅ abi
- ✅ boc
- ✅ client
- ✅ crypto
- ✅ net
- ✅ processing
- ✅ tvm
- ✅ utils


### Run the examples

The examples are located in the `examples` directory. Run them from the root directory of the gem to avoid issues with paths, for instance:

```
ruby ./examples/crypto.rb

random sign keys:
  public: f19eb4d77f081a562169005a8de3c1ff531c921e6788e30535ab89f0746811e7
  secret: da9aab4e2a57acf083e7abf0dae1274e21e13b0c530271734e135e9cf7b4a228

factorize
  ["494C553B", "53911073"]
```


## Tested at and with

* MacOS Catalina 10.15.5
* Arch Linux x86_64
* TON client native library: `TonSdk::NATIVE_SDK_VERSION`


## References
  * Wiki of the gem FFI: https://github.com/ffi/ffi/wiki ; callbacks: https://github.com/ffi/ffi/wiki/Callbacks

  * https://stackoverflow.com/questions/60689128/ruby-ffi-callback-return-values


## Notes
  * Rspec validators or matchers don't work in a block of a non main thread, therefore in the tests an intermediate variable is used to save a result, a block, and then validate it outside of a block.

  * Testing asyncronous code in Ruby is difficult and can incur hacks. Not all asyncronous code should be tested automatically via Rspec or other libraries, some should be instead tested manually once and then left alone thereafter:
  https://www.mikeperham.com/2015/12/14/how-to-test-multithreaded-code

  * In some of the tests of the gem a "sleep" loop with a timeout are used to wait for an asyncronous operation to deliver a result, and this approach will do, although it can be replaced with a more idiomatic one. Oweing to the side effects, at times some tests may fail. When it happens, try to increase a timeout:

  ```ruby
  timeout_at = get_timeout_for_async_operation()

  # before, 5 seconds by default
  sleep(0.1) until @res || get_now() >= timeout_at

  # after, longer timeout
  sleep(0.1) until @res || get_now() >= (timeout_at * 2)
  ```

  * No automatic generator has been used to generate Ruby classes or bindings to the SDK. Why not? Because no appropriate, simple and functional one has been found.


## Credits

* [Tonlabs.io](https://tonlabs.io)
* [Radiance team](https://github.com/radianceteam)
* [Alex Maslakov](https://github.com/GildedHonour)

## License

Apache 2.0; see the `LICENSE` file

## Changelog

See the `CHANGELOG` file

## Community

* news about FreeTON on Telegram https://t.me/ton_crystal_news
* [FreeTON](https://freeton.org)
