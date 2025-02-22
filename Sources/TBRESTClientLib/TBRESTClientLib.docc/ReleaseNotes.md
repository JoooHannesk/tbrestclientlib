# Release Notes

## Client – Version 0.0.9
* Types with an integer-timestamp `ts` property as **milliseconds since the epoche** now contain a property `tsDt` reflecting the timestamp as swift-native `Date()` type. (refer ``TimeseriesResponse/tsDt``)
* Implementation against the official ThingsBoard API – [ThingsBoard CE Docs](https://thingsboard.io/docs/)
* Integration tests executed using
    * ThingsBoard CE 3.9.0 with an private cloud installation
    * ThingsBoard CE 3.8.0 with an on-premise installation
* ThingsBoard CE 3.7.0 with an on-premise installation – [v.3.7.0 API Reference](https://app.swaggerhub.com/apis-docs/johannes_kinzig/thingsboard-rest-api/3.7.0)


## Client - Version 0.0.8
* Implementation against the official ThingsBoard API – [ThingsBoard CE Docs](https://thingsboard.io/docs/)
* Integration tests executed using ThingsBoard CE 3.7.0 with an on-premise installation – [v3.7.0 API Reference](https://app.swaggerhub.com/apis-docs/johannes_kinzig/thingsboard-rest-api/3.7.0)
* Added additional initializer to init client with a *token* and *refreshToken* (instead of *username* and *password*). Refer to <doc:Usage> for further details.


## Client - Version 0.0.7
* Implementation against the official ThingsBoard API – [ThingsBoard CE Docs](https://thingsboard.io/docs/)
* Integration tests executed using ThingsBoard CE 3.7.0 with an on-premise installation – [v3.7.0 API Reference](https://app.swaggerhub.com/apis-docs/johannes_kinzig/thingsboard-rest-api/3.7.0)
