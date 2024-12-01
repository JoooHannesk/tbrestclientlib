<p align="center"><img src="https://bitbucket.org/swift-projects/tbrestclientlib/raw/main/Meta/tbrestclientlib-project-avatar.png"></p>

# TBRESTClientLib

Simple client library for [ThingsBoard](https://thingsboard.io) server installations implementing the administration / user-space API (not device API) – written in Swift.

* Implementation against the official ThingsBoard API – [ThingsBoard CE Docs](https://thingsboard.io/docs/)
* Integration tests executed using ThingsBoard CE 3.7.0 with an on-premise installation – [v.3.7.0 API Reference](https://app.swaggerhub.com/apis-docs/johannes_kinzig/thingsboard-rest-api/3.7.0)

## Project Status
This library was initiated as a sub-project of a larger project which required API access to ThingsBoard server instances. As library development can be seen as a whole project by itself, this part then was open-sourced and released to the public.

Please note: This library is continuously growing but **has not implemented all API endpoints** yet. The same applies to the endpoint's responses: This library does not process every fetched element inside the JSON response string (as described by the official API scheme) but neglects the ones which were out of scope for this project and at the time of development. Check ´TbDataModels.swift´ for further details about the properties contained in each schema response model.

Please refer to the [library documentation](http://tbrestclientlib.parallelogon-software.com/documentation/tbrestclientlib)

## Requirements
This library works with and was tested on:

* iOS >= 17.5
* macOS >= 14.0

Linux is currently unsupported bceause of an incompatibility in a way this library uses `URLSession`. A workaround seems to exist but was not further investigated or tested.

## Installation
* Please refer to library documentation: [Installation](http://tbrestclientlib.parallelogon-software.com/documentation/tbrestclientlib/installation)

## Usage
* Please refer to library documentation: [Usage](http://tbrestclientlib.parallelogon-software.com/documentation/tbrestclientlib/usage)

## Unit & Integration Tests
* Please refer to library documentation: [Testing](http://tbrestclientlib.parallelogon-software.com/documentation/tbrestclientlib/tests)

## License
* MIT License
* Copyright (c) 2024 Johannes Kinzig
* see LICENSE.txt

## Contact and Contribution
* Johannes Kinzig – [Mail](mailto:johannes@parallelogon-software.com) – [Web](https://parallelogon-software.com)
* for contribution please refer to official documentation: [Contribution](http://tbrestclientlib.parallelogon-software.com/documentation/tbrestclientlib/)

## About
I am a software engineer mainly foccussing on application development in Python (and now Swift, as well), for my IoT projects I am using ThingsBoard CE. I recently had the chance (and was given the time) to dive into Swift & iOS / macOS development. Soon, I recognized that Swift (including its tools and language concepts) had potential to optimise my current development workflow, so I continued learning. Due to my affinity (and knwoledge) towards ThingsBoard I started to implement parts of the client API using Swift – which can be seen as my first real-world Swift project.
