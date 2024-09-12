# ``TBRESTClientLib``

Simple client library for ThingsBoard server installations implementing the administration / user-space API (not device API) – written in Swift.

## Overview

ThingsBoard CE is an IoT platform offering device management, device administration and comes with several possibilities to store and visualise time-series data from e.g. sensors, field-devices, machine control systems, etc. This package implements (in parts) the ThingsBoars administration / user-space API (not device API) for comfortable programmatical interaction with a ThingsBoard server.

## Topics

### Installation

- ``TBUserApiClient``

- ``TBUserApiClient/init(baseUrlStr:usernameStr:passwordStr:)``

- ``TBUserApiClient/login(responseHandler:)``
