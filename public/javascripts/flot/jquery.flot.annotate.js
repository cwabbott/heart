/*
 * The MIT License

Copyright (c) 2010 by Juergen Marsch

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
(function ($)
{          var options = {
                   series: {        annotate:
                                                {        active: false,
                                        show: false,
                                  size: 5,
                                drawAnnotate: drawAnnotateDefault ,
                            showTooltip: showTooltipDefault
                                 }
                            }
          };
           var canvas = null, target = null, axes = null, offset = null, data = null, highlights = [];
    function drawAnnotateDefault(ctx,series,datapoint, x,y)
        {        ctx.fillStyle = series.color;
        ctx.strokeStyle = series.color;
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.arc(x,y,series.annotate.size,0,Math.PI*2,true);
        ctx.closePath();
        ctx.fill();
    }
        function showTooltipDefault(x,y,contents)
        {        $('<div id="tooltip">' + contents + '</div>').css(
                {        position: 'absolute',
                display: 'none',
                top: y + 5,
                left: x + 15,
                border: '1px solid #fdd',
                padding: '2px',
                        opacity: 0.90
        }).appendTo("body").fadeIn(200);
           }
        function init(plot)
    {         plot.hooks.processOptions.push(checkAnnotateEnabled);
              function checkAnnotateEnabled(plot, options)
            {        if(options.series.annotate.active)
            {  plot.hooks.draw.push(draw);
               plot.hooks.bindEvents.push(bindEvents);
               var ph = plot.getPlaceholder().selector;
               $(ph).bind("plothover",handleTooltip);
                 }
              }
            function draw(plot, ctx)
        {         canvas = plot.getCanvas();
                   target = $(canvas).parent();
                   axes = plot.getAxes();
                  offset = plot.getPlotOffset();
                 data = plot.getData();
            for (var i = 0; i < data.length; i++)
            {         var series = data[i];
                if (series.annotate.show)
                {   for(var j=0; j<series.data.length;j++)
                    {        drawAnnotate(ctx, series, j); }
                      }
                  }
            }
        function drawAnnotate(ctx,series,j)
        {         var x,y;
            x = offset.left + axes.xaxis.p2c(series.data[j][0]);
            y = offset.top;
            series.annotate.drawAnnotate(ctx,series,series.data[j],x,y);
             }
        function bindEvents(plot, eventHolder)
        {         var r = null;
                  var options = plot.getOptions();
                   var hl = new HighLighting(plot, eventHolder, findNearby, options.series.annotate.active,highlights)
        }
        function findNearby(plot,mouseX,mouseY)
        {         var r, series;
                        data = plot.getData();
                        axes = plot.getAxes();
            for(var i = 0;i < data.length;i++)
            {         series = data[i];
                if (series.annotate.show)
                {   for(var j = 0; j < series.data.length; j++)
                    {         var x, y;
                        y = - series.annotate.size / 2;
                        x = axes.xaxis.p2c(series.data[j][0]) - series.annotate.size / 2;
                                                if (mouseX >= x && mouseX <= (x + series.annotate.size))
                        {   if (mouseY >= y && mouseY <= (y + series.annotate.size))
                            {  r = {i:i,j:j};}
                             }
                           }
                      }
                  }
            return r;
              }
           }
        var previousPoint = null;
    function handleTooltip(event, pos, item)
    {         if(item)
        {        if(previousPoint != item.dataIndex)
            {        previousPoint = item.dataIndex;
                $("#tooltip").remove();
                var x,y,d;
                      d = new Date(item.datapoint[0]);
                x = d.toDateString();
                y = item.datapoint[1];
                item.series.annotate.showTooltip(pos.pageX, pos.pageY, x + " = " + y);
                   }
              }
        else
        {   $("#tooltip").remove();
            previousPoint = null;
        }
         }
    $.plot.plugins.push({
            init: init,
            options: options,
            name: 'annotate',
            version: '0.2'
    });
})(jQuery);