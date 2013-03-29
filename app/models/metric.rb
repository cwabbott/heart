class Metric < ActiveRecord::Base
  
  #include metric fetching modules
  Dir["#{Rails.root}/lib/fetch/**/*.rb"].each { |file|
    next if /[0-9]*_*.rb/.match(file.to_s)
	  require file
	  include ("Fetch::" + File.basename(file).gsub('.rb','').split("_").map{ |ea| ea.capitalize }.join).constantize
  }

  validates_presence_of :fulldate
  validate :validate_dayofweek, :validate_dayofyear, :validate_weekofyear, :validate_monthofyear, :validate_year, :on => :create

  def validate_dayofweek
    self.dayofweek = self.fulldate.wday
  end

  def validate_dayofyear
    self.dayofyear = self.fulldate.yday
  end

  def dayofmonth
    self.fulldate.to_s.slice(8,10)
  end

  def validate_weekofyear
    self.weekofyear = self.fulldate.cweek
  end

  def validate_monthofyear
    self.monthofyear = self.fulldate.mon
  end

  def validate_year
    self.year = self.fulldate.year
  end

  # returns an array of properties that contain meta data
  def self.metadata
    ["id","fulldate","d","year","monthofyear","month","dayofyear","day","dayofweek","weekofyear","completed_at","movingaverage","created_at","updated_at","deleted_at","segment_id","population"]
  end

  # returns an array of possible GROUP BY fields
  def self.groupbydata
    ["fulldate","dayofyear","dayofweek","weekofyear","monthofyear","year"]
  end

  def self.recently_added(average=0,segment=0)
    Metric.where("movingaverage = ? AND segment_id = ?", average, segment).order("fulldate DESC").limit(3)
  end

  def self.days_observed(segment_id)
    Metric.select("fulldate").where(:segment_id => segment_id).where("movingaverage = 0").group("fulldate").count
  end

  def self.find_or_create(date,average,segment=0)
    Metric.find_or_create_by_fulldate_and_movingaverage_and_segment_id(date,average,segment)
  end

  def update_segments(metric=nil, segment_id=nil)
    save_to_metric = metric
    unique_user_count = (/Unique/.match(metric.to_s)) ? true : false
    #need to trim "User Unique"
    metric_to_fetch = (/UserUnique/.match(metric.to_s)) ? metric.gsub(/UserUnique/, '') : metric
    return_value = 0
    if !metric_to_fetch.nil?
      Segment.running(self.fulldate).each do |seg|
        next if segment_id && seg.id != segment_id
        segmented_metric = Metric.find_or_create(self.fulldate,self.movingaverage,seg.id)
        if unique_user_count != true
          return_value = Event.where("populations.segment_id = ? AND metric = ? AND fulldate = ?", seg.id, metric_to_fetch, self.fulldate).joins("INNER JOIN populations ON populations.user_id = events.user_id").sum("total")
          puts "fetching non-unique: saving #{return_value} to #{save_to_metric} for segment #{seg.id}"
        else
          return_value = (Event.select("DISTINCT(events.user_id) as user_id").where("populations.segment_id = ? AND metric = ? AND fulldate = ?", seg.id, metric_to_fetch, self.fulldate).joins("INNER JOIN populations ON populations.user_id = events.user_id")).length
          puts "fetching unique: saving #{return_value} to #{save_to_metric} for segment #{seg.id}"
        end
        segmented_metric.send((save_to_metric.to_s + "=").to_sym, return_value.to_i)
        segmented_metric.fetch_population
        segmented_metric.save
      end
    end
  end

  #user_ids is a hash["user_id"] = number
  #or user_ids is an Enumerable of ActiveRecord objects with either user_id or id properties
  def log_metric_events(user_ids, metric=nil)
    metric = (metric.nil?) ? (caller[0][/`.*'/][1..-2]).split("_")[1] : metric#if the metric param is nil, grabs the calling method's name and splits it on the underscore to get the metric name
    #if it's not a Hash but is an Enumerable, then we have an ActiveRecord result
    if !user_ids.is_a?(Hash) && user_ids.is_a?(Enumerable)
      puts metric.to_s + " Activerecord result passed to log_metric_events"
      ids = Hash.new
      if user_ids.first.respond_to? "user_id"
        user_ids.each do |user|
          ids[user.user_id] = (ids[user.user_id] || 0) + 1 #active record results are assumed to not have any values passed for the user. We just count how many times they appear in the result set.
        end
      elsif user_ids.first.respond_to? "id"
        user_ids.each do |user|
          ids[user.id] = (ids[user.id] || 0) + 1
        end
      end
    else
      puts metric.to_s + "Enumerable Hash passed to log_metric_events"
      ids = user_ids
    end

    if ids.is_a?(Hash)
      Event.delete_all("fulldate = '#{self.fulldate}' AND metric = '#{metric}'")
      batch = 0
      batch_total = 0
      batch_string = Array.new
      ids.each do |user, count|
        batch = batch + 1
        batch_total = batch_total + 1
        batch_string.push("('#{user}','#{count}','#{self.fulldate}','#{metric}',NOW())")
        if batch_total == ids.length
          Event.connection.execute("INSERT INTO events (user_id, total, fulldate, metric, created_at) VALUES #{batch_string.join(',')};")
          batch_string = Array.new
        elsif batch == 1000
          Event.connection.execute("INSERT INTO events (user_id, total, fulldate, metric, created_at) VALUES #{batch_string.join(',')};")
          batch_string = Array.new
          batch = 0
        end
      end
    end
    if !ids.respond_to? "values"
      ids = Hash.new
      ids[0] = 0
    end
    ids
  end

  def fetch_all_segments(segment=nil)
    begin
      Event.select("DISTINCT(metric) as metric").each do |x|
        puts "fetching #{x.metric}"
        self.update_segments(x.metric, segment)
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end

  def fetch_all
    isometric = Isometric.find_or_create(self.fulldate,0,self.segment_id)
    self.methods.each do |x|
      begin
        if /^fetch_/.match(x.to_s)
          dont_fetch = ["fetch_all","fetch_all_segments"]
          next if dont_fetch.include?(x)
          puts "fetching #{x}"
          self.send(x)
          attribute = x.split(/_/)
          isometric.send(attribute[1]+"=", Time.now)
        end
        self.save
        isometric.save
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end
  end

  def fetch_population
    self.population = Population.where(:segment_id => segment_id).count
  end

  def self.aggregate_daily_moving_averages(days=30, where="WHERE fulldate > SUBDATE(NOW(), 90)", groupby=nil, segment=0, measurements=true)
    if groupby.nil? 
      #if groupby is nil, then we want the data for each date - not aggregated. 
      #Group on fulldate to get non-aggregated results for each date (so the aggregating functions like AVG() don't run across all dates.)
      groupby = "GROUP BY fulldate"
    else
      groupby = "GROUP BY #{groupby}"
    end
    measurements_with_avg = Array.new
    case measurements
    when false
    when Array
      measurements.each do |name|
        measurements_with_avg.push(" AVG(#{name}) AS #{name}")
      end
    else
      metric = Metric.new
      metric.attributes.each do |name, value|
        next if Metric.metadata.include?(name)
        next if Metric.groupbydata.include?(name)
        measurements_with_avg.push(" AVG(#{name}) AS #{name}")
      end
    end
    m_with_a = (measurements_with_avg.empty?) ? "" : "," + measurements_with_avg.join(",")
    segmented = " AND segment_id = #{segment} " unless /^IN/.match(segment.to_s)
    self.find_by_sql("SELECT segment_id, fulldate, fulldate AS d, year, monthofyear AS month, dayofyear AS day, '#{days}' AS movingaverage #{m_with_a} FROM metrics #{where} AND movingaverage = #{days} #{segmented} #{groupby} ORDER BY d ASC")
  end

  def self.aggregate_daily_sums(days=30, where="WHERE fulldate > SUBDATE(NOW(), 90)", groupby=nil, segment=0, measurements=true)
    if groupby.nil? #if groupby is nil, then we want the data for each date - not aggregated. Group on fulldate to get non-aggregated results for each date (so the aggregating functions like AVG() don't run across all dates.)
      groupby = "GROUP BY fulldate"
    else
      groupby = "GROUP BY #{groupby}"
    end
    measurements_with_sum = Array.new
    case measurements
    when false
    when Array
      measurements.each do |name|
        measurements_with_sum.push(" SUM(#{name}) AS #{name}")
      end
    else
      metric = Metric.new
      metric.attributes.each do |name, value|
        next if Metric.metadata.include?(name)
        next if Metric.groupbydata.include?(name)
        measurements_with_sum.push(" SUM(#{name}) AS #{name}")
      end
    end
    m_with_a = (measurements_with_sum.empty?) ? "" : "," + measurements_with_sum.join(",")
    segmented = " AND segment_id = " + segment.to_s + " " unless /^IN/.match(segment.to_s)
    self.find_by_sql("SELECT segment_id, fulldate, fulldate AS d, year, monthofyear AS month, dayofyear AS day, '#{days}' AS movingaverage #{m_with_a} FROM metrics #{where} AND movingaverage = #{days} #{segmented} #{groupby} ORDER BY d ASC")
  end

  #This method is used in the /metrics/:/:/cache route
  def moving_averages!(days)
    subselects = Metric.subselects_with_day(days, segment_id).join(",")
    metric_with_calculated_averages = Metric.find_by_sql("SELECT segment_id, fulldate, fulldate AS d, year, monthofyear AS month, dayofyear AS day, '#{days}' AS movingaverage, #{subselects} FROM metrics WHERE fulldate = '#{fulldate}' AND movingaverage = 0 AND segment_id = #{segment_id}")
    metric_with_calculated_averages.first.attributes.each do |name, value|
      next if Metric.metadata.include?(name)
      next if Metric.groupbydata.include?(name)
        self.send(name+"=",value)
    end
  end

  #was used to create moving averages on the fly... became too slow when data sets were large and is now only used in the daily cache cron job
  def self.subselects_with_day(days=30, segment_id=0)
    subqueries = []
    metric = Metric.new
    metric.attributes.each do |name, value|
      next if Metric.metadata.include?(name)
      next if Metric.groupbydata.include?(name)
      subqueries.push("(SELECT AVG(#{name}) AS #{name} FROM metrics WHERE segment_id = #{segment_id} AND movingaverage = 0 AND fulldate BETWEEN SUBDATE(d,#{days}) AND d) AS #{name}")
    end
    subqueries
  end
end
