class Segment < ActiveRecord::Base
  
  belongs_to :demographic
  has_many :populations
  
  ACTIVE = 1
  INACTIVE = 0
  GROUP_A = 1
  GROUP_B = 2
  GROUP_ALL = 3
  
  scope :active, lambda { where("status > 0") }
  scope :running, lambda { |status_date| where(:status => 1).where("status_date <= '#{status_date}'") }
  scope :by_name, lambda { |name=""| where(:name => name) }
  
  validate :default_values, :on => :create
  
  def default_values
    self.division_id ||= Segment::GROUP_ALL
    self.status ||= Segment::ACTIVE
    self.status_date ||= '2000-01-01'
  end

  def display_population
    return cached_population if cached_population && updated_at > 1.day.ago
    self.cached_population = self.populations.count
    save
    cached_population
  end
end
