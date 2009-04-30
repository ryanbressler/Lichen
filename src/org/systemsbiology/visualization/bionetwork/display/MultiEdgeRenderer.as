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

package org.systemsbiology.visualization.bionetwork.display
{
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.display.Graphics;
	
	
	public class MultiEdgeRenderer implements IRenderer
	{
		public var lineWidth:Number = 3;
		public var offsetIncr:Number = 3;
		public var colorMap:Object = {HPRD:"0x3366CC",MINT:"0x339900",IntAct:"0xA2627A", MIPS:"0xFF6600", BioGRID:"0xFF0000"};
//		private var data_sources:Array = ["HPRD","MINT","IntAct","MIPS","BioGrid"];
		
		private static var _instance:MultiEdgeRenderer = new MultiEdgeRenderer();
		public static function get instance():MultiEdgeRenderer { return _instance; }	
		public function render(d:DataSprite):void
		{
			var delta_x1:Number = 0;
			var delta_x2:Number = 0;
			var delta_y1:Number = 0;
			var delta_y2:Number  = 0;
			var offset:Number;
			
			var e:EdgeSprite = d as EdgeSprite;
			var data_sources:Array = e.props.ixnsources;
			var x1:Number = e.x1, y1:Number = e.y1;
			var x2:Number = e.x2, y2:Number = e.y2;

			var g:Graphics = e.graphics;
			g.clear();
			var c:Number;
			//delta_x1 and delta_x2 perpendicular vector of unit length
			delta_x1 = x1-x2;
			delta_y1 = y1-y2;
			c = Math.sqrt(delta_x1*delta_x1+delta_y1*delta_y1);
			delta_x2 = (delta_y1)/c;
			delta_y2 = (delta_x1)/c;

			for (var i:Number = 0; i<data_sources.length; i++){
				g.lineStyle(lineWidth, colorMap[data_sources[i]]);
				
				offset=i/2;
				if(offset!=Math.floor(offset)){ offset=-1*Math.ceil(offset); }
				offset=offsetIncr*offset;

				g.moveTo(x1+offset*delta_x2,y1-offset*delta_y2);
				g.lineTo(x2+offset*delta_x2,y2-offset*delta_y2);	
			}
		}
		

		protected function setLineStyle(e:EdgeSprite, g:Graphics):void
		{

		}

	}
}