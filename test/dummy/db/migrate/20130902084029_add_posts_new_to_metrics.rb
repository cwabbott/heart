class AddPostsNewToMetrics < ActiveRecord::Migration
  if Rails.env.test?
    def change
      add_column :heart_metrics, :postsNew, :integer
      add_column :heart_isometrics, :postsNew, :datetime
      add_column :heart_metrics, :usersNew, :integer
      add_column :heart_isometrics, :usersNew, :datetime
    end
  end
end