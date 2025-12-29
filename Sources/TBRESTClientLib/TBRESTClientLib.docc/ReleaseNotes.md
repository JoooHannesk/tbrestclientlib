# Release Notes

## Client – Version 0.0.20
* Released: 2025-12-29
* Added following endpoint functions:
    * Get device by ID: ``TBUserApiClient/getDeviceById(deviceId:responseHandler:)``
    * Get device info by ID: ``TBUserApiClient/getDeviceInfoById(deviceId:responseHandler:)``
    * Save device (to add or update a device): ``TBUserApiClient/saveDevice(name:label:deviceId:type:deviceProfileId:tenantId:customerId:accessToken:responseHandler:)``
    * Delete device: ``TBUserApiClient/deleteDevice(deviceId:responseHandler:)``
* API change: All parameters that previously took an ID as a String have been updated to accept a UUID instead.

## Client - Version 0.0.19
* Released: 2025-11-08
* Removed a convenience initializer but extended the main initializer to keep the overal signature: no public-facing API changes
* Introduced an API url versioning-scheme and added the coresponding arguments to the initializer signature with a default parameter to prevent public-facing API changes (therefore this remains undocumented for now) 

## Client - Version 0.0.16
* Released: 2025-08-24
* Added ``TBUserApiClient/logout()`` method to request user logout on ThingsBoard server.

## Client - Version 0.0.15
* Released: 2025-08-19
* Added ``TBUserApiClient/getAccessToken()`` for retrieving the currently active access token, enabling easier session recovery without re-authentication.
* Introduced ``TBUserApiClient/getLoginData()`` to access the server URL and username used during initialization (password is intentionally not exposed for security reasons).

## Client – Version 0.0.14
* Released: 2025-08-18
* Added a method ``TBUserApiClient/getCustomerById(customerId:responseHandler:)`` to retrieve the customer the requesting user belongs to
* Refer to <doc:Usage/Customer-Info>
* Integration tests executed using *ThingsBoard CE 3.9.0* with a private cloud installation

## Client – Version 0.0.13
* Released: 2025-07-17
* Removed `intVal` from ``MplValueType`` to prevent floating point numbers having a zero as only decimal digit (e.g. 20.0) to be treated as integers.
* Values (``AttributesResponse`` or ``TimeseriesResponse``) now support: Bool, Double, String

## Client – Version 0.0.11
* Released: 2025-06-21
* Added an optional parameter `logger` to initializers to support logging functionality (requires an *OSLog* instance)
* See <doc:Usage/Initialization-and-Login-Authentication> for what's new
* Integration tests executed using ThingsBoard CE 3.9.0 with a private cloud installation [v.3.9.0 API Reference](https://apidocs.kinzig-developer-docs.com/tbrestclientlib/?urls.primaryName=v3.9.0)

## Client – Version 0.0.10
* Released: 2025-06-11
* Improved the error handling mechanism
* ``TBHTTPRequest/registerErrorHandler(apiErrorHandler:systemErrorHandler:)`` now distinguishes between API generated errors and system thrown errors
* See <doc:Usage/Initialization-with-usernamepassword> for what's new
* Integration tests executed using ThingsBoard CE 3.9.0 with a private cloud installation [v.3.9.0 API Reference](https://apidocs.kinzig-developer-docs.com/tbrestclientlib/?urls.primaryName=v3.9.0)

## Client – Version 0.0.9
* Released: 2024-12-28
* Types with an integer-timestamp `ts` property as **milliseconds since the epoche** now contain a property `tsDt` reflecting the timestamp as swift-native `Date()` type. (refer ``TimeseriesResponse/tsDt``)
* Implementation against the official ThingsBoard API – [ThingsBoard CE Docs](https://thingsboard.io/docs/)
* Integration tests executed using
    * ThingsBoard CE 3.9.0 with a private cloud installation
    * ThingsBoard CE 3.8.0 with an on-premise installation
* ThingsBoard CE 3.7.0 with an on-premise installation – [v.3.7.0 API Reference](https://apidocs.kinzig-developer-docs.com/tbrestclientlib/?urls.primaryName=v3.7.0)


## Client - Version 0.0.8
* Released: 2024-12-23
* Implementation against the official ThingsBoard API – [ThingsBoard CE Docs](https://thingsboard.io/docs/)
* Integration tests executed using ThingsBoard CE 3.7.0 with an on-premise installation – [v3.7.0 API Reference](https://apidocs.kinzig-developer-docs.com/tbrestclientlib/?urls.primaryName=v3.7.0)
* Added additional initializer to init client with a *token* and *refreshToken* (instead of *username* and *password*). Refer to <doc:Usage> for further details.


## Client - Version 0.0.7
* Released: 2024-11-20
* Implementation against the official ThingsBoard API – [ThingsBoard CE Docs](https://thingsboard.io/docs/)
* Integration tests executed using ThingsBoard CE 3.7.0 with an on-premise installation – [v3.7.0 API Reference](https://apidocs.kinzig-developer-docs.com/tbrestclientlib/?urls.primaryName=v3.7.0)
