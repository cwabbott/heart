require 'factory_girl_rails'

FactoryGirl.define do
  factory :metric, class: Heart::Metric do
    fulldate Date.parse('2013-03-20')
    movingaverage 0
    postsNew 10
    usersNew 5
  end
  
  factory :heart_dashboard, class: Heart::Dashboard do
    title "Example"
    description "an example dashboard"
    dashboard "[null,[\"Posts Only\",\"measurement%5B%5D=postsNew&movingaverage%5B%5D=0\"],[\"Users and Posts\",\"measurement%5B%5D=postsNew&measurement%5B%5D=usersNew&movingaverage%5B%5D=0\"]]"
  end
end