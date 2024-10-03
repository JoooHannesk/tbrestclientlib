# Test Cases

## Tests

### Unit Tests


### Integration Tests
The following preconditions are required for the integration tests to run:
- Access to a running ThingsBoard instance (on-premise, self-hosted or thingsboard cloud). *TENANT\_ADMIN* is required for all tests to deliver significant output. Anyhow, tests will not fail if you use *CUSTOMER\_USER* authority but some tests just might be skipped with *passed* result.
- Take `ServerSettings.sample.json`, enter your credentials and save it as `ServerSettings.json` in the same directory. The files reside in `Tests/TBRESTClientLibTests/Resources/HTTPResponses`.

## Run Tests
