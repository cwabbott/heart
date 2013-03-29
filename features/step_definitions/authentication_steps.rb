class Configuration
  def self.first
    self.new
  end
  
  def ready?
    false
  end
  
  def auth(user_and_pass)
    @username ||= user_and_pass[:username]
    @password ||= user_and_pass[:password]
  end
  
  def auth?(option=nil)
    !@username.empty? && !@password.empty?
  end
end
class User
  
end

Given /^An unconfigured system$/ do
  configuration.ready?.should be_false
end

When /^I turn on basic auth with "(.*?)" and "(.*?)"$/ do |arg1, arg2|
  configuration.auth(:username => arg1, :password => arg2)
end

Then /^I should be prompted for basic auth$/ do
  configuration.auth?.should be_true
end

Then /^I should see an error message$/ do
  configuration.auth?.should be_false
end