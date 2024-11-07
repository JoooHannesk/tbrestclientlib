<img src="https://bitbucket.org/swift-projects/tbrestclientlib/raw/main/Meta/tbrestclientlib-project-avatar.png">

# TBRESTClientLib

Simple client library for [ThingsBoard](https://thingsboard.io) server installations implementing the administration / user-space API (not device API) – written in Swift.

* Implementation against the official ThingsBoard API – [ThingsBoard CE Docs](https://thingsboard.io/docs/)
* Integration tests executed using ThingsBoard CE 3.7.0 with an on-premise installation – [v.3.7.0 API Reference](https://app.swaggerhub.com/apis-docs/johannes_kinzig/thingsboard-rest-api/3.7.0)

## Project Status
This project was started as part of larger project which required API access to ThingsBoard instances – this library is continuously growing but **has not implemented all ThingsBoard API endpoints**. I tried to grab all elements for each endpoint as defined by the ThingsBoard api-schema but omitted the ones which seemed too far away for my current use case. Check ´TbDataModels.swift´ for detailed properties contained in each schema model.  

## Installation
* TODO - documentation, link to official documentation

## Usage
* TODO - documentation, link to official documentation

## Integration Tests
* TODO: describe how to edit ServerSettings.sample.json to run integration tests against own ThingsBoard installation / server
* ( Comment: Perform Integration Test with users which have TENANT_ADMIN, and CUSTOMER_USER authority )

## License
* MIT License
* Copyright (c) 2024 Johannes Kinzig
* see LICENSE.txt

## Contact
* Johannes Kinzig – [Mail](mailto:johannes@parallelogon-software.com) – [Web](https://parallelogon-software.com)

## About
I am a software engineer mainly foccussing on application development in Python (and now Swift, as well), for my IoT projects I am using ThingsBoard CE. I recently had the chance (and was given the time) to dive into Swift & iOS / macOS development. Soon, I recognized that Swift (including its tools and language concepts) had potential to optimise my current development workflow, so I continued learning. Due to my affinity (and knwoledge) to ThingsBoard I started to implement parts of the client API using Swift – which can be seen as my first real-world Swift project.
