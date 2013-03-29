class Demographic < ActiveRecord::Base
  has_many :segments

  scope :active, lambda { where("status > 0") }

  def display_population
    return cached_population if cached_population && updated_at > 1.day.ago
    self.cached_population = Population.where(:demographic_id => id).count
    save
    cached_population
  end

  def self.refresh_populations(fulldate,demo_id=nil)
    demographics = demo_id.present? ? [Demographic.find(demo_id)] : Demographic.active.all
    demographics.each do |demo|
      begin
        puts " starting #{fulldate} demographic_id #{demo.id}"
        if demo.refreshql.present? && demo.refreshql.strip.length > 6
          users = RemoteObject.find_by_sql(demo.refreshql.gsub('#{fulldate}',fulldate.to_s))
          a_group = demo.auto_assign ||= 0
          b_group = a_group + 1
          x = 0
          y = 0
          if demo.refreshql_replace?
            puts " dropping all users in demographic_id #{demo.id}"
            Population.delete_all("demographic_id = #{demo.id}")
            inserts = []
            users.each do |user|
              inserts.push "(#{demo.id}, #{user.id}, #{a_group}, NOW(), NOW())"
              if inserts.size >= 5000
                Population.insert_extended(inserts)
                inserts = []
              end
            end
            Population.insert_extended(inserts)
          else
            if a_group != 0
              x = Population.where(:segment_id => a_group).count
              y = Population.where(:segment_id => b_group).count
              a_b_groups = (Segment.find(a_group).division_to_s == "A") ? true : false
            end
            counter = (x > y) ? 1 : 0 #begin inserting in the A or B group, this is done to keep the populations of A and B as even as possible
            users.each do |user|
              if user.respond_to?("drop_id") && user.drop_id.to_i != 0
                Population.delete_all("demographic_id = #{demo.id} AND user_id = #{user.drop_id}") #should delete just 1 user
          	    puts " drop[#{user.drop_id}]"
  	          else
                if !Population.where(:demographic_id => demo.id).where(:user_id => user.id).exists?
                  pop = Population.new
                  pop.demographic_id = demo.id
                  pop.user_id = user.id

                  counter = 0 if counter > 1
                  counter = counter + 1
                  if a_group > 0
                    if a_b_groups
                      pop.segment_id = (counter - 1 == 0) ? a_group : b_group
                    else
                      pop.segment_id = a_group #it is neither an A nor a B group
                    end
                  end

                  pop.save
  		            puts " add[#{user.id}]"
                else
  		            puts " exists[#{user.id}]"
  	            end
              end
            end
          end
        end
        demo.cached_populations = Population.where("demographic_id = ?", demo.id).count
      rescue e
        puts e.message
        puts e.backtrace.inspect
      end
    end
  end

  def refreshql_replace?
    (refreshql_replace == 1) ? true : false
  end
end
