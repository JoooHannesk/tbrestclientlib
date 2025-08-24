![project_avatar_icon](https://bitbucket.org/swift-projects/tbrestclientlib/raw/main/Meta/tbrestclientlib-project-avatar.png)

# TBRESTClientLib

Simple client library for [ThingsBoard](https://thingsboard.io) servers - implementing the administration / user-space API (not device API) – written in Swift.

## 🛠 Development Status – Available Functions (v0.0.16)
This library is continuously growing but has **not yet implemented all API endpoints**. Currently supported functionality:

+ [Login](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#Initialization-and-Login-Authentication)
+ [Logout](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#Logout)
+ [Read own user profile](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#User-Profile)
+ [Read customer info](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage/#Customer-Info)
+ [Read devices and device profiles](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#Devices-and-device-profiles)
+ [Read attributes](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#Entity-attributes)
+ [Set / delete attributes](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#saveEntityAttributes)
+ [Read time-series data](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#Entitiy-timeseries-data)
+ [Manipulate / delete time-series data](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#deleteEntityTimeseries)

Please refer to the documentation for further details regarding the [development status](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/#Development-Status).

This library was initiated as a sub-project of a larger project which required API access to ThingsBoard server instances. Because library development can be seen as a full project by itself, this part then was open-sourced and released to the public.
Please note: This library is continuously growing but **has not implemented all API endpoints** yet. The same applies to the endpoint's responses: This library does not process every fetched element inside the JSON response string (as described by the official API scheme). It neglects the ones which were out of the parent-project's scope. Refer to ´TbDataModels.swift´ for further details about the properties contained in each schema response model.

## Documentation
+ 📚 [Library Documentation](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib)
+ 🏠 [Library Home](https://johanneskinzig.com/tbrestclientlib.html)

## Release history
[See what's new](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/releasenotes)

* Version 0.0.15 - 2025-08-19
* Version 0.0.14 - 2025-08-18
* Version 0.0.13 – 2025-07-17
* Version 0.0.10 - 11.06.2025
* Version 0.0.9 - 18.12.2024
* Version 0.0.7 - 20.11.2024

Implementation against the official ThingsBoard API – [ThingsBoard CE Docs](https://thingsboard.io/docs/). All integration tests ran against real ThingsBoard installations:

* ThingsBoard CE 3.9.0 with an on-premise installation – [v.3.9.0 API Reference](https://app.swaggerhub.com/apis/johannes_kinzig/thingsboard-rest-api/3.9.0)
* ThingsBoard CE 3.8.0 with an on-premise installation
* ThingsBoard CE 3.7.0 with an on-premise installation – [v.3.7.0 API Reference](https://app.swaggerhub.com/apis-docs/johannes_kinzig/thingsboard-rest-api/3.7.0)

## Requirements
This library works with and was tested on:

* iOS >= 17.5
* macOS >= 14.0

Linux is currently unsupported due to an incompatibility in how this library uses `URLSession`. While a potential workaround exists, it has not been fully investigated or tested. Additionally, since version 0.0.11, *OSLog* is used for logging, which is also currently unsupported by Swift on Linux. (Both were added as a ToDo 😉)

* Please refer to library DocC documentation: [Requirements](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/#Requirements)

## Installation
* Please refer to library documentation: [Installation](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/installation)

## Usage
* Please refer to library documentation: [Usage](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage)

## Unit & Integration Tests
* Please refer to library documentation: [Testing](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/testing)

## License
* MIT License
* Copyright (c) 2024 Johannes Kinzig
* see LICENSE.txt

## Contact and Contribution
* Johannes Kinzig – [Mail](mailto:mail@johanneskinzig.com) – [Web](https://johanneskinzig.com)
* for contribution please refer to official documentation: [Contribution](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/developmentcontribution)
    
## Disclaimer
This library is an independent implementation developed by [its author(s)](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/#Contact-the-authors) and is **not affiliated with, endorsed by, or officially associated with ThingsBoard Inc. in any way**. For further details [mail the author](mailto:johannes@parallelogon-software.com) and/or refer to this library's [license](https://bitbucket.org/swift-projects/tbrestclientlib/src/main/LICENSE.txt).

