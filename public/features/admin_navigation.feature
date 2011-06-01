Feature: Admin should have access to all pages available in one central location

    Scenario: check categories
        Given I am on admin page
        When I follow "Categories"
        Then I should see "Select category"

