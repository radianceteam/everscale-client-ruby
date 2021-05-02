# Changelog

1.13.x
-----
* TON SDK version: 1.13.0
* the changes are according the ones of TON SDK

1.12.x
-----
* TON SDK version: 1.12.0
* internal refactoring
* the changes are according the ones of TON SDK

1.11.x
-----
* TON SDK version: 1.11.0
* the changes are according the ones of TON SDK


1.10.x
-----
* TON SDK version: 1.10.0
* the changes are according the ones of TON SDK


1.9.x
-----
* TON SDK version: 1.9.0
* remove TonSdk::NATIVE_LIB_VERSION, rename TonSdk::SDK_VERSION to TonSdk::NATIVE_SDK_VERSION
* the changes are according the ones of TON SDK


1.7.x
-----
* TON SDK version: 1.7.0
* the changes are according the ones of TON SDK

1.3.x
-----
* TON SDK version: 1.6.0
* the changes are according the ones of TON SDK

1.2.x
-----
* TON SDK version: 1.5.2
* min Ruby version: 3.0


1.1.x
-----
* new `Client` `.resolve_app_request()`
* new `Net` `.query()`, `.suspend()`, `.resume()`
* new `Debot`
* new `Boc` `.get_boc_hash()`
* new `Crypto` `.register_signing_box()`, `.get_signing_box()`, `.signing_box_get_public_key()`,
`.signing_box_sign()`, `remove_signing_box()`
* new paramentes in `NetworkConfig`; particularly

```
  server_address: "example.com"
```

becomes

```
  endpoints: ["example.com"]
```

check out the main repository for the details

* new data types/classes in several modules


1.0.0
-----
* The first version has been released.