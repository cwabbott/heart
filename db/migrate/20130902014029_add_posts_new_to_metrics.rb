class AddPostsNewToMetrics < ActiveRecord::Migration
  if Rails.env.test?
    def change
      add_column :metrics, :postsNew, :integer
      add_column :isometrics, :postsNew, :datetime
      add_column :metrics, :usersNew, :integer
      add_column :isometrics, :usersNew, :datetime
    end
  end
end