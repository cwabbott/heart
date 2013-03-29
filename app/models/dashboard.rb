class Dashboard < ActiveRecord::Base
  scope :active, lambda { where(:status => nil).where('dashboard != ""') }
  scope :default, lambda { where(:title => "Default") }
end