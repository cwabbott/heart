//[JTGP == "Javascript the Good Parts"]
//[JTGP page25 "Global Abatement"]
var HEART = function(){
  /*
    - JSON responses are cached in the the private cache property
    - heart_this refers to the global scope
    - Whenever an element is turned into a flot canvas, the flot object is cached in graphs. That way, subsequent calls to modify the flot on that element will get the same object returned.
  */
  var cache = {indices : [], values : []}, heart_this = this, graphs = {indices : [], instances : []};
  var graph_options = {points : false, bars : false, lines : true, zoom : false, stack : null, pie : false, fill : true};
  //[JTGP page37 "Closure"]
  return {
    //
    //metric data json caching
    //
    cacheRead : function(index){
      return cache.values[cache.indices.findIndex(index)];
    },

    cacheWrite : function(index,value){
      var current_index = cache.indices.findIndex(index);
      if(current_index){
        //[JTGP page139 "Using JSON Securely"]
        cache.values[current_index] = eval("("+value+")");
      }else{
        cache.indices.push(index);
        cache.values.push(eval("("+value+")"));
      }
    },

    cacheInspect : function(){
      return cache;
    },

    //cache_index is the serialized value of all the form checkboxes (options) in the dashboard form
    cacheIndex : function(){
      return $('#heartform input').serialize().toString();
    },

    graphRead : function(dom){
      return graphs.instances[graphs.indices.findIndex(dom)];
    },

    graphWrite : function(index,value){
      var current_index = graphs.indices.findIndex(index);
      if(current_index){
        graphs.instances[current_index] = value;
      }else{
        graphs.indices.push(index);
        graphs.instances.push(value);
      }
    },

    annotate : function() {
      $.ajax({
        type : "POST",
        cache : false,
        url  : '/annotations/create',
        dataType: 'script',
        data : { 
          'fulldate': $('#annotation_fulldate').val(),
          'note': $('#annotation_note').val(),
          'date_from': $('#date_from').val(),
          'date_to': $('#date_to').val(),
          'user_id': $('#annotation_user_id').val()
          },
        success : function(res){
          $("#clickdatalabel").text('Annotated!');
          $('#clickdata').fadeOut(1200);
        },
        headers: {
              'X-Transaction': 'POST Example',
              'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
            },
      });
    },

    description : function(bool_remove){
      var remove = bool_remove || false;
      console.log(remove);
      if(!remove){
        $.ajax({
          type : "POST",
          cache : false,
          url  : '/annotations/description',
          dataType: 'script',
          data : { 'fulldate': '2999-12-31', 'note': $('#custom_description').val(), 'date_from': '2999-12-31', 'date_to': '2999-12-31' },
          success : function(res){
            if(typeof(chart_description) != 'undefined' && chart_description != ""){
              $('#description_div').html("<img src='/images/bluestar.png' align='left' width='16px' onclick='HEART.description(false)'/> &nbsp; " + chart_description);
            }
            HEART.link();
          },
          headers: {
                'X-Transaction': 'POST Example',
                'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
              },
          });
        }else{
          $('#custom_description').val("");
          $('#description_div').html("");
          $('#description').val("");
          $('#description').attr("checked", false);
        }
    },

    link : function(){
      var date_from = "", date_to = "", yearly_stacked = "", description = "";
      var flotit_date_from = $('#date_from').val();
      var flotit_date_to = $('#date_to').val();
      if($('#yearly_stacked').attr("checked")){ yearly_stacked = "&yearly_stacked=1"; }
      if(flotit_date_from != "#{@metrics.first.fulldate.to_s}"){
        date_from = "&date_from="+flotit_date_from;
      }
      if(flotit_date_to != "#{@metrics.last.fulldate.to_s}"){
        date_to = "&date_to="+flotit_date_to;
      }
      if($('#description').attr("checked")){ description = "&description=" + $("#description").val(); }
      $('#linkto').val("https://"+document.domain+"/dashboards/default?review=1&" + $('#heartform input:checkbox').serialize().toString() + date_from + date_to + description + yearly_stacked);
      $('#linkto').effect("highlight", {color: "#72B9EB"}, 2000);
    },

    image : function(){
      dashboard_id = $('#dashboard_id').val();
      result = $.ajax({
        type : "POST",
        cache : true,
        url  : '/images',
        dataType : 'text',
        data : {
                'dashboard_id': dashboard_id,
                'dataurl': $('#flot .flot-base')[0].toDataURL(),
                'purpose': 'export'
                },
        async : true,
        success : function(res){
          var image = jQuery.parseJSON(res);
          window.open('/images/' + image.id + '.png');
        },
        headers : {
          'X-Transaction': 'POST Example',
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
      });
    },
    
    tsv : function(){
      $('#tsv_export').attr("checked", true);
      HEART.flotGraph().draw();
    },

    table : function(){
      $('#heart_data_table').toggle();
      var cache_index = HEART.cacheIndex();
      var exportdata = [], exportlabels = [];
      var movingaverage = '0';
      var segment = '0';
      $.each($('input:checkbox:checked.segments'),function(){
        segment = $(this).val();
        $.each($('input:checkbox:checked.movingaverages'),function(){
          movingaverage = $(this).val();
          $.each($('input:checkbox:checked.measurements'),function(){
            var flotDataHash = $.trim("flotData" + segment + "_" + movingaverage);
            if($(this).attr("checked")){
              exportdata.push(HEART.cacheRead(cache_index)[flotDataHash][$(this).val()].data);
              exportlabels.push(HEART.cacheRead(cache_index)[flotDataHash][$(this).val()].label);
            }
          })
        })
      });
      var data_table = $('#heart_data_table');
      var headers = '';
      data_table.empty();
      $.each(exportlabels, function(){
        headers += '<th>'+this+'</th>';
      });
      data_table.append('<tr><th>Date</th>'+headers+'</tr>');
      var rows = {};
      var total_rows = exportdata.length;
      for(var i=0; i<total_rows; i++){
        var arr = exportdata.shift();
        var arr_length = arr.length;
        for(var ii=0; ii<arr_length; ii++){
          rows[arr[ii][0]] = rows[arr[ii][0]] || [];
          rows[arr[ii][0]].push(arr[ii][1]);
        }
      }
      var keys = Object.keys(rows);
      $.each(keys, function(){
        var date = new Date(parseInt(this));
        var td = '<td>'+date.getFullYear()+'-'+(date.getMonth()+1)+'-'+date.getDate()+'</td>';
        for(var i=0; i<rows[this].length; i++){
          td += '<td>'+rows[this][i]+'</td>';
        }
        data_table.append('<tr>'+td+'</tr>');
      });

    },

    get_points : function(){
      return graph_options.points;
    },
    set_points : function(){
      $('.heart_points').toggleClass('heart_off');
      graph_options.points = (graph_options.points) ? false : true;
      HEART.flotGraph().draw();
    },

    get_bars : function(){
      return graph_options.bars;
    },
    set_bars : function(){
      if(graph_options.lines){
        $('.heart_lines').toggleClass('heart_off');
        graph_options.lines = false; //mutually exclusive
      }
      if(graph_options.pie){
        $('.heart_pie').toggleClass('heart_off');
        graph_options.pie = false;
      }
      $('.heart_bars').toggleClass('heart_off');
      graph_options.bars = (graph_options.bars) ? false : true;
      HEART.flotGraph().draw();
    },

    get_lines : function(){
      return graph_options.lines;
    },
    set_lines : function(){
      if(graph_options.bars){
        $('.heart_bars').toggleClass('heart_off');
        graph_options.bars = false; //mutually exclusive
      }
      if(graph_options.pie){
        $('.heart_pie').toggleClass('heart_off');
        graph_options.pie = false;
      }
      $('.heart_lines').toggleClass('heart_off');
      graph_options.lines = (graph_options.lines) ? false : true;
      HEART.flotGraph().draw();
    },
    
    get_pie : function(){
      return graph_options.pie;
    },
    set_pie : function(){
      if(graph_options.lines){
        $('.heart_lines').toggleClass('heart_off');
        graph_options.lines = false; //mutually exclusive
      }
      if(graph_options.bars){
        $('.heart_bars').toggleClass('heart_off');
        graph_options.bars = false;
      }
      $('.heart_pie').toggleClass('heart_off');
      graph_options.pie = (graph_options.pie) ? false : true;
      HEART.flotGraph().draw();
    },
    
    get_zoom : function(){
      return graph_options.zoom;
    },
    set_zoom : function(){
      $('.heart_zoom').toggleClass('heart_off');
      graph_options.zoom = (graph_options.zoom) ? false : true;
      HEART.flotGraph().draw();
    },
    
    get_stack : function(){
      return graph_options.stack;
    },
    set_stack : function(){
      $('.heart_stack').toggleClass('heart_off');
      graph_options.stack = (graph_options.stack) ? null : true;
      if(graph_options.stack){
        $(".annotations").attr("checked", false);
      }
      HEART.flotGraph().draw();
    },

    get_fill : function(){
      return graph_options.fill;
    },
    set_fill : function(){
      $('.heart_fill').toggleClass('heart_off');
      graph_options.fill = (graph_options.fill) ? null : true;
      HEART.flotGraph().draw();
    },
    
    //
    //different type of graphs
    //
    flotGraph : function(spec){
      var spec = spec || {};
      spec.flotoptions = {
        colors: ["#FF8300", "#06799F", "#FF2800", "#9440ed","#C3F500"],
        xaxis: { mode: "time", reserveSpace: null},
        xaxes: [{ },
                { show: false, tickFormatter: function(v, xaxis){return "";},},
                { show: false, tickFormatter: function(v, xaxis){return "";},},
                { show: false, tickFormatter: function(v, xaxis){return "";},},
                { show: false, tickFormatter: function(v, xaxis){return "";},},],
        yaxis: { min: 0 },
        grid: { backgroundColor: { colors: ["#fff", "#fff"] }, hoverable: true, clickable: true },
        legend: { noColumns: 3, container: $('#flotlegend, .legend'), labelBoxBorderColor: null, show: true, labelFormatter: function(label, series) {
            // series is the series object for the label
            if(label.substring(label.length -1) == "]"){
              if(label.substring(label.length -4) == "999]"){
                return "forecast";
              }else if(label.substring(label.length -4) == "998]"){
                return ".";
              }else if(label.substring(label.length -4) == "888]"){
                return "target";
              }else if(label.substring(label.length -4) == "666]"){
                return "significance";
              }else{
                return label.substring(label.indexOf('['));
              }
            }else{
              return "<a onclick=\"$('#measurement_" + series.att_name + "').attr('checked', false); $('#ratio_" + series.att_name + "').attr('checked', false); HEART.flotGraph().draw(); return false;\">" + label + "</a>";
            }
          } },
        series: { 
          stack: HEART.get_stack(),
          pie: {
            show: HEART.get_pie(),
            radius: 1,
            label: {
              show: true,
              radius: 3/4,
              background: { 
                  opacity: 0.5,
                  color: '#000'
              }
            }
          }
        },
        zoom: { interactive: HEART.get_zoom() },
        pan: { interactive: true },
        bars : { show : HEART.get_bars(), fill : HEART.get_fill(), barWidth : 24 * 60 * 60 * 1000 },
        lines : { show : HEART.get_lines(), fill : HEART.get_fill() },
        points : { show : HEART.get_points() },
      };

      var that = this.graph(spec);

      //privileged methods added for this instance
      that.get_options = function(){
        return flotoptions;
      };

      that.hover();
      that.click();
      return that;
    },

    miniGraph : function(spec){
      var spec = spec || {};
      spec.flotoptions = {
        colors: ["#FF8300", "#06799F", "#FF2800", "#9440ed","#C3F500"],
        xaxis: { mode: "time", tickLength: 0, show: false, reserveSpace: true },
        grid: { backgroundColor: { colors: ["#fff", "#fff"] }, hoverable: false, clickable: false },
        legend: { show: false, noColumns: 0},
        lines : { show : true, fill : true },
        points : { show : true },
      };
      var that = this.graph(spec);

      return that;
    },

    //[JTGP page52 "Functional (Inheritance)"]
    //
    //following functions are all methods of the "graph" object that is returned by lineGraph, miniGraph, etc
    //
    graph : function(spec){
      var that = {};
      var spec = spec || {};
      //private properties
      var target = spec.target || "#flot";
      var metrics = "";
      var flotoptions = spec.flotoptions || {xaxis: { mode: "time", tickLength: 0 }};

      //was reflot
      var draw = function(options){
        options = options || {};
        if(typeof(options.serialized) != 'undefined'){
          var pairs, tmp = "";
          $('input:checkbox:checked').attr('checked', false);
          $('#description_div').html("");
          $('#description').val(' ');
          $('#description').attr('checked', false);
          pairs = options.serialized.split('&');
          for (var i = 0;i<pairs.length;i++){
            tmp = pairs[i];
            if(tmp.indexOf("description=") != -1){
              tmp = tmp.split('=');
              $('#description').val(tmp[1]);
              $('#description').attr('checked', true);
            }else{
              if(tmp.indexOf("%5B%5D") != -1){
                tmp = tmp.replace("%5B%5D=","_");//ex: movingaverage%5B%5D=30 is converted to movingaverage_30
              }else{
                tmp = tmp.replace("=","_");//ex: method=sum is converted to method_sum
              }
              $('#'+tmp).attr('checked', true);
            }
          }
        }
        refresh_metrics(options);
        return this;
      };

      var refresh_metrics = function(options) {
        var count = 0;
        var flots = new Array;
        var flotit_date_from = $('#date_from').val();
        var flotit_date_to = $('#date_to').val();
        HEART.link();
        var groupbydata = new Array;
        $.each($('input:checkbox:checked.groupby'),function(){
          groupbydata[count] = $(this).val();
          count++;
        });
        var movingaverages = new Array;
        count = 0;
        $.each($('input:checkbox:checked.movingaverages'),function(){
          movingaverages[count] = $(this).val();
          count++;
        });
        var segments = new Array;
        count = 0;
        $.each($('input:checkbox:checked.segments'),function(){
          segments[count] = $(this).val();
          count++;
        });
        var measurements = new Array;
        count = 0;
        $.each($('input:checkbox:checked.measurements'),function(){
          measurements[count] = $(this).val();
          count++;
        });
        var ratios = new Array;
        count = 0;
        $.each($('input:checkbox:checked.ratios'),function(){
          ratios[count] = $(this).val();
          count++;
        });

        var cache_index = HEART.cacheIndex();
        if(typeof(HEART.cacheRead(cache_index)) != 'undefined'){
          //already in cache
          $('#overlay, #loadingGif').hide();
          metrics = HEART.cacheRead(cache_index);
          flotit();
          if(options.image){
            $.ajax({
              type : "POST",
              cache : true,
              url  : '/images',
              dataType : 'text',
              data : {
                      'dashboard_id': options.dashboard_id,
                      'dataurl': $('#miniflot' + options.dashboard_id + ' .flot-base')[0].toDataURL(),
                      'purpose': 'index'
                      },
              async : true,
              headers : {
                'X-Transaction': 'POST Example',
                'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
              },
            });
          }
        }else{
          //not in the cache, once ajax call is finished try to draw the graph again
          $('#overlay, #loadingGif').show();
          $.ajax({
            type : "POST",
            cache : true,
            url  : '/dashboards/flotit',
            dataType : 'text',
            data : {
                    'date_from': flotit_date_from,
                    'date_to': flotit_date_to,
                    'group_by': groupbydata,
                    'moving_averages': movingaverages,
                    'segments': segments,
                    'measurements': measurements,
                    'ratios': ratios,
                    'method_sum': $('#method_sum').attr('checked'),
                    'dashboard_id': $('#dashboard_id').val(),
                    'description': $('#description').val()
                    },
            async : true,
            success : function(res){
              HEART.cacheWrite(cache_index,res);
              draw(options);//by the time that this ajax request has finished a different draw call may have overwritten the heartform options, call draw again to reset the form and pull from cache.. plenty about this i don't like
            },
            headers : {
              'X-Transaction': 'POST Example',
              'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
            },
          });
        }
      };

      var flotit = function(){
        function stacked(){

        }
        var growing = false;
        var cache_index = HEART.cacheIndex();
        target = get_target() || "#flot";
        options = get_options();
        var count = 0;
        var movingaverage = '0';
        var segment = '0';
        var flots = new Array;
        var exportdata = [], exportlabels = [];
        $.each($('input:checkbox:checked.segments'),function(){
          segment = $(this).val();
          $.each($('input:checkbox:checked.movingaverages'),function(){
            movingaverage = $(this).val();
            var flotDataHash = $.trim("flotData" + segment + "_" + movingaverage);
            $.each($('input:checkbox:checked.ratios'),function(){
              if($(this).attr("checked")){
                flots[count] = HEART.cacheRead(cache_index)[flotDataHash][$(this).val()];
                count++;
                if($('#tsv_export').attr("checked")){
                  exportdata.push(HEART.cacheRead(cache_index)[flotDataHash][$(this).val()].data);
                  exportlabels.push(HEART.cacheRead(cache_index)[flotDataHash][$(this).val()].label);
                }
              }
            });
            $.each($('input:checkbox:checked.measurements'),function(){
              var flotDataHash = $.trim("flotData" + segment + "_" + movingaverage);
              if($(this).attr("checked")){
                if($('#yearly_stacked').attr("checked")){
                  //time series is shown with years on top of each other
                  //need to make sure the data for each series covers the entire year.
                  var timeseries_obj_data = HEART.cacheRead(cache_index)[flotDataHash][$(this).val()].data;
                  var years = {values : []}, dateObject = new Date(), stacked_index = 1, new_timeseries_obj_data = [];
                  for(var z=0; z < timeseries_obj_data.length; z++){
                    dateObject.setTime(timeseries_obj_data[z][0]);
                    if(years.values.findIndex(dateObject.getFullYear()) === false){
                      //prime the new series with a blank array of data points
                      years.values.push(dateObject.getFullYear());
                      stacked_index = years.values.findIndex(dateObject.getFullYear());
                      new_timeseries_obj_data[stacked_index] = [];
                      //copy the data series object and pass it a reference to the blank array of data points
                      flots[count] = jQuery.extend(true, {}, HEART.cacheRead(cache_index)[flotDataHash][$(this).val()]);
                      flots[count]['xaxis'] = stacked_index + 1;
                      flots[count]['data'] = new_timeseries_obj_data[stacked_index];
                      flots[count]['label'] = flots[count]['label'] + dateObject.getFullYear();
                      flots[count]['lines'] = { fill : (0.6 / years.values.length)};
                      count++;
                      //update the reference with data
                      //make sure all dates from Jan 1, 2xxx until Dec 31, 2xxx are filled
                      if(dateObject.getDate() != 1 || dateObject.getMonth() != 0){
                        var loopDate = new Date(dateObject.getFullYear(), 0, 1, dateObject.getHours(), dateObject.getMinutes(),dateObject.getSeconds(),dateObject.getMilliseconds());
                        //console.log(loopDate.valueOf() + " " + (dateObject.valueOf() + 86400000));
                        while(loopDate.valueOf() < dateObject.valueOf() + 86400000) {
                          new_timeseries_obj_data[stacked_index].push([loopDate.valueOf(),0]);
                          loopDate.setTime(loopDate.valueOf() + 86400000);
                        }
                      }
                      new_timeseries_obj_data[stacked_index].push([timeseries_obj_data[z][0],timeseries_obj_data[z][1]]);
                    }else{
                      stacked_index = years.values.findIndex(dateObject.getFullYear());
                      new_timeseries_obj_data[stacked_index].push([timeseries_obj_data[z][0],timeseries_obj_data[z][1]]);
                    }
                  }
                  if(dateObject.getDate() != 31 || dateObject.getMonth() != 11){
                    var loopDate = new Date(dateObject.getFullYear(), 11, 31, dateObject.getHours(), dateObject.getMinutes(),dateObject.getSeconds(),dateObject.getMilliseconds());
                    console.log(loopDate.valueOf() + " " + (dateObject.valueOf() + 86400000));
                    while(loopDate.valueOf() >= dateObject.valueOf() + 86400000) {
                      dateObject.setTime(dateObject.valueOf() + 86400000);
                      new_timeseries_obj_data[stacked_index].push([dateObject.valueOf(),0]);
                    }
                  }
                  flots.reverse();
                }else{
                  flots[count] = HEART.cacheRead(cache_index)[flotDataHash][$(this).val()];
                  count++;
                }
                if($('#tsv_export').attr("checked")){
                  exportdata.push(HEART.cacheRead(cache_index)[flotDataHash][$(this).val()].data);
                  exportlabels.push(HEART.cacheRead(cache_index)[flotDataHash][$(this).val()].label);
                }
              }
            });
          });
        });
        if($('#tsv_export').attr("checked")){
          $('#tsv_export').attr("checked", false);
          window.DownloadJSON2CSV(exportdata, exportlabels);
        }
        var count_annotations = 0;
        $.each($('input:checkbox:checked.annotations'),function(){
          if($(this).attr("checked")){ flots[count] = HEART.cacheRead(cache_index)["flotDataAnnotationsHash" + $(this).val()]["note"]; count++; count_annotations++; }
        });
        if(count_annotations == 0){
          options["grid"]["markings"] = "";
        }else{
          options["grid"]["markings"] = HEART.cacheRead(cache_index)["markings"];
        }
        if(typeof(HEART.cacheRead(cache_index)["chart_description"]) != 'undefined'){
          if(HEART.cacheRead(cache_index)["chart_description"] != ""){
            $('#description_div').html("<p class='notice'><img src='/images/bluestar.png' align='right' width='16px' /><img src='/images/bluestar.png' align='left' width='16px' onclick='HEART.description(true)'/>&nbsp;" + HEART.cacheRead(cache_index)["chart_description"] + "</p>");
          }else{
            $('#description_div').html("");
          }
        }
        return $.plot($(target), flots, options);
      }

      var get_options = function(){
        return flotoptions;
      };

      var get_target = function(){
        return target;
      };

      var previousPoint = null;
      var hover = function(){
        var dom = $(target);
        $(dom).bind("plothover", function (event, pos, item) {
          if(!HEART.get_pie()){
            $("#x").text(pos.x.toFixed(2));
            $("#y").text(pos.y.toFixed(2));

            if (item) {
              if (previousPoint != item.datapoint) {
                  previousPoint = item.datapoint;

                  $("#tooltip").remove();
                  var x = item.datapoint[0],
                      y = item.datapoint[1],
                      z = item.series.data[item.dataIndex][2];
                      dateString = new Date(x);
                      if(y == 0 && z != "" || y == 1 && z != ""){
                        y = z;//annotations
                      }
                  window.showTooltip(item.pageX + 10, item.pageY, item.series.label + " = " + y + " <br />" + dateString.toDateString());
              }
            }else{
              $("#tooltip").remove();
            }
          }
        });
      }

      var click = function(){
        var dom = $(target);
        $(dom).bind("plotclick", function (event, pos, item) {
          if (item) {
            var note = "";
            dateString = new Date(item.datapoint[0]);
            $("#clickdata").show();
            $('#annotation_fulldate').val(item.datapoint[0]);
            var fdah_array = [];
            if(HEART.cacheRead(HEART.cacheIndex())["flotDataAnnotationsHash" + item.datapoint[1]]){
              fdah_array = HEART.cacheRead(HEART.cacheIndex())["flotDataAnnotationsHash" + item.datapoint[1]]["note"]["data"];
              $("#annotation_user_id").val(HEART.cacheRead(HEART.cacheIndex())["flotDataAnnotationsHash" + item.datapoint[1]]["user_id"]);
              $('#annotation_user_id').attr('disabled', true);
            }else{
              $('#annotation_user_id').attr('disabled', false);
            }
            for (var i = 0;i<fdah_array.length;i++){
              if(fdah_array[i][0] == item.datapoint[0]){
                note = fdah_array[i][2];
              }
            }

            $('#annotation_note').val(note.replace(/<br \/>/gi, '\n'));
            $("#annotation_legend").text(dateString.toDateString());
            $("#clickdatalabel").text("Annotate " + dateString.toDateString());
            $("#annotation_fetch").val(item.series.att_name);
          }
        });
      }


      //[JTGP page53 "Functional (Inheritance 'two steps')"]
      that.draw = draw;
      that.refresh_metrics = refresh_metrics;
      that.flotit = flotit;
      that.get_options = get_options;
      that.hover = hover;
      that.click = click;
      return that;
    },//end graph object

  };//end of return
}();