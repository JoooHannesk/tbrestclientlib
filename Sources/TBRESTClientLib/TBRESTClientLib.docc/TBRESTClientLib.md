# ``TBRESTClientLib``

Simple client library for ThingsBoard server installations implementing the administration / user-space API (not device API) – written in Swift.

## Overview
 [ThingsBoard](https://thingsboard.io) is an IoT platform offering device management, device administration and comes with several possibilities to store and visualise time-series data from e.g. sensors, field-devices, machine control systems, etc. This library implements (in parts) the ThingsBoard administration / user-space API (not device API) for comfortable programmatical interaction with a ThingsBoard server. For compatibility with ThingsBoard server refer to <doc:ReleaseNotes>.

This documentation tries to refere to the official ThingsBoard nomenclature as well as official API documentation as close as possible. It may did not work out all the time.

## Disclaimer
This library is an independent implementation developed by its author(s) - see below - and is **not affiliated with, endorsed by, or officially associated with ThingsBoard Inc. in any way**. For further details [mail the author](mailto:johannes@parallelogon-software.com) and/or refer to this library's <doc:License>.

## Repository
* This library is hostet on Bitbucket: [https://bitbucket.org/swift-projects/tbrestclientlib.git](https://bitbucket.org/swift-projects/tbrestclientlib/src/main/)
* This documentation is served from: [https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib](https://tbrestclientlib.kinzig-developer-docs.com/documentation/tbrestclientlib)

## Release History
See what's new: <doc:ReleaseNotes>
* Version 0.0.9 - 18.12.2024
* Version 0.0.8 - 23.11.2024
* Version 0.0.7 - 20.11.2024

## Compatibility to ThingsBoard Server
For details regarding ThingsBoard server compatibility, please refer to the <doc:ReleaseNotes>.

## Development Status
This library was initiated as a sub-project of a larger project which required API access to ThingsBoard server instances. Because library development can be seen as a full project by itself, this part then was open-sourced and released to the public.

Please note: This library is continuously growing but **has not implemented all API endpoints** yet. The same applies to the endpoint's responses: This library does not process every fetched element inside the JSON response string (as described by the official API scheme). It neglects the ones which were out of the parent-project's scope. Refer to <doc:Usage> for further details about the properties contained in each schema response model.

## Requirements
This library works with and was tested on:
* iOS >= 17.5
* macOS >= 14.0

Linux is currently unsupported bceause of an incompatibility in a way this library uses `URLSession`. A workaround seems to exist but was not further investigated, implemented or tested. (But it was added as a ToDo 😉)

## Contact the author(s)
Johannes Kinzig – [Mail](mailto:mail@johanneskinzig.com) – [Web](https://johanneskinzig.com)

## Contribution
Contribution is always welcome, please refer to documentation: <doc:DevelopmentContribution>

## Topics
- <doc:ReleaseNotes>
- <doc:Installation>
- <doc:Usage>
- <doc:Testing>
- <doc:DevelopmentContribution>
- <doc:License>
