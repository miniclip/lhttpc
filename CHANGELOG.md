# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.0.0] - 2026-10-28

### Added
- type specs to all functions [Sérgio Almeida]

### Changed
- [dep.] `tls_certificate_check` from 1.21.0 to 1.35.0 [Sérgio Almeida]
- CI to run on OTP 27 to 29 [Sérgio Almeida]
- `elvis.config` to disable `no_receive_without_timeout` and `no_throw` rules [Sérgio Almeida]
- exported type `lhttpc:socket()` from `_` to `inet:socket() | ssl:sslsocket()` [Sérgio Almeida]

### Fixed
- TLS connections rejected with `{verify_ssl_cert, false}` on OTP 26 and later [Sérgio Almeida]
- `elvis.config` to the `elvis_core` 6.x format [Sérgio Almeida]

### Removed
- compatibility with OTP 22 to 26 [Sérgio Almeida]

## [4.3.2] - 2024-03-11

### Changed

- [dep.] `tls_certificate_check` from 1.9.0 to 1.21.0 [Dinis Rosário]

## [4.3.1] - 2022-04-19

### Added

- `rebar3_ex_doc` + `make ex_doc-dry` [Paulo Oliveira]

### Changed

- `edoc`-based doc. to `ex_doc`-based doc. [Paulo Oliveira]

## [4.3.0] - 2021-09-16

### Changed

- TLS certificate validation to prepare for
[DST Root CA X3 expiration](https://blog.voltone.net/post/30) [Guilherme Andrade]
- [dep.] `tls_certificate_check` from 1.7.0 to 1.9.0 [Guilherme Andrade]

## [4.2.0] - 2021-07-16

### Added

- `rebar3_hank` [Paulo Oliveira]

### Changed

- CI container approach to `setup-beam` with cache [Paulo Oliveira]
- CA bundles, to base them on the latest Mozilla Included CA Certificate List [Guilherme Andrade]

### Removed

- compatibility with OTP 21

## [4.1.2] - 2021-03-15

### Changed

- [dep.] `tls_certificate_check` from 1.1.1 to 1.2.0 [Paulo Oliveira]

### Fixed

- `rebar3` + `certifi` (now indirectly removed) compilation issues [Paulo Oliveira]

## [4.1.1] - 2021-03-04

### Removed

- unused dep `parse_trans` [Paulo Oliveira]

## [4.1.0] - 2021-03-04

### Changed

- CI from 23.1 to 23.2 [Paulo Oliveira]
- `rebar.config` to a fresher look-and-feel [Paulo Oliveira]

### Removed

- all mentions of `@spec` [Paulo Oliveira]
- `test/simple_load.erl` [Paulo Oliveira]

## [4.0.0] - 2020-12-10

### Added

- all types that are exposed via API functions to their respective module's
`export_type` sections [Paulo Oliveira]

### Removed

- lhttpc_types.hrl [Paulo Oliveira]
- lhttpc.hrl [Paulo Oliveira]
- defined types that are unused internally (and not exported) [Paulo Oliveira]

## [3.3.0] - 2020-05-22

### Added

- compatibility with OTP 23

### Changed

- Travis constraints: updated version as per our current reality; added `make check`
- minimum supported version to 19.3
- README.md: removed outdated info; added test-related info

### Fixed

- some broken tests

## [3.2.0] - 2020-04-30

### Changed

- source of dependencies to Hex, for quicker builds

### Removed

- support for OTP 17
- support for OTP 18
- support for rebar2

## [3.1.0] - 2020-03-12

### Added

- exported types lhttpc:result/0 and lhttpc:headers/0

### Changed

- CA bundles, to base them on the latest Mozilla Included CA Certificate List

### Fixed

- OTP 21 dialyzer warnings

## [3.0.7] - 2019-09-25

### Fixed

- unwarranted throwing of exception(s) to consumer during racy pool creation

## [3.0.6] - 2019-09-24

### Fixed

- warning on rebar3 over ssl_verify_fun's missing .app description

## [3.0.5] - 2019-02-01

### Fixed

- potential compilation issues when importing lib. as a dependency on OTP 21

## [3.0.4] - 2019-01-23

### Fixed

- bad specification of returned error reasons on :request/{4,5,6,9}

## [3.0.3] - 2019-01-18

### Fixed

- dialyzer warnings

## [3.0.2] - 2018-09-13

### Fixed

- OTP 21 compile-time warnings

## [3.0.1] - 2018-08-07

### Fixed

- rebar2 support

## [3.0.0] - 2018-08-07

### Added

- missing boot dependencies

### Changed

- application was rebar3ified while still being usable as a rebar2 dependency
- application version is now determined from git
- HTTPS requests are now secure by default

### Fixed

- unintelligibility of which test cases failed (main suite)
- low test coverage due to broken test cases that prevented others from running

### OLD STYLE CHANGE LOG BELOW

```text
Version ?:
* Add support for connect_options
    * Enables the user to pass socket options, for instance ip and port,
      that will be used when connecting the socket
    * Allows the user to specify SSL options during the connect phase
* Add support for "streaming" of entities
* Add start/0 and stop/0
* Fix for unexpected messages after request has been completed
    * When the client process is trapping exits (which some eunit versions seem
      to be doing by default) there would be {'EXIT', Pid, normal} messages left
      after completing requests which came from the lhttpc_client process.
      These are now avoided.
* Add rebar support (thanks to Benoit Chesneau)
* Add support for HTTP basic auth (Filipe Manana)
* Add support for IPv6 (Filipe Manana)
* Several URL parsing fixes (Filipe Manana)
* Add support for proxies via HTTP CONNECT method (Filipe Manana)
* Add connection limit to the connection pool (Filipe Manana)
* Add suport for using multiple connection pools - different requests can now
  use different connection pools (Filipe Manana)

Version 1.2.5:
* Fix for decoding chunked HTTP responses with extraneous whitespace
  (thanks to Bob Ippolito)
    * api.facebook.com includes extra whitespace in its chunked HTTP response
      length, e.g. "6  \r\n" instead of "6\r\n".

Version 1.2.4:
* Fix handling of HTTP response code 304 (patch by Ben Slavin)

Version 1.2.3:
* Fix handling of unexpected 100 Continue response (patch by Magnus Henoch)

Version 1.2.2:
* Fix Host header, add port number (reported by Benoit Chesneau)

Version 1.2.1:
* Fix confusion of arguments in request/9 (introduced in 1.2.0)

Version 1.2.0:
* Add support for options
    * {connect_timeout, Milliseconds}: Aborts the connect phase after
      Milliseconds
    * {send_retry, N}: The client will retry sending the request N times
      if the connection is closed
* Add support for downloading chunked transfer encoding
* More consistent error handling
    * The client can either return {ok, Result} or {error, Reason}. Reason
      (which wasn't very well defined before) can now be:
        * connection_closed: The server closed the connection on us (N times
          in case it happens just after sending the request)
        * connect_timeout: If the TCP stack gives up or we hit the
          connect_timeout option
        * timeout: If the overall request timeout value is hit
    * All other errors (socket, protocol etc. will result in a runtime error)
* Better connection handling (issues #2 and #3 on bitbucket.org/etc/lhttpc)
    * Now understands what to do with connections to servers < HTTP/1.1
    * Now respects "Connection: close" in request headers, which means
      clients can choose to not use persistent connections
* RFC Compliance
    * Fix reading of chunked encoding since section 3.6 claims that "All
      transfer-coding values are case-insensitive"
    * Support for responses that doesn't have an entity body (thanks to Steve
      Ellis)
        * No body for the HEAD and OPTIONS (unless indicated for the latter)
          methods
        * Don't try to read a body when receiving a 204 status

Version 1.1.2:
* Fix minor error with {active, once} instead of {active, true} in manager
* Remove socket and try to find another if the manager can't set controlling
  process due to socket error
* Improve test suite

Version 1.1.1:
* Fix problem with empty lists in dicts when last socket is consumed
* Improve test suite to include cover report

Version 1.1.0:
* Support for configurable connection timeout

Version 1.0.0:
* Initial version
* Persistent connections have hardcoded timeout
```
