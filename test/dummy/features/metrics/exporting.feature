@export @javascript
Feature: Exporting Metric Data
  Scenario: Exporting metric data as graph image
    Given there is example metric data
    When I graph the example metric data
    And I export the graph as an image
    Then I should get an image
    
  Scenario: Exporting metric data as a tab separated file
    Given there is example metric data
    When I graph the example metric data
    And I export the graph as a text file
    Then I should get tab separated text