module Heart
  class Isometric < Heart::Application
    attr_accessible :fulldate, :movingaverage
    
    def self.find_or_create(date,average)
      Heart::Isometric.where(fulldate: date).where(movingaverage: average).first || 
      Heart::Isometric.create(fulldate: date, movingaverage: average)
    end
  end
end
