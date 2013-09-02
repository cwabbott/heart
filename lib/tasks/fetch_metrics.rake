namespace :metrics do
  desc "Fetch all metrics and update all active segments, refresh populations before fetching"
  task :fetch_all => :environment do
    unless ENV.include?("fulldate")
      raise "usage: rake metrics:fetch_all fulldate=2011-01-01"
    end
    fulldate = Date.parse(ENV['fulldate'])
    metric = Metric.find_or_create(fulldate,0)
    metric.fetch_all
  end

  desc "Fetch a specific metric for all days between dates; does not update segments"
  task :fetch_between => :environment do
    unless ENV.include?("fulldate") && ENV.include?("fromdate") && ENV.include?("metric")
      raise "usage: rake metrics:fetch_between fulldate=2011-01-01 fromdate=2010-12-01 metric=metricName"
    end
    fulldate = Date.parse(ENV['fulldate'])
    fromdate = Date.parse(ENV['fromdate'])
    metric_name = ENV['metric']
    method = "fetch_" + metric_name.to_s

    fromdate.upto(fulldate) do |date|
      #first for the global metrics / all users
      metric = Metric.find_or_create(date,0)
      isometric = Isometric.find_or_create(date,0)

      metric.send(method)

      metric.save
      isometric.send(metric_name+"=", Time.now) unless method == "fetch_all"
      isometric.save unless method == "fetch_all"
    end
  end

  desc "Cache a moving average for a range of dates"
  task :moving_average => :environment do
    unless ENV.include?("fulldate") && ENV.include?("fromdate") && ENV.include?("average")
      raise "usage: rake metrics:moving_average fulldate=2011-01-01 fromdate=2010-12-01 average=30"
    end
    fulldate = Date.parse(ENV['fulldate'])
    fromdate = Date.parse(ENV['fromdate'])
    movingaverage = (ENV['average'].nil?) ? 30 : ENV['average'].to_i
    fromdate.upto(fulldate) do |date|
      metric = Metric.find_or_create(date,movingaverage)
      metric.save!
      metric.moving_averages!(movingaverage)
      metric.save
    end
  end

  desc "Fetch metrics that were not previously fetched between specific dates."
  task :fetch_missing_metric_data => :environment do
    unless ENV.include?("fulldate") && ENV.include?("fromdate")
      raise "usage: rake metrics:fetch_missing_metric_data fulldate=2011-01-01 fromdate=2010-12-01"
    end
    fulldate = Date.parse(ENV['fulldate'])
    fromdate = Date.parse(ENV['fromdate'])
    fromdate.upto(fulldate) do |date|
      missing_metrics = []
      isometric = Isometric.where("fulldate = ? and movingaverage = 0", date).first
      isometric.attributes.each { |key,value| missing_metrics.push(key) if value.nil? }

      metric = Metric.where("fulldate = ? and movingaverage = 0", date).first
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
end
