module Heart
  class Dashboard < Heart::Application
    INACTIVE = 2
    scope :active, lambda { where(:status => nil).where('dashboard != ""') }
  end
end
