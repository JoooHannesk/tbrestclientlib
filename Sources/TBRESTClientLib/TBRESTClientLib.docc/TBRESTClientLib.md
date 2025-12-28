# ``TBRESTClientLib``

Simple client library for ThingsBoard server installations implementing the administration / user-space API (not device API) – written in Swift.

## 👓 Overview
[ThingsBoard](https://thingsboard.io) is an IoT platform that provides device management and administration, along with multiple options for storing and visualizing time-series data from sensors, field devices, machine control systems, and similar sources.

This library implements selected parts of the ThingsBoard administration and user-space API (not the device API) to enable convenient, programmatic interaction with a ThingsBoard server. For server compatibility details, please refer to the <doc:ReleaseNotes>.

Throughout this documentation, we aim to follow the official ThingsBoard nomenclature and API documentation as closely as possible. While every effort is made to stay aligned, minor deviations may occur.

## 🛠 Development Status – Available Functions (v0.0.20)
This library is **under active development** and is steadily expanding its coverage of the ThingsBoard API. As a result, **not all API endpoints are available yet**. For a detailed and up-to-date overview of the currently supported endpoints, please refer to the <doc:Usage> section.

### Currently supported functionality
* <doc:Usage/Initialization-and-Login-Authentication>
* <doc:Usage/Logout>
* <doc:Usage/User-Profile>
* <doc:Usage/Customer-Info>
* <doc:Usage/Devices-and-device-profiles>
* <doc:Usage/Entity-attributes>
* <doc:Usage/Entitiy-timeseries-data>

⚠️ Caution: Prior to version 0.1.0, the public API may undergo refinements. Any breaking changes are expected to be manageable for existing users.

## 🥾 Motivation
This library originated as a sub-project of a larger system that required reliable and convenient API access to ThingsBoard server instances. As development progressed, it became clear that the API layer represented a substantial project on its own. Consequently, this component was extracted, generalized, and open-sourced for public use.

Please note that the library is under active development and does not yet cover the complete ThingsBoard API surface. The same limitation applies to response models: not all fields defined in the official API schemas are currently mapped or processed. Only those elements required by the original parent project are included.

For a detailed overview of the properties supported by each response model, please refer to <doc:Usage>.

## 📝 Documentation
* 📦 This library is hostet on GitHub: [https://github.com/JoooHannesk/tbrestclientlib.git](https://github.com/JoooHannesk/tbrestclientlib.git)
* 📚 This documentation is served from: [https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib)
* 🏠 Library Home: [https://johanneskinzig.com/tbrestclientlib.html](https://johanneskinzig.com/tbrestclientlib.html)

## 💻 Requirements
This library works with and was tested on:
* iOS >= 17.5
* macOS >= 14.0

Linux is currently unsupported due to an incompatibility in how this library uses `URLSession`. While a potential workaround exists, it has not been fully investigated or tested. Additionally, since version 0.0.11, *OSLog* is used for logging, which is also currently unsupported by Swift on Linux. (Both were added as a ToDo 😉)

## 💾 Installation
* Please refer to section: <doc:Installation>

## 📱 Usage
* Please refer to section: <doc:Usage>

## 🧪 Unit & Integration Tests
* Please refer to section: <doc:Testing>

## 🕰️ Release history
* Refer to the <doc:ReleaseNotes>

## 📑 License
* MIT <doc:License>
* Copyright (c) 2024 Johannes Kinzig
* see LICENSE.txt

## 📇 Contact the author(s) and Contribution
* Johannes Kinzig – [Mail](mailto:mail@johanneskinzig.com) – [Web](https://johanneskinzig.com)
* Contribution is always welcome, please refer to section: <doc:DevelopmentContribution>

## 📑 Disclaimer
This library is an independent implementation developed by its author(s) - see below - and is **not affiliated with, endorsed by, or officially associated with ThingsBoard Inc. in any way**. For further details [mail the author](mailto:mail@johanneskinzig.com) and/or refer to this library's <doc:License>.
