/*!--------------------------------------------------------------------------*
 *  
 *  jquery.heightLine.js
 *  
 *  MIT-style license. 
 *  
 *  2013 Kazuma Nishihata 
 *  http://www.to-r.net
 *  
 *--------------------------------------------------------------------------*/
;(function($){
	$.fn.heightLine = function(){
		var target = this,fontSizeChangeTimer,windowResizeId= Math.random();
		var heightLineObj = {
			op : {
				"maxWidth" : 10000,
				"minWidth" : 0,
				"fontSizeCheck" : false
			},
			setOption : function(op){
				this.op = $.extend(this.op,op);
			},
			destroy : function(){
				target.css("height","");
			},
			create : function(op){
				var self = this,
					maxHeight = 0,
					windowWidth = $(window).width();
				self.setOption(op);
				if( windowWidth<=self.op.maxWidth && windowWidth>=self.op.minWidth ){
					target.each(function(){
						if($(this).outerHeight()>maxHeight){
							maxHeight = $(this).outerHeight();
						}
					}).each(function(){
						var height = maxHeight
								   - parseInt($(this).css("padding-top"))
								   - parseInt($(this).css("padding-bottom"));
						$(this).height(height);
					});
				}
			},
			refresh : function(op){
				this.destroy();
				this.create(op);
			},
			removeEvent :function(){
				$(window).off("resize."+windowResizeId);
				target.off("destroy refresh");
				clearInterval(fontSizeChangeTimer);
			}
		}
		if(typeof arguments[0] === "string" && arguments[0] === "destroy"){
			target.trigger("destroy");
		}else if(typeof arguments[0] === "string" && arguments[0] === "refresh"){
			target.trigger("refresh");
		}else{
			heightLineObj["create"](arguments[0]);
			
			$(window).on("resize."+windowResizeId,function(){
				heightLineObj["refresh"]();
			});

			target.on("destroy",function(){
				heightLineObj["removeEvent"]();
				heightLineObj["destroy"]();
			}).on("refresh",function(){
				heightLineObj["refresh"]();
			});

			if(heightLineObj.op.fontSizeCheck){
				
				if($("#fontSizeChange").length<=0){
					var fontSizeChange = $("<span id='fontSizeChange'></span>").css({
						width:0,
						height:"1em",
						position:"absolute",
						left:0,
						top:0
					}).appendTo("body");
				}
				var defaultFontSize = $("#fontSizeChange").height();
				fontSizeChangeTimer = setInterval(function(){
					if(defaultFontSize != $("#fontSizeChange").height()){
						heightLineObj["refresh"]();
					}
				},100);
			}
		}
		return target;
	}
})(jQuery);