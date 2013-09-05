When /^I export the graph as an image$/ do
  click_link('heart_export_image')
  page.should_not have_content('RecordNotFound')
end

Then /^I should get an image$/ do
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    assert_match(/.png/, current_url)
    page.should_not have_content('RecordNotFound')
  end
end

When /^I export the graph as a text file$/ do
  check('tsv_export')
  click_button('Graph')
  page.should_not have_content('RecordNotFound')
end

Then /^I should get tab separated text$/ do
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    page.should have_content(3.days.ago.strftime("%Y/%-m/%-d"))
    page.should have_content("\t")
  end
end