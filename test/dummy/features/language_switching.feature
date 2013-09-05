Feature: Users can switch the interfaces language
  Scenario: A user wants to see the page in English
    Given I am on the dashboard page
    When I choose "English" from the language options
    Then the page displays the interface in "English"
    And reloading the dashboard page does not revert my language preference
  
  Scenario: A user wants to see the page in Japanese
    Given I am on the dashboard page
    When I choose "Japanese" from the language options
    Then the page displays the interface in "Japanese"
    And reloading the dashboard page does not revert my language preference