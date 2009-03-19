package org.systemsbiology.visualization.bionetwork.display
{
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.display.Graphics;
	import flash.utils.Dictionary;
	
	
	public class MultiEdgeRenderer implements IRenderer
	{
		
		private static var _instance:MultiEdgeRenderer = new MultiEdgeRenderer();
 
		public static function get instance():MultiEdgeRenderer { return _instance; }

	
		public function render(d:DataSprite):void
		{
			var e:EdgeSprite = d as EdgeSprite;
			var x1:Number = e.x1, y1:Number = e.y1;
			var x2:Number = e.x2, y2:Number = e.y2;
			trace(e.target.data.name + "and" + e.source.data.name);
			var delta_x1:Number = 0;
			var delta_x2:Number = 0;
			var delta_y1:Number = 0;
			var delta_y2:Number  = 0;
			var g:Graphics = e.graphics;
			g.clear();
			var data_sources:Array = ["HPRD", "MINT", "STRING"];
			var c:Number;
			//0xff0000, 0xffcc00, 0x00ff00, 0x0066ff
			var colorMap:Dictionary = new Dictionary();
			//yellow
			colorMap["HPRD"] = "0xffcc00"
			//green
			colorMap["MINT"] = "0x00ff00";
			colorMap["STRING"] = "0x0066ff";
			
			var lineWidth:Number = 7.000000000;
			var offset:Number = 0.2000000000000;
			var offsetIncr:Number = lineWidth; 
			//angle of edge
			for (var i:Number = 0; i<data_sources.length; i++){
			trace("i" + i);
				g.lineStyle(lineWidth, colorMap[data_sources[i]]);
				if(i>0){
					trace(x1+" , "+y1);
					trace(x2+" , "+y2);
					delta_x1 = x1-x2;
					delta_y1 = y1-y2;
					trace("delta_x " + delta_x1);
					trace("delta_y " + delta_y1);
					c = Math.sqrt(Math.abs(delta_x1)^2+Math.abs(delta_y1)^2);
					trace("c " + c);
					//abs or not?
					delta_x2 = offset * (delta_y1)/c;
					delta_y2 = offset * (delta_x1)/c;
				
//					var x1_old:Number = x1;
//					var y1_old:Number = y1;
//					var x2_old:Number = x2;
//					var y2_old:Number = y2;
				
					x1+=delta_x2;
					y1-=delta_y2;
				
					x2+=delta_x2;
					y2-=delta_y2;
				
				
//					trace("delta_x "+delta_x2);
//					trace("delta_y "+delta_y2);
//					trace(Math.sqrt((Math.abs(x2_old-x2)^2+Math.abs(y2_old-y2)^2))-offset);
					trace("-------------------");
				}
				g.moveTo(x1,y1);
				g.lineTo(x2,y2);
				
				
			}
		}
		

		protected function setLineStyle(e:EdgeSprite, g:Graphics):void
		{

		}

	}
}