require_dependency "heart/application_controller"

module Heart
  class MetricsController < ApplicationController

    def index
      @metrics = Heart::Metric.recently_added
    end

    def show
      #restrict the range of dates to prevent a lot useless metric records
      params[:fulldate] = Date.yesterday unless params[:fulldate] <= Date.yesterday.to_s
      @metric = Heart::Metric.find_or_create(params[:fulldate],0)
      @isometric = Heart::Isometric.find_or_create(params[:fulldate],0)
    end

    def fetch
      method = "fetch_" + params[:attribute].to_s
      params[:enddate] = (params[:enddate].nil?) ? params[:fulldate] : params[:enddate]
      startdate = Date.parse(params[:fulldate].to_s)
      enddate = Date.parse(params[:enddate].to_s)
      startdate.upto(enddate) do |date|
        @metric = Heart::Metric.find_or_create(date,0)
        isometric = Heart::Isometric.find_or_create(date,0)

        @metric.send(method)

        @metric.save
        isometric.send(params[:attribute.to_s]+"=", Time.now) unless method == "fetch_all"
        isometric.save unless method == "fetch_all"
      end
    end
    
  end
end
