![project_avatar_icon](https://github.com/JoooHannesk/tbrestclientlib/blob/main/Meta/tbrestclientlib-project-avatar.png)

# TBRESTClientLib
Simple ReST client library for ThingsBoard - implementing the administration / user-space API (not device API) – written in Swift.

## 👓 Overview
[ThingsBoard](https://thingsboard.io) is an IoT platform that provides device management and administration, along with multiple options for storing and visualizing time-series data from sensors, field devices, machine control systems, and similar sources.

This library implements selected parts of the ThingsBoard administration and user-space API (not the device API) to enable convenient, programmatic interaction with a ThingsBoard server. For server compatibility details, please refer to the <doc:ReleaseNotes>.

Throughout this documentation, we aim to follow the official ThingsBoard nomenclature and API documentation as closely as possible. While every effort is made to stay aligned, minor deviations may occur.

## 🛠 Development Status – Available Functions (v0.0.20)
This library is **under active development** and is steadily expanding its coverage of the ThingsBoard API. As a result, **not all API endpoints are available yet**. For a detailed and up-to-date overview of the currently supported endpoints, please refer to the [Usage](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage) section.

### Currently supported functionality
* [Login](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#Initialization-and-Login-Authentication)
* [Logout](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#Logout)
* [Read own user profile](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#User-Profile)
* [Read customer info](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage/#Customer-Info)
* [Read devices and device profiles](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#Devices-and-device-profiles)
* [Add, Edit and Delete devices](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#Add-Edit-and-Delete-devices)
* [Read attributes](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#Entity-attributes)
* [Set / delete attributes](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#saveEntityAttributes)
* [Read time-series data](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#Entitiy-timeseries-data)
* [Manipulate / delete time-series data](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage#deleteEntityTimeseries)

⚠️ Caution: Prior to version 0.1.0, the public API may undergo refinements. Any breaking changes are expected to be manageable for existing users.

## 🥾 Motivation
This library originated as a sub-project of a larger system that required reliable and convenient API access to ThingsBoard server instances. As development progressed, it became clear that the API layer represented a substantial project on its own. Consequently, this component was extracted, generalized, and open-sourced for public use.

Please note that the library is under active development and does not yet cover the complete ThingsBoard API surface. The same limitation applies to response models: not all fields defined in the official API schemas are currently mapped or processed. Only those elements required by the original parent project are included.

For a detailed overview of the properties supported by each response model, please refer to `TbDataModels.swift`

## 📝 Documentation
+ 📚 [Library Documentation](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib)
+ 🏠 [Library Home](https://johanneskinzig.com/tbrestclientlib.html)

## 🕰️ Release history
[See what's new](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/releasenotes)

* Version 0.0.20 – 2025-12-29
* Version 0.0.19 – 2025-11-08
* Version 0.0.15 - 2025-08-19
* Version 0.0.14 - 2025-08-18
* Version 0.0.13 – 2025-07-17

## 💻 Requirements
This library works with and was tested on:

* iOS >= 17.5
* macOS >= 14.0

For compatibility to specific ThingsBoard server versions, refer to [ThingsBoard Server Compatibility](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/thingsboardservercompatibility) in this library documentation.

* Please refer to library DocC documentation: [Requirements](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/#Requirements)

## 💾 Installation
* Please refer to library documentation: [Installation](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/installation)

## 📱 Usage
* Please refer to library documentation: [Usage](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/usage)

## 🧪 Unit & Integration Tests
* Please refer to library documentation: [Testing](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/testing)

## 📑 License
* [MIT License](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/license)
* Copyright (c) 2024 Johannes Kinzig
* see LICENSE.txt

## 📇 Contact and Contribution
* Johannes Kinzig – [Mail](mailto:mail@johanneskinzig.com) – [Web](https://johanneskinzig.com)
* for contribution please refer to official documentation: [Contribution](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/developmentcontribution)
    
## 📑 Disclaimer
This library is an independent implementation developed by [its author(s)](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib/#Contact-the-authors) and is **not affiliated with, endorsed by, or officially associated with ThingsBoard Inc. in any way**. For further details [mail the author](mailto:mail@johanneskinzig.com) and/or refer to this library's [license](https://github.com/JoooHannesk/tbrestclientlib/blob/main/LICENSE.txt).

