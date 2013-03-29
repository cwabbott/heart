@metrics @javascript
Feature: Custom dashboards
  In order to quickly access important metrics
  
  As a business decision maker
  
  I want a bookmarkable URL that preloads all custom graphs I am interested in
  and fills it with the latest metric data.
  
  Scenario: Display existing dashboards on index page
    Given there is an example dashboard
    When I visit the dashboard index
    Then I should see a link to the dashboard
    
  Scenario: View custom dashboard graphs
    Given there is an example dashboard
    When I visit the example dashboard
    Then I should see the dashboard sidebar
    
  Scenario: Create a custom dashboard
    When I visit the dashboard index
    And choose the create dashboard option
    Then I can create a custom dashboard

  Scenario: Custom dashboards require at least one graph
    When I am creating a custom dashboard
    And I forget to add a graph
    Then it does not allow me to save the dashboard
    
  Scenario: Custom dashboards require a title
    When I am creating a custom dashboard
    And I have a blank title
    Then it does not allow me to save the dashboard
  
  Scenario: Editing a dashboard's title and graphs
    Given there is an example dashboard
    When I visit the example dashboard
    And choose the edit dashboard option
    Then I can edit the dashboard's title and graphs