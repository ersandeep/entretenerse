Feature: Retry on Fail Within Milliseconds

  Scenario: User does not see the message immediately, but does within the timeframe specified by the step
    Given I am on page retry_on_fail
    Then I should eventually see "This will load in time"

  Scenario: User does not see the message in time
    Given I am on page retry_on_fail
    # The following step should fail because we purposefully load the content too slowly
    Then I should eventually see "This will load too slowly"
