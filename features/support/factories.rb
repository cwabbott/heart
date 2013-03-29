require 'factory_girl_rails'

FactoryGirl.define do
  factory :metric do
    fulldate Date.parse('2013-03-20')
    segment_id 0
    movingaverage 0
    population 0
    postsNew 10
    usersNew 5
  end
  
  factory :dashboard do
    title "Example"
    description "an example dashboard"
    dashboard "[null,[\"Posts Only\",\"measurement%5B%5D=postsNew&segment%5B%5D=0&movingaverage%5B%5D=0\"],[\"Users and Posts\",\"measurement%5B%5D=postsNew&measurement%5B%5D=usersNew&segment%5B%5D=0&movingaverage%5B%5D=0\"]]"
  end
end