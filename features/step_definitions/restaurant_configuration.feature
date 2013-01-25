Feature: Restaurant configuration
  As a person responsible for reservations in a restaurant
  I want to enter my restaurant data (name, email, location, opening hours, tables count) into the system
  So that my customers can make online reservations

  Background:
    Given a restaurant called "Denis"
    And I am logged in as an authorized and authenticated user

  Scenario: Successful configuration
    When I enter restaurant configuration page
    Then I see configuration form with name filled in
    When I enter restaurant street "lalalala"
    And I enter restaurant name "Denis Xyz"
    And I enter restaurant city "Warszawa"
    And I enter restaurant zip code "00-444"
    And I enter restaurant telephone "22 555 44 55"
    And I enter restaurant tables sets:
      | capacity | count |
      | 1        | 12    |
      | 2        | 10    |
      | 3        | 0     |
      | 4        | 5     |
      | 5        | 0     |
      | 6        | 0     |
      | 7        | 0     |
      | 8        | 0     |
    And I enter restaurant opening hours:
      | week_day_number | opened_from | opened_until | closed | opened_24h |
      | 1               | 12:00       | 22:00        |        |            |
      | 2               | 12:00       | 22:00        |        |            |
      | 3               |             |              | true   |            |
      | 4               | 12:00       | 22:00        |        |            |
      | 5               |             |              |        | true       |
      | 6               |             |              |        | true       |
      | 7               |             |              | true   |            |
    And I check that I want to receive sms notifications
    And I enter notifications telephone number "555-555-555"
    And I enter facebook page id "77707070707"
    And I press save configuration button
    Then System saves configuration I have entered

  Scenario: No required data provided
    When I enter restaurant configuration page
    Then I see configuration form with name filled in
    And I enter restaurant name ""
    And I press save configuration button
    Then I should see there are configuration errors
    And I should see that name is required
    And I should see that tables sets are required
    And I should see that opening hours on each day are required

  Scenario: Invalid tables counts
    When I enter restaurant configuration page
    And I enter restaurant tables sets:
      | capacity | count |
      | 1        | -1    |
    And I press save configuration button
    Then I should see there are configuration errors
    And I should see count should be a non-negative integer

  Scenario: Empty tables set count
    When I enter restaurant configuration page
    And I enter restaurant tables sets:
      | capacity | count |
      | 1        |       |
    And I press save configuration button
    Then the 1 person field should be empty

  Scenario: Adding new tables set
    When I enter restaurant configuration page
    And I press add tables set button-link
    Then I should see new tables set dialog
    When I set capacity to 11, count to 2 and confirm dialog
    Then I see configuration form with tables set containing 2 tables for 11 people
    And I see tables set has been added

  Scenario: Modifying existing tables set
    When I enter restaurant configuration page
    And I press add tables set button-link
    Then I should see new tables set dialog
    When I set capacity to 2, count to 2 and confirm dialog
    Then I see configuration form with tables set containing 2 tables for 2 people

  Scenario: Restaurant closed every day
    When I enter restaurant configuration page
    Then I see configuration form with name filled in
    And I enter restaurant name "Denis Xyz"
    And I enter restaurant tables sets:
      | capacity | count |
      | 1        | 12    |
    And I enter restaurant opening hours:
      | week_day_number | opened_from | opened_until | closed | opened_24h |
      | 1               |             |              | true   |            |
      | 2               |             |              | true   |            |
      | 3               |             |              | true   |            |
      | 4               |             |              | true   |            |
      | 5               |             |              | true   |            |
      | 6               |             |              | true   |            |
      | 7               |             |              | true   |            |
    And I press save configuration button
    Then I should see there are configuration errors
    And I should see that restaurant cannot be closed every day

  Scenario: Removing existing tables set
    When I enter restaurant configuration page
    And I press remove button-link within 4 people tables set
    Then I see configuration form without tables set for 4 people

  Scenario: Sms notifications number validation errors
    When I enter restaurant configuration page
    And I check that I want to receive sms notifications
    And I press save configuration button
    Then I should see there are configuration errors
    And I should see I should enter sms notifications telephone number
    When I enter notifications telephone number "999"
    And I press save configuration button
    Then I should see there are configuration errors
    And I should see that telephone should contain 7 digits