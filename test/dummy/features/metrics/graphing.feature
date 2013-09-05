@metrics @javascript
Feature: Graphing Metric Data
  Scenario: Display metric data in a graph
    Given there is example metric data
    When I graph the example metric data
    Then the legend should show the example metric data
    And the graph should show the data
    
  Scenario: Display a blank graph when data is missing
    Given no example metric data exists
    When I graph the example metric data
    Then the legend should show the example metric data
    And the graph should be blank