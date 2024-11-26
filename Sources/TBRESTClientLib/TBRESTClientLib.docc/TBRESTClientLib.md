# ``TBRESTClientLib``

Simple client library for ThingsBoard server installations implementing the administration / user-space API (not device API) – written in Swift.

## Overview
 [ThingsBoard](https://thingsboard.io) is an IoT platform offering device management, device administration and comes with several possibilities to store and visualise time-series data from e.g. sensors, field-devices, machine control systems, etc. This package implements (in parts) the ThingsBoard administration / user-space API (not device API) for comfortable programmatical interaction with a ThingsBoard server. For compatibility with ThingsBoard server refer to <doc:ReleaseNotes>.

This documentation tries to refere to the official ThingsBoard nomenclature as well as official API documentation as close as possible. It may did not work out all the time.

## Development Status
This library was initiated as a sub-project of a larger project which required API access to ThingsBoard server instances. As library development can be seen as a whole project by itself, this part then was open-sourced and released to the public.

Please note: This library is continuously growing but **has not implemented all API endpoints** yet. The same applies to the endpoints responses: This library does not process every fetched element inside the JSON response string (as described by the official API scheme) but neglects the ones which were out of scope at the time of development. Check ´TbDataModels.swift´ for further details about the properties contained in each schema response model.


## Topics
- <doc:ReleaseNotes>
- <doc:Installation>
- <doc:Usage>
- <doc:Tests>
- <doc:DevelopmentContribution>
- <doc:License>
