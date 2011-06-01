Feature: Admin should be able to setup and run crawlers
    In order to fill in entretenerse with data
    As a admin
    I want to setup and run crawlers

    @javascripts
    Scenario: Crawlers list is empty
        Given I am on the crawlers page
        Then I should see "There is no crawlers configured yet."

    Scenario: Add new crawler
        Given I am on the crawlers page
        When I click on "Add One Now"
        Then I should see "Configure New Crawler"

    #@javascripts
    #Scenario: Crawlers list has records
        #Given I have few crawlers configured
        #When I go to the crawlers page
        #Then I should not see "admin.crawlers.no_crawlers" translated
        #And I should see the grid

    #Scenario: Inactivate crawler
        #Given I have active crawlers
        #When I click "Activate" button
        #Then I should see "Activate this crawler" popup

    #Scenario: Activate item
        #Given I have few inactive crawlers

    #Scenario: Run crawler now
