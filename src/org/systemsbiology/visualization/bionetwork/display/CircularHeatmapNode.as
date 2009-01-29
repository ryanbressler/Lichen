package org.systemsbiology.visualization.display
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	import flash.display.Graphics;
{
	public class CircularHeatmapNode
	{
		public function CircularHeatmapNode implements IRenderer
		{
 
		public var _defaultSize:Number;
 
		
		public function RoundBlockRenderer(defaultSize : Number = 6)
		{
			this._defaultSize = defaultSize;
		}
 
		public function render(d:DataSprite):void
		{
			var size:Number = d.size * _defaultSize;
			var g : Graphics = d.graphics;
			g.clear();
			g.drawcircle(d.u-d.x, d.v-d.y,4);
 
		}
		}

	}
}