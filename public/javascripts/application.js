//[JTGP == "Javascript the Good Parts"]
$(function(){
  $('.dashboards').hover(function(){
    $('.dashboards-buttons-left, .dashboards-buttons-right').hide();
    $(this).children('.dashboards-buttons-left, .dashboards-buttons-right').show();
  }, function(){

  });
});

//onload trigger graph
$(document).ready(function(){
  if($("#flot, .flot").length){
    HEART.flotGraph().draw();
  }
});
//trigger graph when clicking button
$(function(){
  $('.heart_flotgraph_draw').click(function(){
    HEART.flotGraph().draw();
    return false;
  });
  $('.heart_export_tsv').click(function(){
    HEART.tsv();
    return false;
  });
  $('.heart_export_image').click(function(){
    HEART.image();
    return false;
  });
  $('.heart_export_table').click(function(){
    HEART.table();
    return false;
  });
  $('.heart_set_pie').click(function(){
    HEART.set_pie();
    return false;
  });
  $('.heart_set_bars').click(function(){
    HEART.set_bars();
    return false;
  });
  $('.heart_set_lines').click(function(){
    HEART.set_lines();
    return false;
  });
  $('.heart_set_stack').click(function(){
    HEART.set_stack();
    return false;
  });
  $('.heart_set_points').click(function(){
    HEART.set_points();
    return false;
  });
  $('.heart_set_fill').click(function(){
    HEART.set_fill();
    return false;
  });
  $('.heart_set_zoom').click(function(){
    HEART.set_set_zoom();
    return false;
  });
});

$(document).ready(function(){
  $('.tTip').betterTooltip();
  $('#clickdata').hide();
  $(function() {
      if($("#date_from").length){
  		  var dates = $( "#date_from, #date_to" ).datepicker({
    			defaultDate: "-1d",
    			changeMonth: true,
    			changeYear: true,
    			dateFormat: "yy-mm-dd",
    			onSelect: function( selectedDate ) {
    				var option = this.id == "date_from" ? "minDate" : "maxDate",
    					instance = $( this ).data( "datepicker" ),
    					date = $.datepicker.parseDate(
    						instance.settings.dateFormat ||
    						$.datepicker._defaults.dateFormat,
    						selectedDate, instance.settings );
    				dates.not( this ).datepicker( "option", option, date );
    				$(this).trigger("change");
    			}
    		});
  		}
  	});
});

//dashboard minigraph sidebar
$(document).ready(function(){
  if($("#trigger_button").length){
  	$("#trigger_button").click(function(){
  		$(".panel").toggle("slow");
  		$("#trigger_title").toggle("slow");
  		$("#trigger").toggleClass("active");
  		return false;
  	});
  	$("#trigger_button").trigger('click');
  }
});

var pageX = 0;
var pageY = 0;
jQuery(document).ready(function(){
   $(document).mousemove(function(e){
      pageX = e.pageX;
      pageY = e.pageY;
   });
})

//[JTGP page32 "Augmenting Types"]
if(!Array.prototype["findIndex"]){
  Array.prototype.findIndex = function(value){
    var ctrl = false;
    for (var i=0; i < this.length; i++) {
      if (this[i] == value) {
        return i;
      }
    }
    return ctrl;
  };
}

function bind_piehover(dom){
	$(dom).bind("plothover", function (event, pos, item) {
        if (item) {
          $("#tooltip").remove();
          var x = item.datapoint[0],
              y = item.datapoint[1][0][1];
          showTooltip(pageX, pageY, item.series.label + " = " + y);
        }else{
          $("#tooltip").remove();
        }
    });
}

function bind_pieclick(dom){
  $(dom).bind("plotclick", function (event, pos, item) {
        if (item.datapoint[1][0][0]) {
          document.location.href = "/segments/"+item.datapoint[1][0][0]+".csv";
        } else {
          alert('This segment cannot be exported.');
        }
    });
  }

function DownloadJSON2CSV(objArray, labelsArray)
{
    var array = typeof objArray != 'object' ? JSON.parse(objArray[0]) : objArray[0];
    var str = 'Date';
    var dateObj = new Date();
    var dateStr = "";
    for(var z = 0; z < labelsArray.length; z++){
      str += '\t ' + labelsArray[z];
    }
    str += '\r\n';
    for (var i = 0; i < array.length; i++) {
        var line = '';
        /*for (var index in array[i]) {
            if(line != '') line += ','

            line += array[i][index];
        }*/
        dateObj.setTime(array[i][0]);
        var year = dateObj.getFullYear();
        var month = dateObj.getMonth() + 1;
        var day = dateObj.getDate();
        var dateString = year + "/" + month + "/" + day;
        //dateObj.toLocaleDateString()
        line += dateString + '\t' + array[i][1];
        for(var zz = 1; zz < labelsArray.length; zz++){
          line += '\t' + objArray[zz][i][1];
        }
        str += line + '\r\n';
    }
    if (navigator.appName != 'Microsoft Internet Explorer')
    {
        window.open('data:text/plain;charset=utf-8,' + encodeURIComponent(str).replace(/'/,'%27'));
    }
    else
    {
        var popup = window.open('','csv','');
        popup.document.body.innerHTML = '<pre>' + str + '</pre>';
    }
}