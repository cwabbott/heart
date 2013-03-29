@configuration
Feature: Configure HEART Authentication

  In order to limit access to the metric system
  
  As a system administrator
  
  I want to configure authentication for HEART by following some
  simple on-screen instructions, and without modifying project source code.
  
  Scenario Outline: Configuring basic auth
    Given An unconfigured system
    When I turn on basic auth with "<Username>" and "<Password>"
    Then I should <Outcome>
    
    Examples: Successful configuration settings
      Username and password must be non-blank
    | Username | Password | Outcome                    |
    | admin    | somepass | be prompted for basic auth |
    
    Examples: Missing configuration setting
      Blank username or password are not valid
    | Username | Password | Outcome              |
    |          | somepass | see an error message |
    | admin    |          | see an error message |
    |          |          | see an error message |