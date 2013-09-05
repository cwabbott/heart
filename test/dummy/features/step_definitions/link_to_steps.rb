When /^I access the metric dashboard with a special URL$/ do
  visit(
    heart_engine.default_dashboards_path(
      :review => "1",
      :measurement => ['postsNew', 'usersNew'],
      :segment => [0],
      :movingaverage => [0],
      :date_from => 3.days.ago.to_date,
      :date_to => 0.days.ago.to_date
    )
  )
end