class MetricsController < ApplicationController
  before_filter :login_required, :only => [:show, :index]

  def index
    @metrics = Metric.recently_added
  end

  def show
    #restrict the range of dates to prevent a lot useless metric records
    params[:fulldate] = Date.yesterday unless params[:fulldate] <= Date.yesterday.to_s
    @metric = Metric.find_or_create(params[:fulldate],0)
    @isometric = Isometric.find_or_create(params[:fulldate],0)
  end

  def create
  end

  def new
  end

  def edit
  end

  def update
  end

  def fetch
    method = "fetch_" + params[:attribute].to_s
    params[:enddate] = (params[:enddate].nil?) ? params[:fulldate] : params[:enddate]
    startdate = Date.parse(params[:fulldate].to_s)
    enddate = Date.parse(params[:enddate].to_s)
    startdate.upto(enddate) do |date|
      @metric = Metric.find_or_create(date,0)
      isometric = Isometric.find_or_create(date,0)

      @metric.send(method)

      @metric.save
      isometric.send(params[:attribute.to_s]+"=", Time.now) unless method == "fetch_all"
      isometric.save unless method == "fetch_all"
    end
  end

  def cache
    params[:enddate] = (params[:enddate].nil?) ? params[:fulldate] : params[:enddate]
    startdate = Date.parse(params[:fulldate].to_s)
    enddate = Date.parse(params[:enddate].to_s)

    movingaverage = params[:movingaverage].to_i
    startdate.upto(enddate) do |date|
      @metric = Metric.find_or_create(date,movingaverage)
      @metric.save!
      @metric.moving_averages!(movingaverage)

      @metric.save
    end
    @metric ||= Metric.first
  end

  def export
    where = "WHERE fulldate >= '"+params[:fulldate]+"' AND fulldate <= '"+params[:enddate]+"'"
    groupby = nil

    @metrics0 = Metric.aggregate_daily_moving_averages(0, where, groupby)
    export_hash = Hash.new
    export_data = Hash.new
    @metrics0.each do |metric|
      export_data[metric.fulldate.to_s] = metric.send(params[:attribute.to_s])
    end
    export_hash[params[:attribute.to_s]] = export_data
    respond_to do |format|
      format.json {render :json => export_hash}
    end
  end
end
