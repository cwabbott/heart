class Secondary < ActiveRecord::Base
  self.abstract_class = true

  # prior to AR 3.2.1
  url = URI.parse(Heart::Application.config.secondary_database_url)
  establish_connection(
    :adapter  => 'mysql2',
    :host     => url.host,
    :username => url.userinfo.split(':')[0],
    :password => url.userinfo.split(':')[1],
    :database => url.path[1..-1],
    :port     => url.port || 3306
  )
end

class RemoteObject < Secondary
  self.table_name = Heart::Application.config.remote_object_default_table
end