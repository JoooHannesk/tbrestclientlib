# Usage
Description of relevant methods and data models which are used to communicate with your server.

## Currently supported methods

### Initialization and Login (Authentication)
A client object can be initialized in two different ways - and requires to provide login data. Either by username/password or access tokens retrieved by a previous session. The following initializers are implemented as failable and will do so, if their parameters are provided with an empty string.
* ``TBUserApiClient/init(baseUrlStr:username:password:)``: server url, authentication by username and password 
* ``TBUserApiClient/init(baseUrlStr:accessToken:)``: server url, authentication by access token retrieved from a previous session

A thrid option with a custom http session handler exists `init(baseUrlStr:username:password:httpSessionHandler:)` but is intentionally not marked as public because its main purpose is to be used with a mock http client for unit testing.

#### Initialization with username/password
The following listing shows initialization by username and password. After initialization, make sure to register a specific error handler for your application. ``TBHTTPRequest/registerAppErrorHandler(errorHandler:)`` is always called when a request to the server fails. The cause of failure doesn't matter (e.g. server not reachable, incorrect authentication or incorrect server request).
```swift
import TBRESTClientLib
let myClient = try? TBUserApiClient(baseUrlStr: "https://my-thingsboard-iot-server.com", username: "MyUsername", password: "MySuperSecretPassword")

myClient?.registerAppErrorHandler { errorMsg in
    print("Unexpected error: \(errorMsg)")
}
```
Types involved: ``TBAppError``

#### Login when initialized with username/password
When client is initialized with username/password ``TBUserApiClient/login(responseHandler:)`` method can be called afterwards. This generates a login token which remains with the client until it is deinitalized or cleand up.
```swift
try? myClient?.login() { authToken in
    print("\(authToken)")
}
```
Types involved: ``AuthLogin``

#### Initialization with existing access token
Initialization can also be performed by using a previosuly feteched access token (instead of username/password). Procedure mainly stays the same as described above: init client, then register error handler
```swift
let accessToken = AuthLogin(token: "MyAccessToken", refreshToken: "MyRefreshToken")
let myClient2 = try? TBUserApiClient(baseUrlStr: "https://my-thingsboard-iot-server.com", accessToken: accessToken)

myClient2?.registerAppErrorHandler() { errorMsg in
    print("Unexpected error: \(errorMsg)")
}
```
Types involved: ``AuthLogin``, ``TBAppError``

#### Login when initialized with access token
When initialized with an access token it may be the case to *renew* the login (e.g. because the server rejects an invalidated access token). In this case ``TBUserApiClient/login(withUsername:andPassword:responseHandler:)`` needs to be called to obtain a new access token.
```swift
try? myClient2?.login(withUsername: "MyUsername", andPassword: "MySuperSecretPassword"){ authToken in
    print("\(authToken)")
}
```
Types involved: ``AuthLogin``


### Users


## Data Models
When requesting data from your thingsboard server, the response is wrapped into one or more of the following data models:

### Device Profiles

### Devices
