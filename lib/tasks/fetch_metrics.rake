namespace :metrics do
  desc "Fetch all metrics and update all active segments, refresh populations before fetching"
  task :fetch_all => :environment do
    unless ENV.include?("fulldate")
      raise "usage: rake metrics:fetch_all fulldate=2011-01-01"
    end
    fulldate = Date.parse(ENV['fulldate'])
    Demographic.refresh_populations(fulldate)
    metric = Metric.find_or_create(fulldate,0,0)
    metric.fetch_all
    metric.fetch_all_segments
  end

  desc "Fetch all metrics WITHOUT refreshing populations, also update metrics for each active segment"
  task :fetch_all_no_refresh => :environment do
    unless ENV.include?("fulldate")
      raise "usage: rake metrics:fetch_all_no_refresh fulldate=2011-01-01"
    end
    fulldate = Date.parse(ENV['fulldate'])
    metric = Metric.find_or_create(fulldate,0,0)
    metric.fetch_all
    metric.fetch_all_segments
  end

  desc "Update metric values for each segment without refreshing populations"
  task :fetch_all_segments => :environment do
    unless ENV.include?("fulldate")
      raise "usage: rake metrics:fetch_all_segments fulldate=2011-01-01 fromdate=2010-12-01"
    end
    fulldate = Date.parse(ENV['fulldate'])
    fromdate = (ENV['fromdate']) ? Date.parse(ENV['fromdate']) : fulldate
    fromdate.upto(fulldate) do |date|
      metric = Metric.find_or_create(date,0,0)
      metric.fetch_all_segments
    end
  end

  desc "Update metrics values for only one segment"
  task :fetch_all_segment => :environment do
    unless ENV.include?("fulldate") && ENV.include?("id")
      raise "usage: rake metrics:fetch_all_segment fulldate=2011-01-01 id=12"
    end
    fulldate = Date.parse(ENV['fulldate'])
    fromdate = (ENV['fromdate']) ? Date.parse(ENV['fromdate']) : fulldate
    id = ENV['id']
    fromdate.upto(fulldate) do |date|
      seg = Segment.find(id)
      metric = Metric.find_or_create(date,0,seg.id)
      metric.fetch_all_segments(seg.id)
    end
  end

  desc "Update a single metric for only one segment for a range of dates"
  task :fetch_metric_for_segment => :environment do
    unless ENV.include?("fulldate") && ENV.include?("id") && ENV.include?("metric")
      raise "usage: rake metrics:fetch_metric_for_segment fulldate=2011-01-01 fromdate=2010-12-01 metric=metricName id=12"
    end
    fulldate = Date.parse(ENV['fulldate'])
    fromdate = (ENV['fromdate']) ? Date.parse(ENV['fromdate']) : fulldate
    id = ENV['id']
    metric_name = ENV['metric']
    fromdate.upto(fulldate) do |date|
      seg = Segment.find(id)
      metric = Metric.find_or_create(date,0,seg.id)
      metric.update_segments(metric_name, seg.id)
    end
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
      metric = Metric.find_or_create(date,0,0)
      isometric = Isometric.find_or_create(date,0,0)

      metric.send(method)

      metric.save
      isometric.send(metric_name+"=", Time.now) unless method == "fetch_all"
      isometric.save unless method == "fetch_all"
    end
  end

  desc "Update metric values for a specific metric for all days between dates for all segments (does not fetch)"
  task :fetch_between_segments => :environment do
    unless ENV.include?("fulldate") && ENV.include?("fromdate") && ENV.include?("metric")
      raise "usage: rake metrics:fetch_between_segments fulldate=2011-01-01 fromdate=2010-12-01 metric=metricName"
    end
    fulldate = Date.parse(ENV['fulldate'])
    fromdate = Date.parse(ENV['fromdate'])
    metric_name = ENV['metric']
    method = "fetch_" + metric_name.to_s

    fromdate.upto(fulldate) do |date|
      #first for the global metrics / all users
      metric = Metric.find_or_create(date,0,0)
      isometric = Isometric.find_or_create(date,0,0)
      metric.update_segments(metric_name)
    end
  end

  desc "Update a single metric for only one segment for a range of dates, update populations"
  task :fetch_metric_for_segment_refresh_population => :environment do
    unless ENV.include?("fulldate") && ENV.include?("segment_id") && ENV.include?("metric") && ENV.include?("demographic_id")
      raise "usage: rake metrics:fetch_metric_for_segment_refresh_population fulldate=2011-01-01 fromdate=2010-12-01 metric=metricName segment_id=12 demographic_id=33"
    end
    fulldate = Date.parse(ENV['fulldate'])
    fromdate = (ENV['fromdate']) ? Date.parse(ENV['fromdate']) : fulldate
    segment_id = ENV['segment_id']
    demographic_id = ENV['demographic_id']
    metric_name = ENV['metric']
    fromdate.upto(fulldate) do |date|
      Demographic.refresh_populations(date, demographic_id)
      seg = Segment.find(segment_id)
      metric = Metric.find_or_create(date,0,seg.id)
      metric.update_segments(metric_name, seg.id)
    end
  end

  desc "Update all segmentable metrics for only one segment for a range of dates, update population for each day"
  task :fetch_all_metrics_for_segment_refresh_population => :environment do
    unless ENV.include?("fulldate") && ENV.include?("segment_id") && ENV.include?("demographic_id")
      raise "usage: rake metrics:fetch_all_metrics_for_segment_refresh_population fulldate=2011-01-01 fromdate=2010-12-01 segment_id=12 demographic_id=33"
    end
    fulldate = Date.parse(ENV['fulldate'])
    fromdate = (ENV['fromdate']) ? Date.parse(ENV['fromdate']) : fulldate
    segment_id = ENV['segment_id']
    demographic_id = ENV['demographic_id']
    fromdate.upto(fulldate) do |date|
      Demographic.refresh_populations(date, demographic_id)
      seg = Segment.find(segment_id)
      metric = Metric.find_or_create(date,0,seg.id)
      metric.fetch_all_segments(seg.id)
    end
  end

  desc "Refresh populations for all demographics"
  task :refresh_populations => :environment do
    unless ENV.include?("fulldate")
      raise "usage: rake metrics:refresh_populations fulldate=2011-01-01 id=14"
    end
    fulldate = Date.parse(ENV['fulldate'])
    id = (ENV.include?("id")) ? ENV['id'] : nil
    Demographic.refresh_populations(fulldate, id)
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
      Segment.active.all.each do |seg|
        begin
          metric = Metric.find_or_create(date,movingaverage,seg.id)
          metric.save!
          metric.moving_averages!(movingaverage)
          metric.save
        rescue e
          puts e.message
          puts e.backtrace.inspect
        end
      end
    end
  end

  desc "Fetch metrics that were not previously fetched between specific dates. Does not update segments."
  task :fetch_missing_metric_data => :environment do
    unless ENV.include?("fulldate") && ENV.include?("fromdate")
      raise "usage: rake metrics:fetch_missing_metric_data fulldate=2011-01-01 fromdate=2010-12-01"
    end
    fulldate = Date.parse(ENV['fulldate'])
    fromdate = Date.parse(ENV['fromdate'])
    fromdate.upto(fulldate) do |date|
      missing_metrics = []
      isometric = Isometric.where("fulldate = ? and segment_id = 0 and movingaverage = 0", date).first
      isometric.attributes.each { |key,value| missing_metrics.push(key) if value.nil? }

      metric = Metric.where("fulldate = ? and segment_id = 0 and movingaverage = 0", date).first
      missing_metrics.each do |missing|
        fetch_method = "fetch_#{missing}"
        if metric.respond_to?(fetch_method)
          puts "#{fetch_method} for #{date}"
          begin
            metric.send(fetch_method)
            metric.save
            isometric.send("#{missing}=", Time.now)
            isometric.save
          rescue Exception => e
            puts "#{fetch_method} exception on #{date}"
            puts e.message
          end
        end
      end
    end
  end
end
