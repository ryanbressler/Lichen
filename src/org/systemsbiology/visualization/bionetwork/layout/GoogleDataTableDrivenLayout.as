package org.systemsbiology.visualization.layout {
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
	public function GoogleDataTableDrivenLayout(layoutmap:Object) {
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
			trace(n.data.name);
			if (this.layoutmap[n.data.name]){			
				_t.$(n).x = this.layoutmap[n.data.name][1];
				_t.$(n).y = this.layoutmap[n.data.name][2];	
			}
    	}

		updateEdgePoints(_t);
		_t = null;
	}

} // end of class 
}
	