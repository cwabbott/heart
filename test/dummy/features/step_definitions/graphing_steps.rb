Given /^there is example metric data$/ do
  (1..3).each do |number|
    FactoryGirl.create(:metric, :fulldate => number.days.ago.to_date)
  end
end

Given /^no example metric data exists$/ do
  #no data
end

When /^I graph the example metric data$/ do
  visit(default_dashboards_path)
  fill_in('date_from', :with => 3.days.ago.strftime('%F'))
  fill_in('date_to', :with => 1.day.ago.strftime('%F'))
  check_metrics
  click_button('Graph')
end

Then /^the legend should show the example metric data$/ do
  page.should have_css('td.legendLabel', :text => 'PostsNew')
  page.should have_css('td.legendLabel', :text => 'UsersNew')
end

Then /^the graph should show the data$/ do
  #unsure how to test atm
end

Then /^the graph should be blank$/ do
  #unsure how to test atm
end

def check_metrics
  find(:css, '#namespace_title_Posts').click
  check('measurement_postsNew')
  find(:css, '#namespace_title_Users').click
  check('measurement_usersNew')
end