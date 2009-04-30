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