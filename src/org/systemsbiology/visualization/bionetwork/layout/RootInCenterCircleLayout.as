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

package org.systemsbiology.visualization.layout {
	import flare.animate.Transitioner;
import flare.vis.data.Data;
import flare.vis.data.DataSprite;
import flare.vis.data.EdgeSprite;
import flare.vis.data.NodeSprite;
import flare.vis.operator.layout.Layout;
import flash.geom.Rectangle;

public class RootInCenterCircleLayout extends Layout
{
	private var _barysort:Boolean = false;
	private var _weight:String = null; // TODO: update this to use a Property instance
	private var _edges:uint = NodeSprite.ALL_LINKS;
	private var _padding:Number = 0.05;

	
	/** Flag indicating if barycentric sorting using the graph structure
	 *  should be performed. */
	public function get sortByEdges():Boolean { return _barysort; }
	public function set sortByEdges(b:Boolean):void { _barysort = b; }
	
	/**
	 * Creates a new RootInCenterCircleLayout.
	 * @param sortbyEdges Flag indicating if barycentric sorting using
	 *  the graph structure should be performed
	 */
	public function RootInCenterCircleLayout(sortByEdges:Boolean=false) {
		this.sortByEdges = sortByEdges;
	}
	
	/** @inheritDoc */
	public override function operate(t:Transitioner=null):void
	{
		_t = (t!=null ? t : Transitioner.DEFAULT);
		
		var d:Data = visualization.data;
		var nn:uint = d.nodes.length, i:int = 0;
		
		var rootNode:DataSprite  =layoutRoot;
		
		var items:Array = new Array();
        for (i=0; i<nn; ++i) if (d.nodes[i]!=rootNode) items.push(d.nodes[i]); //MOD: excluding the rootNode
        
        nn = items.length;
        
        // sort by barycenter
        if (_barysort && d.edges.length > 0) {
	         barysort(items);
		}
		
		// perform the layout
		var r:Rectangle = layoutBounds;
		var cx:Number = (r.x + r.width) / 2;
		var cy:Number = (r.y + r.height) / 2;
		var rx:Number = (0.5 - _padding) * r.width;
		var ry:Number = (0.5 - _padding) * r.height;

		for (i=0; i<items.length; i++) {
			var n:NodeSprite = items[i];
			var angle:Number = i*2*Math.PI / nn;
			_t.$(n).x = Math.cos(angle)*rx + cx;
			_t.$(n).y = Math.sin(angle)*ry + cy;
    	}
    	
    	_t.$(rootNode).x = cx;
    	_t.$(rootNode).y = cy;
		
		updateEdgePoints(_t);
		_t = null;
	}
	
	/**
	 * Sort the items around the circle according to the
	 * barycenters of the individual nodes.
	 */
	private function barysort(items:Array):void
	{
		var niters:uint = 700, i:uint=0, k:uint;
		var inertia:Number = 0;
		var weight:Number;
		var unchanged:Boolean;
		
		// u --> index position
		// v --> barycenter
		for (i=0; i<items.length; ++i) {
			items[i].u = items[i].v = i;
		}
		
		for (i=0; i<niters; ++i) {
			inertia = (i / (niters-1));
			
        	// sort by barycenters, update each position index
        	items.sortOn("v", Array.NUMERIC);
            for (unchanged=(i>0), k=0; k<items.length; ++k) {
            	if (unchanged && items[k].u != k)
            		unchanged = false;
            	items[k].u = k;
            }
            if (unchanged) break; // if no difference, we're done
            
            // for each node, compute the new barycenter
            for (k=0; k<items.length; ++k) {
            	var n:NodeSprite = items[k];
                weight = inertia;
                n.v = weight * n.u;
                
                n.visitEdges(function(e:EdgeSprite):void
                {
                	// retrieve the edge weight
                	var w:Number = _weight==null ? 1.0 : e.props[_weight];
                	if (isNaN(w)) w = 1.0;
                	w = Math.exp(w); // transform the weight
                	
                	// add weighted distance to barycenter
                	n.v += w * e.other(n).u;
                	weight += w;
                });
                
                // normalize to get final barycenter value
                n.v /= weight;
            }
        }
		items.sortOn("v", Array.NUMERIC);
	}
	
} // end of class RootInCenterCircleLayout
}
	