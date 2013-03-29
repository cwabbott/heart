def dashboard_title
  "Dboard Example"
end

Given /^there is an example dashboard$/ do
  FactoryGirl.create(:dashboard, :title => dashboard_title)
  Dashboard.count.should equal(2) #default + example
end

When /^I visit the dashboard index$/ do
  visit(dashboards_path)
  page.should_not have_content('Internal Server Error')
end

Then /^I should see a link to the dashboard$/ do
  page.should have_content(dashboard_title.downcase)
end

When /^I visit the example dashboard$/ do
  visit(dashboards_path)
  page.should_not have_content('Internal Server Error')
  find_link(dashboard_title).click
end

Then /^I should see the dashboard sidebar$/ do
  page.should have_content("Posts Only")
end

When /^choose the create dashboard option$/ do
  find_link("new_dashboard_link").click
end

When /^choose the edit dashboard option$/ do
  find_link("edit_dashboard_link").click
end

def add_a_graph
  check_metrics
  click_button('Graph')
  fill_in(:chart_title1, :with => "A Demo Chart")
  find(:css, '#dash_graph1').click
end

Then /^I can create a custom dashboard$/ do
  fill_in(:dashboard_title, :with => "Does it Work?")
  add_a_graph
  find(:css, '#check_save_dashboard').click
  page.should have_content("Does it Work?".downcase)
  page.should_not have_content("A Demo Chart")
end

When /^I am creating a custom dashboard$/ do
  visit(new_dashboard_path)
end

When /^I have a blank title$/ do
  fill_in(:dashboard_title, :with => "")
  add_a_graph
end

When /^I forget to add a graph$/ do
  fill_in(:dashboard_title, :with => "Does it Work?")
end

Then /^it does not allow me to save the dashboard$/ do
  find(:css, '#check_save_dashboard').click
  page.driver.browser.switch_to.alert.accept
  page.should have_css('#check_save_dashboard')
end

Then /^I can edit the dashboard's title and graphs$/ do
  fill_in(:dashboard_title, :with => "Does it Work?")
  add_a_graph
  find(:css, '#check_save_dashboard').click
  page.should have_content("Does it Work?".downcase)
  page.should_not have_css('#check_save_dashboard')
end