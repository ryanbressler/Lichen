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
		trace("render");
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
			if (n.props.timecourse_data){
				var sortedData:Array = n.props.timecourse_data.sortOn("index", Array.NUMERIC).reverse();
			var numTimepoints:Number = sortedData.length;
			var maxRadius:Number = 30;
			var radius:Number = 0;
			var binning:String = 'even';
			var fillColor:String;
			if (binning == 'even'){
				radius = maxRadius;	
				var stepSize:Number = Math.floor(maxRadius/numTimepoints);
				for (var i:Number = 0; i<sortedData.length; i++){
//					trace(sortedData[i]);
//					trace(sortedData[i]['index']);
					fillColor = this._discreteColorRange.getCellColorHex(sortedData[i]['value'].toString());
					g.beginFill(parseInt(fillColor,16));
					g.drawCircle(0,0,radius);
					radius-=stepSize;
				}
			}
			
			else if (binning == 'proportional'){
				var prevTime:Number = 0;
				var currTime:Number = 0;		
				var totalTime:Number = 0; 
				for (var i: Number = 0; i<sortedData.length; i++){
					totalTime += int(sortedData[i]['index']);
				}
				totalTime=int(sortedData[0]['index'])-int(sortedData[sortedData.length-1]['index']);
				
				for (var i:Number = 0; i<sortedData.length; i++){
					currTime = sortedData[i]['index'];
					trace("iteration");
					trace(i);
					trace(sortedData[i]);
					fillColor = this._discreteColorRange.getCellColorHex(sortedData[i]['value'].toString());
					g.beginFill(parseInt(fillColor,16));
					stepSize = ((int(prevTime)-int(currTime)) * maxRadius)/totalTime;
					radius -= stepSize;
					g.drawCircle(0,0,radius);
					prevTime = currTime;
				}
			}
			
			var name:String = d.data.name;
 
		}
	}
	}
	
}
