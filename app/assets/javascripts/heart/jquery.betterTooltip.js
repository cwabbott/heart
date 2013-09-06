/*-------------------------------------------------------------------------------
	A Better jQuery Tooltip
	Version 1.0
	By Jon Cazier
	jon@3nhanced.com
	01.22.08
-------------------------------------------------------------------------------*/

$.fn.betterTooltip = function(options){
	
	/* Setup the options for the tooltip that can be 
	   accessed from outside the plugin              */
	var defaults = {
		speed: 200,
		delay: 300
	};
	
	var options = $.extend(defaults, options);
	
	/* Create a function that builds the tooltip 
	   markup. Then, prepend the tooltip to the body */
	getTip = function() {
		var tTip = 
			"<div class='tip'>" +
				"<div class='tipMid'>"	+
				"</div>" +
				"<div class='tipBtm'></div>" +
			"</div>";
		return tTip;
	}
	$("body").prepend(getTip());
	
	/* Give each item with the class associated with 
	   the plugin the ability to call the tooltip    */
	$(this).each(function(){
		
		var $this = $(this);
		var tip = $('.tip');
		var tipInner = $('.tip .tipMid');
		
		var tTitle = (this.title);
		this.title = "";
		var offset = $(this).offset();

		
		/* Mouse over and out functions*/
		$this.hover(
			function() {
				offset = $(this).offset();
				tipInner.html(tTitle);
				setTip(offset.top, offset.left);
				setTimer();
			}, 
			function() {
				stopTimer();
				tip.hide();
			}
		);		   
		
		/* Delay the fade-in animation of the tooltip */
		setTimer = function() {
			$this.showTipTimer = setInterval("showTip()", defaults.delay);
		}
		
		stopTimer = function() {
			clearInterval($this.showTipTimer);
		}
		
		/* Position the tooltip relative to the class 
		   associated with the tooltip                */
		setTip = function(top, left){
			var topOffset = tip.height();
			var xTip = (left-50)+"px";
			var yTip = (top-topOffset-42)+"px";
			tip.css({'top' : yTip, 'left' : xTip});
		}
		
		/* This function stops the timer and creates the
		   fade-in animation                          */
		showTip = function(){
			stopTimer();
			tip.animate({"opacity": "toggle"}, defaults.speed);
		}
	});
};

function showTooltip(x, y, contents) {
    $('<div id="tooltip">' + contents + '</div>').css( {
        position: 'absolute',
        display: 'none',
        top: y + 5,
        left: x + 5,
        padding: '10px',
				'line-height': '12px',
				'text-shadow': '0px -1px 1px rgba(0, 0, 0, .8)',
				'max-width': '240px',
				color: 'white',
				'font-size':'12px',
				'background-color': '#c63929',
			  border: '2px solid #951100',
			  '-moz-border-radius': '5px',
			  '-webkit-border-radius': '5px',
			  'border-radius': '5px',
			  '-moz-box-shadow': 'inset 0px 0px 0px 1px rgba(255, 115, 100, 0.4), 0 2px 6px #333',
			  '-webkit-box-shadow': 'inset 0px 0px 0px 1px rgba(255, 115, 100, 0.4), 0 2px 6px #333',
			  'box-shadow': 'inset 0px 0px 0px 1px rgba(255, 115, 100, 0.4), 0 2px 6px #333'
    }).appendTo("body").fadeIn(0);
}