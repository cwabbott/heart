module Heart
  class Engine < ::Rails::Engine
    isolate_namespace Heart
    
    # Run migrations from inside the rails engine
    # instead of copying to app with heart:install:migrations
    initializer :append_migrations do |app|
      # support migration files from metric fetch definition directories in root app lib/fetch
      config.paths['db/migrate'] << 'lib/fetch'
      # also support migration files inside engine db/migrate directories
      unless app.root.to_s.match root.to_s
        if Rails.version.match /\A3\..*\z/
          app.config.paths["db/migrate"] += config.paths["db/migrate"].expanded
        elsif Rails.version.match /\A4\..*\z/
          config.paths["db/migrate"].expanded.each do |expanded_path|
            app.config.paths["db/migrate"] << expanded_path
          end
        end
      end
    end
  end
end
