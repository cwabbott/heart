require_dependency "heart/application_controller"

module Heart
  class DashboardsController < ApplicationController

    def default
    end
    
    def index
      @dashboards = Heart::Dashboard.active.all
    end

    def show
      @dashboard = Heart::Dashboard.find(params[:id])
      @charts = ActiveSupport::JSON.decode(@dashboard.dashboard)
    end
    
    def new
    end

    def create
      dashboard = Heart::Dashboard.new()
      dashboard.title = params[:title]
      dashboard.dashboard = params[:charts_serialized]
      dashboard.save
      redirect_to dashboards_path
    end

    def edit
      @dashboard = Heart::Dashboard.find(params[:id])
    end

    def update
      dashboard = Heart::Dashboard.find(params[:id])
      dashboard.title = params[:title]
      dashboard.description = params[:description]
      dashboard.dashboard = params[:charts_serialized]
      dashboard.date_from = params[:date_from]
      dashboard.save
      redirect_to dashboards_path
    end

    def archive
      dashboard = Heart::Dashboard.where(id: params[:dashboard_id]).first
      dashboard.status = Heart::Dashboard::INACTIVE
      dashboard.save
      redirect_to dashboards_path
    end

    def flotit
      params[:date_from] ||= 30.days.ago.to_s
      params[:date_to] ||= 1.days.ago.to_s     
      @annotations = Heart::Annotation.visible(:from => params[:date_from], :to => params[:date_to])
      @description = Heart::Annotation.where(id: params[:description]).first.note if params[:description].to_i > 0
      
      # THE WHERE
      where = "WHERE fulldate >= '"+params[:date_from]+"' AND fulldate <= '"+params[:date_to]+"'"
      # THE GROUPBY
      groupby = ""
      if !params[:group_by].empty?
        counter = 0
        params[:group_by].each do |value|
          groupby += "," if counter >= 1
          groupby += " " + value
          counter += 1
        end
      end
      groupby = nil if groupby.empty?
      # THE MEASUREMENTS
      measurements = params[:measurements].empty? ? false : params[:measurements]
      
      @metrics = Hash.new
      if params[:moving_averages].kind_of?(Array)
        params[:moving_averages].each do |y|
          if(params[:method_sum] == "true")
            @metrics[y.to_s] = Heart::Metric.aggregate_daily_sums(y, where, groupby, measurements)
          else
            @metrics[y.to_s] = Heart::Metric.aggregate_daily_moving_averages(y, where, groupby, measurements)
          end
        end
      end
    end
    
  end
end
