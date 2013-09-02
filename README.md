## Setting up locally, running cucumber scenarios
bundle install
create config/database.yml with connection info to local db
create databases in mysql (e.g., ```create database 'my_heart_database'```)
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake db:test:prepare
bundle exec cucumber


## Setting up on Heroku
bundle install
git init
git add .
git commit -m "init"
heroku create
heroku addons:add cleardb:ignite
heroku config | grep CLEARDB_DATABASE_URL
heroku config:set DATABASE_URL=''
heroku config:add SECONDARY_DB_URL=''
git push heroku master
heroku run rake db:migrate
heroku run rake db:seed
heroku open
