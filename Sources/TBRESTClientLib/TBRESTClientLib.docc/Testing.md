# Testing
This library comes with unit and integration tests.

## Current Test Situation
![Current Test Situation refering to v0.0.20](currentTestSituation)

## Unit Tests
Unit tests were implemented to test basic library functionality. A mock http client and sample response data is required.

Tests are defined in `Tests/TBRESTClientLibTests/UnitTests.swift`, sample response data resides in `Tests/TBRESTClientLibTests/Resources/HTTPResponses`.

The files are named to fit the request functions names and contain sample responses (as JSON).

## Integration Tests
This library contains integration tests to serve multiple purposes:
- test library functionality
- test with real response data
- test compatibility with different server versions

### Integration tests require different user privileges
The integration tests distinguish between tests requiring *TENANT\_ADMIN* and *CUSTOMER\_USER* authority. Therefore the following preconditions are required for all integration tests to run (and pass):
- Access to a running ThingsBoard instance (on-premise, self-hosted or thingsboard cloud).
- A user with *TENANT\_ADMIN* and another user with *CUSTOMER\_USER* authority.
- Tests requiring *CUSTOMER\_USER* authority are located at: `Tests/TBRESTClientLibTests/IntegrationTests.swift`
- Tests requiring *TENANT\_ADMIN* authority are located at: `Tests/TBRESTClientLibTests/IntegrationTestsAdmin.swift`
- Tests requiring *CUSTOMER\_USER* authority can be run with *TENANT\_ADMIN* authority, as well.

### How to run integration tests requiring *CUSTOMER\_USER* authority
- Take `ServerSettings.sample.json`, enter your credentials and save it as `ServerSettings.json` in the same directory. The file resides in `Tests/TBRESTClientLibTests/Resources/`.
- `ServerSettings.json` is set in `.gitignore` to prevent accidential leakage of login data.

### How to run integration tests requiring *TENANT\_ADMIN* authority
- Take `ServerSettingsAdmin.sample.json`, enter your credentials and save it as `ServerSettingsAdmin.json` in the same directory. The file resides in `Tests/TBRESTClientLibTests/Resources/`.
- `ServerSettingsAdmin.json` is set in `.gitignore` to prevent accidential leakage of login data.

## Run Tests
- Xcode:
    - Menu: *Product* > *Test*
    - Keyboard: ⌘U
- Terminal (SwiftPM):
    - `swift test --disable-swift-testing` (uses *XCTest* only, therefore you can skip *Swift Testing* tests)
