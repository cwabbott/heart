$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "heart/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "heart"
  s.version     = Heart::VERSION
  s.authors     = ["Charles Abbott"]
  s.email       = ["cwabbott@gmail.com"]
  s.homepage    = "https://github.com/cwabbott/heart"
  s.summary     = "A Rails Engine to help you quickly start visualizing time-series metrics."
  s.description = "HEART helps you start tracking and graphing time-series metrics from your application's data. Simple to setup, so you can start viewing trends in your own custom metrics without coding."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '~> 3.2.14'
  s.add_dependency 'haml', ['>= 3.0.0']
  s.add_dependency 'i18n'

  s.add_development_dependency 'cucumber-rails', '~> 1.3.0'
  s.add_development_dependency 'capybara', '2.0.0.beta2'
  s.add_development_dependency 'selenium-webdriver', '~> 2.31.0'
  s.add_development_dependency 'database_cleaner', '~> 0.8.0'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'zip'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'rspec-rails', '~> 2.0'
end
