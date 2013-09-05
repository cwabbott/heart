module Heart
  class Isometric < Heart::Application
    def self.find_or_create(date,average)
      Heart::Isometric.where(fulldate: date).where(movingaverage: average).first || 
      Heart::Isometric.where(fulldate: date, movingaverage: average)
    end
  end
end
