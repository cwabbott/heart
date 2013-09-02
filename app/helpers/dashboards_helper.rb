module DashboardsHelper
  def check_box_helper(name, value, options, checked=false)
    value = value.to_s
    name = name.to_s
    if params[:review].nil?
      if ["movingaverage[]","annotate[]"].include?(name) && ["0","1","note"].include?(value)
        checked = true
      end
    else
      params.each do |x,y|
        if "#{x}[]" == name && y.include?(value) || x == name
          checked = true
        end
      end
    end
    options['id'] = (options['id'].nil?) ? "#{name.gsub("[]","")}_#{value}" : options['id']
    check_box_tag name, value, checked, options
  end

  def tool_tip(options)
    "<div class='tipTitle'>#{options[:title]}</div>#{options[:content]}<br /><br /><hr /><div class='center caps'>#{options[:subtitle]}</div>#{options[:footer]}"
  end
  
  def to_flot_time(date)
    date.to_time.to_i * 1000
  end
  
  # Creates javascript objects to use as hashes for flot graph data series + labels
  def flot_array(metrics)
    replace = false
    hash = Hash.new
    if metrics.nil? || metrics.first.nil? || metrics.first.movingaverage.nil?
      replace = true
      metrics = Metric.aggregate_daily_moving_averages(0, "WHERE fulldate > SUBDATE((SELECT fulldate FROM metrics WHERE movingaverage = 0 ORDER BY fulldate desc LIMIT 1), 3)")
    end
    movingaverage = metrics.first.movingaverage

    #TODO need to move all these options into the HEART js object, set these at runtime, make them easily customizable in the UI
    extraMeasurements = ''
    label_suffix = ''
    if replace == true
      extraMeasurements = "lines : { show : false, fill : false },"
      label_suffix = ''
    else
      if movingaverage.to_i > 0
        extraMeasurements = 'points : { show : false, symbol : "circle" }, lines : { show : true, fill : false },'
        label_suffix = " [MA:#{movingaverage}] "
      end
    end#if replace = true
    #loop through for all the standard measurements
    metrics.first.attributes.sort.each do |att, value|
      next unless value.respond_to? :to_f
      next if value.is_a? Time
      extraSettings = extraMeasurements
      label = t(att) + label_suffix
      hash[att] = "#{att} : {#{extraSettings} label : '#{label}', data : ["
    end
    #
    # Now start creating the data arrays for flot. [date_converted_to_integer, value_of_metric_for_date]
    #
    metrics.each do |metric|
      metric.attributes.sort.each do |att, value|
        next unless value.respond_to? :to_f
        next if value.is_a? Time
        hash[att] = "#{hash[att]} [#{to_flot_time(metric.fulldate)}, #{value}],"
      end
    end
    #
    # Finished creating data arrays
    #
    metrics.first.attributes.sort.each do |att, value|
      next unless value.respond_to? :to_f
      next if value.is_a? Time
      hash[att] = "#{hash[att]} ], att_name : \"#{att}\",},"
    end

    flotdata = "flotData_#{movingaverage} : {"
    hash.each { |key, value| flotdata += value + "\n" }
    flotdata += "},"
    flotdata
  end
  
  def flot_annotations_array(annotation_groups)
    flotdata = ""
    markings = ""
    y_axis = 0
    colors = ["000", "0066ff"]
    annotation_groups.each do |annotations|
      flotdata += "flotDataAnnotationsHash#{y_axis} : { att_name : 'flotDataAnnotationsHash#{y_axis}', user_id : #{annotations.first.try(:user_id)||0}, note : { lines : { show : false }, points : { show : true, symbol : 'square' }, color: '##{colors[y_axis]}', label : '', data : ["
      annotations.each do |annotation|
          flotdata = flotdata.to_s + ("["+ to_flot_time(annotation.fulldate).to_s + ", #{y_axis},'" + annotation.note.to_s + "'],").to_s
          markings += "{ color: '#000', lineWidth: 1, xaxis: { from: " + to_flot_time(annotation.fulldate).to_s + ", to: " + to_flot_time(annotation.fulldate).to_s + " } },"
      end
      flotdata += "]}},\n "
      y_axis += 1
    end
    flotdata + "markings : [ #{markings}],"
  end
end