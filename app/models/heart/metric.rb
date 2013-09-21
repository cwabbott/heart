module Heart
  class Metric < Heart::Application
    #include metric fetching modules
    Dir["#{Rails.root}/lib/fetch/**/*.rb"].each { |file|
      next if /[0-9]*_*.rb/.match(file.to_s)
  	  require file
  	  include ("Fetch::" + File.basename(file).gsub('.rb','').split("_").map{ |ea| ea.capitalize }.join).constantize
    }

    validates_presence_of :fulldate
    validate :validate_dayofweek, :validate_dayofyear, :validate_weekofyear, :validate_monthofyear, :validate_year, :on => :create
    attr_accessible :fulldate, :movingaverage

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
      ["id","fulldate","d","year","monthofyear","month","dayofyear","day","dayofweek","weekofyear","completed_at","movingaverage","created_at","updated_at","deleted_at"]
    end

    # returns an array of possible GROUP BY fields
    def self.groupbydata
      ["fulldate","dayofyear","dayofweek","weekofyear","monthofyear","year"]
    end

    def self.recently_added(average=0)
      Heart::Metric.where("movingaverage = ?", average).order("fulldate DESC").limit(3)
    end

    def self.find_or_create(date,average)
      Heart::Metric.where(fulldate: date).where(movingaverage: average).first ||
      Heart::Metric.create(fulldate: date, movingaverage: average)
    end

    def fetch_all
      isometric = Heart::Isometric.find_or_create(self.fulldate,0)
      self.methods.each do |x|
        begin
          if /^fetch_/.match(x.to_s)
            dont_fetch = ["fetch_all"]
            next if dont_fetch.include?(x.to_s)
            puts "fetching #{x}"
            self.send(x)
            attribute = x.split(/_/)
            isometric.send(attribute[1]+"=", Time.now)
            self.save
            isometric.save
          end
        rescue RuntimeError => e
          puts e.message
          puts e.backtrace.inspect
        rescue NoMethodError => e
          puts e.message
          puts e.backtrace.inspect
        end
      end
    end

    def self.aggregate_daily_moving_averages(days=30, where="WHERE fulldate > SUBDATE(NOW(), 90)", groupby=nil, measurements=true, sum_avg="AVG")
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
          measurements_with_avg.push(" #{sum_avg}(#{name}) AS #{name}")
        end
      else
        metric = Metric.new
        metric.attributes.each do |name, value|
          next if Metric.metadata.include?(name)
          next if Metric.groupbydata.include?(name)
          measurements_with_avg.push(" #{sum_avg}(#{name}) AS #{name}")
        end
      end
      m_with_a = (measurements_with_avg.empty?) ? "" : "," + measurements_with_avg.join(",")
      self.find_by_sql("
        SELECT fulldate, fulldate AS d, year, monthofyear AS month, dayofyear AS day, '#{days}' AS movingaverage #{m_with_a} 
        FROM heart_metrics 
        #{where} AND movingaverage = #{days} #{groupby} 
        ORDER BY d ASC"
        )
    end

    def self.aggregate_daily_sums(days=nil, where=nil, groupby=nil, measurements=true)
      self.aggregate_daily_moving_averages(days, where, groupby, measurements, "SUM")
    end

    # TODO remove the following methods
    #This method is used in the /metrics/:/:/cache route
    def moving_averages!(days)
      subselects = Metric.subselects_with_day(days).join(",")
      metric_with_calculated_averages = Metric.find_by_sql("SELECT fulldate, fulldate AS d, year, monthofyear AS month, dayofyear AS day, '#{days}' AS movingaverage, #{subselects} FROM heart_metrics WHERE fulldate = '#{fulldate}' AND movingaverage = 0")
      metric_with_calculated_averages.first.attributes.each do |name, value|
        next if Metric.metadata.include?(name)
        next if Metric.groupbydata.include?(name)
          self.send(name+"=",value)
      end
    end    
    #was used to create moving averages on the fly... became too slow when data sets were large and is now only used in the daily cache cron job
    def self.subselects_with_day(days=30)
      subqueries = []
      metric = Metric.new
      metric.attributes.each do |name, value|
        next if Metric.metadata.include?(name)
        next if Metric.groupbydata.include?(name)
        subqueries.push("(SELECT AVG(#{name}) AS #{name} FROM heart_metrics WHERE movingaverage = 0 AND fulldate BETWEEN SUBDATE(d,#{days}) AND d) AS #{name}")
      end
      subqueries
    end

  end #end of class
end #end of module
