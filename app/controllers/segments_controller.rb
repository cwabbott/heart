class SegmentsController < ApplicationController
  
  def index
    @segments = Segment.active.all
    @demographics = Demographic.active.all
  end

  def create
    demographic = Demographic.new
    demographic.name = params[:name].to_s.parameterize
    demographic.definition = params[:definition]
    demographic.initial_population = 0
    demographic.status = 1
    demographic.save
    seg = Segment.new(:demographic_id => demographic.id, :name => 'all')
    seg.save!
    users = RemoteObject.find_by_sql(params[:definition])
    users.each do |user|
        demographic.initial_population += 1
        pop = Population.new
        pop.demographic_id = demographic.id
        pop.user_id = user[:id]
        pop.segment_id = seg.id
        pop.save
    end
    demographic.save
    redirect_to segments_path
  end
  
  def edit
    @demographic = Demographic.find(params[:id])
    @pop = Population.where(:demographic_id => @demographic.id).count
    @free = Population.where(:demographic_id => @demographic.id).where('segment_id <= 0').count
    @sample_size = @pop.to_f / (1.0 + @pop.to_f * (0.03*0.03))
  end

end
