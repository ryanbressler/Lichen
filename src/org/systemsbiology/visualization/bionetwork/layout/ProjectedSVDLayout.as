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

package org.systemsbiology.visualization.bionetwork.layout
{
	import com.clevr.matrixalgebra.RealMatrix;
	import com.clevr.matrixalgebra.SingularValueDecomposition;
	
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	
	import org.systemsbiology.visualization.bionetwork.layout.Layout3d;

	public class ProjectedSVDLayout extends Layout3d
	{
		private var _padding:Number = .05;
		private var _3dValArray:Array;
		private var _rotateBy : int = 0;
		
		public function ProjectedSVDLayout()
		{
			super();
		}
		
		protected override function layout():void
		{
			var d:Data = visualization.data;
			var nn:uint = d.nodes.length;
			
			
			//nn X nn RealMatrix for svd
			var adjMat : RealMatrix = new RealMatrix(nn,nn,0.0); 
			var adjArrayRef : Array = adjMat.getArray();
			
			
			var items:Array = new Array();
	        for (var i:int = 0; i<nn; i++)
	        {
	        	var node : NodeSprite = d.nodes[i];
	        	//populate adjMatrix
	        	for (var j:int = 0; j<nn; j++)
	        	{
	        		//coerece to undirected
	        		if(node.isConnected(d.nodes[j])) adjArrayRef[i][j] = 1.0; 
	        	}
	        	items.push(node);
	        } 
			
			//compute svd and project down to 3 dimensions ans store if needed
			if(!this._3dValArray)
			{
				 
		        
		        var SVD : SingularValueDecomposition = new SingularValueDecomposition(adjMat);
		     	//var s : Array = SVD.getSingularValues();
		        //var UArray : Array = SVD.getU().getArray();
		        var VArray: Array = SVD.getV().getArray();
		        nn = items.length;
		        
		        this._3dValArray = this.projectDown(VArray, 5, 3);
			}
			
			//render
			this.render(_t,items,this._3dValArray,layoutBounds,.025*this._rotateBy,.5,.5);
			this._rotateBy++;
			
	    	
			updateEdgePoints(_t);
		}
		
		
		
	}
	
	
	
	
}