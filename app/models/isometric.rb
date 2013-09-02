class Isometric < ActiveRecord::Base
  def self.find_or_create(date,average)
    Isometric.find_or_create_by_fulldate_and_movingaverage(date,average)
  end
end
