# Testing
This library comes with unit and integration tests.

## Current Test Situation
![Current Test Situation refering to v0.0.11](currentTestSituation)

## Unit Tests
Unit tests were implemented to test basic library functionality. A mock http client and sample response data is required. Tests are defined in `Tests/TBRESTClientLibTests/UnitTests.swift`, sample response data resides in `Tests/TBRESTClientLibTests/Resources/HTTPResponses`. The files are named to fit the request functions names and contain sample responses (as JSON).

## Integration Tests
This library contains integration tests to serve multiple purposes:
- test library functionality
- test with real response data
- test compatibility with different server versions


The following preconditions are required for the integration tests to run:
- Access to a running ThingsBoard instance (on-premise, self-hosted or thingsboard cloud). *TENANT\_ADMIN* is required for all tests to deliver significant output. Anyhow, tests will not fail if you use *CUSTOMER\_USER* authority but some tests just might be skipped with *passed* result.
- Take `ServerSettings.sample.json`, enter your credentials and save it as `ServerSettings.json` in the same directory. The file resides in `Tests/TBRESTClientLibTests/Resources/`.

- `ServerSettings.json` is set in `.gitignore` to prevent accidential leakage of login data.

## Run Tests
- Xcode:
    - Menu: *Product* > *Test*
    - Keyboard: ⌘U
- Terminal (SwiftPM):
    - `swift test`
