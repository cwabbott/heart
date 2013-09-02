class DashboardsController < ApplicationController
  before_filter :login_required

  def index
    @date_from_value = 7.days.ago.to_date.to_s
    @dashboards = Dashboard.active.all
    @metrics = Metric.aggregate_daily_moving_averages(0, "WHERE fulldate > SUBDATE(SUBDATE(NOW(),2), 10) AND fulldate < SUBDATE(NOW(),1)")
  end

  def show
    params[:date_from] = (Date.today - 3.months).beginning_of_month
    params[:date_to] = (Date.today + 1.month).end_of_month
    @dashboard = Dashboard.find(params[:id])
    @charts = ActiveSupport::JSON.decode(@dashboard.dashboard)
    @annotations = Annotation.visible(:from => params[:date_from], :to => params[:date_to])
    @metrics = Metric.aggregate_daily_moving_averages(90)
  end

  def create
    dashboard = Dashboard.new()
    dashboard.title = params[:title]
    dashboard.dashboard = params[:charts_serialized]
    dashboard.save
    redirect_to dashboards_path
  end

  def new
    @dashboard = Dashboard.first
    @annotations = Annotation.visible(:from => Time.now - 1.month, :to => Time.now)
    @metrics = Metric.aggregate_daily_moving_averages(90)

    @categories = Hash.new("") #all indexes start as blank strings
    @categories.each {|key, value| @categories[key] = value.gsub!(/[\+]+$/, '')} #remove the last plus sign
  end

  def edit
    @dashboard = Dashboard.find(params[:id])
    @annotations = Annotation.visible(:from => Time.now - 1.month, :to => Time.now)
    @metrics = Metric.aggregate_daily_moving_averages(90)

    @categories = Hash.new("") #all indexes start as blank strings
    @categories.each {|key, value| @categories[key] = value.gsub!(/[\+]+$/, '')} #remove the last plus sign
  end

  def update
    dashboard = Dashboard.find(params[:id])
    dashboard.title = params[:title]
    dashboard.description = params[:description]
    dashboard.dashboard = params[:charts_serialized]
    dashboard.date_from = params[:date_from]
    dashboard.save
    redirect_to dashboards_path
  end

  def archive
    @dashboard = Dashboard.find(params[:dashboard_id])
    @dashboard.status = 2
    @dashboard.save!
    redirect_to dashboards_path
  end
  
  def default
    @dashboard = Dashboard.default.first
    @annotations = Annotation.visible(:from => 5.years.ago, :to => Time.now)
    @metrics = Metric.aggregate_daily_moving_averages(90)
  end

  def flotit
    date_from = Date.parse(params[:date_from])
    @dashboard = Dashboard.find(params[:dashboard_id])
    params[:date_to] = (params[:date_to].empty?) ? 1.days.ago.to_s : params[:date_to]
    @annotations = Annotation.visible(:from => params[:date_from], :to => params[:date_to])
    where = "WHERE fulldate >= '"+params[:date_from]+"' AND fulldate <= '"+params[:date_to]+"'"

    groupby = ""
    if params[:group_by] != ""
      counter = 0
      params[:group_by].each do |value|
         groupby += "," if counter >= 1
        groupby += " " + value
        counter += 1
      end
    end
    groupby = nil unless groupby != ""

    measurements = (params[:measurements].length == 0) ? false : params[:measurements]
    @metrics = Hash.new
    params[:moving_averages].each do |y|
      if(params[:method_sum] == "true")
        @metrics[y.to_s] = Metric.aggregate_daily_sums(y, where, groupby, measurements)
      else
        @metrics[y.to_s] = Metric.aggregate_daily_moving_averages(y, where, groupby, measurements)
      end
    end

    if params[:description].to_i > 0
      @description = Annotation.find(params[:description]).note
    else
      @description = ""
    end
  end
end