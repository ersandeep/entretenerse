Feature: Admin should have access to all pages available in one central location
    In order to show off cucumber with capybara
    As a Ruby developer
    I want to run some scenarios with different browser simulators

    @javascript @focus
    Scenario: View occurrence
        Given category exists with name: "Theatre"
        And an event exists with title: "Theatre Super Show", sponsor_id: 1, category: that category
        And a place exists with name: "Times Square"
        And attribute exists with name: "Theatre", value: "Theatre"
        And an occurrence exists with event: the event, date: "2011-02-09 23:50:00", hour: "23:50:00", place: the place
        And the occurrence has that attribute
        Given I am on the homepage
        When I follow "Theatre Super Show"
        Then I should see "Times Square"
        And I should see "Rating"
        And I should see "Entretenerse - Theatre Super Show - Theatre - Times Square"
