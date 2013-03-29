class Isometric < ActiveRecord::Base
  def self.find_or_create(date,average,segment=0)
    Isometric.find_or_create_by_fulldate_and_movingaverage_and_segment_id(date,average,segment)
  end
end
