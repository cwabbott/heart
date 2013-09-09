Given /^I am on the dashboard page$/ do
  visit(heart_engine.default_dashboards_path)
end

When /^I choose "(.*?)" from the language options$/ do |arg1|
  click_link("lang_#{lang(arg1)}")
end

Then /^the page displays the interface in "(.*?)"$/ do |arg1|
  @language = arg1
  page.should have_content(I18n.t(:no_average, :locale => "#{lang(arg1)}_heart"))
end

Then /^reloading the dashboard page does not revert my language preference$/ do
  visit(default_dashboards_path)
  page.should have_content(I18n.t(:no_average, :locale => "#{lang(@language)}_heart"))
end

def lang(option)
  case option
  when "English"
    :en
  when "Japanese"
    :ja
  end
end