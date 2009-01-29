package org.systemsbiology.visualization.display {
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	import flash.display.Graphics;
	import flare.vis.data.render.IRenderer;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	public class CircularHeatmapRenderer  implements IRenderer
	{

 		private static var _instance:CircularHeatmapRenderer = new CircularHeatmapRenderer();
		public var _defaultSize:Number;
 		public static function get instance():CircularHeatmapRenderer { return _instance; }
		
		public function CircularHeatmapRenderer(defaultSize : Number = 4)
		{
			this._defaultSize = defaultSize;
		}
 
		public function render(d:DataSprite):void
		{
			var size:Number = d.size * _defaultSize;
			var g : Graphics = d.graphics;
			g.clear();
			
						var _n : Number = Math.random();
			g.beginGradientFill( 	GradientType.LINEAR,
									[ 0xffffffff* _n,0xaaaaaaaa* _n, 0x8c8c8cff* _n, 0x000000 ],
									[ .8, .8, .8, .8 ],
									[ 0,96, 128, 180 ],
									new Matrix()
								);
			var name:String = d.data.name;
//			g.drawCircle(0,0,8);
//			g.drawCircle(0,0,12);
//			g.drawCircle(0,0,15);
//			g.drawCircle(0,0,20);
			g.beginFill(0xffcc00);
			g.drawCircle(0,0,15);
			g.beginFill(0xff9900);
			g.drawCircle(0,0,10);
			g.beginFill(0xff00ff);
			g.drawCircle(0,0,5);
 
		}
	}

	
}
