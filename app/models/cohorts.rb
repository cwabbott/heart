class Cohort < ActiveRecord::Base
  scope :active, lambda { where("status > 0") }
end