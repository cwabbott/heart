Before do
  User.create(:name => "Default")
  Dashboard.create(:title => "Default")
  Configuration.create
  Metric.create(:segment_id => 0, :movingaverage => 0, :fulldate => Date.today)
end