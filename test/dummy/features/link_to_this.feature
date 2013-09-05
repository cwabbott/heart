@javascript
Feature: Directly linking to a metric graph
  Scenario: Users can access graphs directly by URL
    Given there is example metric data
    When I access the metric dashboard with a special URL
    Then the legend should show the example metric data