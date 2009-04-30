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

package org.systemsbiology.visualization.bionetwork.layout {
import flare.animate.Transitioner;
import flare.vis.data.Data;
import flare.vis.data.DataSprite;
import flare.vis.data.NodeSprite;
import flare.vis.operator.layout.Layout;

import flash.geom.Rectangle;

import org.systemsbiology.visualization.data.DataView;

public class GoogleDataTableDrivenLayout extends Layout
{
	private var layoutTable:DataView;
	private var layoutmap:Object;
	/**
	 * Creates a new RootInCenterCircleLayout.
	 * @param sortbyEdges Flag indicating if barycentric sorting using
	 *  the graph structure should be performed
	 */
	public function GoogleDataTableDrivenLayout() {
		this.layoutmap=layoutmap;
	}
	
	/** @inheritDoc */
	public override function operate(t:Transitioner=null):void
	{
		_t = (t!=null ? t : Transitioner.DEFAULT);
		
		var d:Data = visualization.data;
		var nn:uint = d.nodes.length, i:int = 0;
		
		var items:Array = new Array();
 		for (i=0; i<nn; ++i) items.push(d.nodes[i]);
		// perform the layout
	
		for (i=0; i<items.length; i++) {
			var n:NodeSprite = items[i];
			trace("name" + n.data.name);
			trace("x"+n.props.x);
			trace("y"+n.props.y);
			_t.$(n).x = n.props.x;
			_t.$(n).y = n.props.y;
    	}
		
		updateEdgePoints(_t);
		_t = null;
		trace("finished");
	}

} // end of class 
}
	