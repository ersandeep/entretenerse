Feature: Admin should have access to all pages available in one central location
    In order to show off cucumber with capybara
    As a Ruby developer
    I want to run some scenarios with different browser simulators

    @javascript
    Scenario: check categories
        Given I am on the admin page
        When I follow "Categories"
        Then I should see "Select category"

    @javascript
    Scenario: check crawlers
        Given I am on the admin page
        When I follow "Crawlers"
        Then I should see "Crawlers"
        And I should see "There is no crawlers configured yet."

