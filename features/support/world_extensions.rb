module KnowsTheDomain
  def configuration
    @configuration ||= Configuration.first
  end
end
World(KnowsTheDomain)

system('bundle exec rake db:migrate:redo VERSION=20130902014029 RAILS_ENV=test')