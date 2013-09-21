namespace :heart do
  namespace :metrics do
    
    desc "Fetches all metrics for a particular date"
    task :fetch_all => :environment do
      unless ENV.include?("todate")
        raise "usage: rake heart:metrics:fetch_all fromdate=2011-01-01 todate=2011-01-30"
      end
      todate = Date.parse(ENV['todate'])
      fromdate = Date.parse(ENV['fromdate'])
      fromdate.upto(todate) do |date|
        metric = Heart::Metric.find_or_create(date,0)
        metric.fetch_all
      end
    end

    desc "Fetch a specific metric for all days between dates"
    task :fetch_between => :environment do
      unless ENV.include?("todate") && ENV.include?("fromdate") && ENV.include?("metric")
        raise "usage: rake heart:metrics:fetch_between todate=2011-01-01 fromdate=2010-12-01 metric=metricName"
      end
      todate = Date.parse(ENV['todate'])
      fromdate = Date.parse(ENV['fromdate'])
      metric_name = ENV['metric']
      method = "fetch_" + metric_name.to_s

      fromdate.upto(todate) do |date|
        #first for the global metrics / all users
        metric = Heart::Metric.find_or_create(date,0)
        isometric = Heart::Isometric.find_or_create(date,0)

        metric.send(method)

        metric.save
        isometric.send(metric_name+"=", Time.now) unless method == "fetch_all"
        isometric.save unless method == "fetch_all"
      end
    end

    desc "Fetch metrics that were not previously fetched between specific dates."
    task :fetch_missing => :environment do
      unless ENV.include?("todate") && ENV.include?("fromdate")
        raise "usage: rake heart:metrics:fetch_missing todate=2011-01-01 fromdate=2010-12-01"
      end
      todate = Date.parse(ENV['todate'])
      fromdate = Date.parse(ENV['fromdate'])
      fromdate.upto(todate) do |date|
        missing_metrics = []
        isometric = Heart::Isometric.where("fulldate = ? and movingaverage = 0", date).first
        isometric.attributes.each { |key,value| missing_metrics.push(key) if value.nil? }

        metric = Heart::Metric.where("fulldate = ? and movingaverage = 0", date).first
        missing_metrics.each do |missing|
          fetch_method = "fetch_#{missing}"
          if metric.respond_to?(fetch_method)
            puts "#{fetch_method} for #{date}"
            begin
              metric.send(fetch_method)
              metric.save
              isometric.send("#{missing}=", Time.now)
              isometric.save
            rescue e
              puts "#{fetch_method} exception on #{date}"
              puts e.message
            end
          end
        end
      end
    end
    
    desc "Cache a moving average for a range of dates"
    task :moving_average => :environment do
      unless ENV.include?("todate") && ENV.include?("fromdate") && ENV.include?("average")
        raise "usage: rake heart:metrics:moving_average todate=2011-01-01 fromdate=2010-12-01 average=30"
      end
      todate = Date.parse(ENV['todate'])
      fromdate = Date.parse(ENV['fromdate'])
      movingaverage = (ENV['average'].nil?) ? 30 : ENV['average'].to_i
      fromdate.upto(todate) do |date|
        metric = Heart::Metric.find_or_create(date,movingaverage)
        metric.save!
        metric.moving_averages!(movingaverage)
        metric.save
      end
    end
    
  end #end metrics namespace
end #end heart namespace
