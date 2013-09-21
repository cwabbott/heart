# HEART

HEART is a rails engine to help you quickly begin visualizing your data as time series metrics.
Write your own metric definitions using your own Rails models and business logic. Use plain ole SQL, read in text files, make API calls, do whatever you need to get your metric values - and HEART will help you visualize it.

![heart example bar][1]

Several display options are available for customizing bar and line graphs.
![heart example line][2]

Other features include:

- shareable links direct to any graph you've viewed.
- export your graph to a saveable or hot-linkable image file. 
- export your data to a tab-separated file for importing to Excel or other programs.
- Average and SUM your metric data with multiple different group by options
- visually compare year-on-year data
- track moving averages of your time series data
- easy to bundle and share metric definition code between projects

## Install
Add the gem to your gemfile:
```
gem 'heart', '~> 0.0.1'
```

[Optional] Add any other gems to your gemfile for prepackaged HEART metrics if applicable:
```
gem 'heart_vbulletin4', '~> 0.0.1'
```

Bundle, then migrate:
```
bundle install
bundle exec rake db:migrate
```
That will setup the HEART database tables, and add metrics for any prepackaged HEART metric gem that you might have installed.

Mount the engine on some path, by editing your routes.rb file and adding:
```ruby
mount Heart::Engine => "/heart", as: 'heart_engine'
```
Now, when you startup your local server and access /heart you'll be greeted by the heart main page.

### Rails 4
Need to add the following to your gem file for Rails 4 support:

```
gem 'protected_attributes'
gem 'haml', '~> 4.0'
``` 

## Creating your own custom metrics
The real simplicity of HEART comes from the ease in which you can create and isolate your own custom metrics to share between projects. Here's an example on how to add a metric to track the number of new posts in our imaginary forum which is written in Ruby on Rails (the same project we have the gem installed in):

1. Create a 'fetch' directory inside lib
2. Create a module in your lib directory to encase your metric definitions. All metric definitions can leverage the special fulldate method to allow HEART to pass in the current date it is trying to aggregate. It should look like this

  ```
    module Fetch
      module Myforum
        def fetch_myforumPostsNew
          Myforum::Post.where(posted_at: Time.parse("#{fulldate} 00:00:00")..Time.parse("#{fulldate} 23:59:59"))
        end
      end
    end
  ```
3. Create a migration to add your metric to HEART's database tables. Move the migration file into the same directory as your fetch module. E.g., this file named 2013092100000123_add_posts_new_to_heart.rb is placed in the /lib/fetch/ directory with the module created in step 2

  ```
    class AddPostsNewToHeartMetrics < ActiveRecord::Migration
      def change
        add_column :heart_metrics, :myforumPostsNew, :integer
        add_column :heart_isometrics, :myforumPostsNew, :datetime
      end
    end
  ```
4. Run your migrations. HEART will automatically include the migration files in your lib/fetch directory and its subdirectories (so you can arrange them in sub-folders however you like)
5. Aggregate your metric data into HEART's tables.
  ```
  bundle exec rake heart:metrics:fetch_all fromdate=2013-09-01 todate=2013-09-03
  ```

![developers note][0] All fetch methods must be prefixed with "fetch" followed by an underscore for HEART to find them. CamelCasing is the current standard for metric names after the "fetch". HEART takes the metric name from the database (e.g., "myforumPostsNew") and looks for a translation in your locales to pretty it up.

### TODO
1. Support non-MySQL databases
2. Remove protected_attributes requirement for support Rails 4
3. Support time series for other than just daily values (e.g., hourly)

[0]: doc/images/dev_note.png
[1]: doc/images/heart_bar.jpg
[2]: doc/images/heart_line.jpg


