/*
**    Copyright (C) 2003-2009 Institute for Systems Biology
**                            Seattle, Washington, USA.
**
**    This library is free software; you can redistribute it and/or
**    modify it under the terms of the GNU Lesser General Public
**    License as published by the Free Software Foundation; either
**    version 2.1 of the License, or (at your option) any later version.
**
**    This library is distributed in the hope that it will be useful,
**    but WITHOUT ANY WARRANTY; without even the implied warranty of
**    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
**    Lesser General Public License for more details.
**
**    You should have received a copy of the GNU Lesser General Public
**    License along with this library; If not, see <http://www.gnu.org/licenses/>.
*/

package org.systemsbiology.visualization.bionetwork.display{
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.systemsbiology.visualization.bioheatmap.discretecolorrange;
	
	public class CircularHeatmapRenderer  implements IRenderer
	{

// 		private static var _instance:CircularHeatmapRenderer = new CircularHeatmapRenderer();
		public var _defaultSize:Number;
//		public static function get instance():CircularHeatmapRenderer { return _instance; }
		private var _discreteColorRange:discretecolorrange;
		
		public function CircularHeatmapRenderer(discreteColorRange:discretecolorrange,defaultSize : Number = 20)
		{
			this._defaultSize = defaultSize;
			this._discreteColorRange=discreteColorRange;
		}
 
		public function render(d:DataSprite):void
		{
			var n:NodeSprite = d as NodeSprite;
			var size:Number = d.size * _defaultSize;
			var g : Graphics = d.graphics;
			g.clear();
			trace(this._discreteColorRange);
						var _n : Number = Math.random();
			g.beginGradientFill( 	GradientType.LINEAR,
									[ 0xffffffff* _n,0xaaaaaaaa* _n, 0x8c8c8cff* _n, 0x000000 ],
									[ .8, .8, .8, .8 ],
									[ 0,96, 128, 180 ],
									new Matrix()
								);					
//get values in time series
//order values
//loop through values and map to color
//draw circle and color

      		trace(d.props.timecourse_data);
			trace(n.props.timecourse_data);
			var sortedData:Array = n.props.timecourse_data.sortOn("index", Array.NUMERIC).reverse();
			var numTimepoints:Number = sortedData.length;
			var maxRadius:Number = 26;
			var radius:Number = 0;
			var stepSize:Number = Math.floor(maxRadius/numTimepoints);
			trace("step size");
			trace(stepSize);
			radius = maxRadius;
			trace("number time points");
			trace(numTimepoints);
			
			for (var i:Number = 0; i<sortedData.length; i++){
				
				trace(sortedData[i]);
				trace(sortedData[i]['index']);
				var fillColor:String =this._discreteColorRange.getCellColorHex(sortedData[i]['value'].toString());
				g.beginFill(parseInt(fillColor,16));
				g.drawCircle(0,0,radius);
				radius-=stepSize;
			}
			
			var name:String = d.data.name;
//			g.drawCircle(0,0,8);
//			g.drawCircle(0,0,12);
//			g.drawCircle(0,0,15);
//			g.drawCircle(0,0,20);
//			g.beginFill(0xffcc00);
//			g.drawCircle(0,0,15);
//			g.beginFill(0xff9900);
//			g.drawCircle(0,0,10);
//			g.beginFill(0xff00ff);
//			g.drawCircle(0,0,5);
 
		}
	}

	
}
