class Population < ActiveRecord::Base

  def self.count_grouped_by_date(demographic_id)
    select("COUNT(DATE(created_at)) as the_count, DATE(created_at) as the_date_only").
      where(:demographic_id => demographic_id).
      group("the_date_only").
      order("the_date_only DESC")
  end

  def self.insert_extended(values_array)
    sql = "INSERT INTO populations (`demographic_id`, `user_id`, `segment_id`, `created_at`, `updated_at`) VALUES #{values_array.join(", ")}"
    Population.connection.execute sql
  end
end