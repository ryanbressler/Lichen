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
	
	import flash.events.MouseEvent;

	public class ProjectedSVDLayout extends Layout3d
	{
		private var _padding:Number = .05;
		private var _3dValArray:Array;
		private var _2dValArray:Array;
		private var rotate : Boolean = true;
		
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
			var dragedNode : int=-1;
			
			var items:Array = new Array();
	        for (var i:int = 0; i<nn; i++)
	        {
	        	var node : NodeSprite = d.nodes[i];
	        	if(this._2dValArray && node.stage.hasEventListener(MouseEvent.MOUSE_MOVE) && (this._2dValArray[i][0]!= node.x || this._2dValArray[i][1]!=node.y) )
	        	{
	        		dragedNode=i;
	        		node.props.oldx=node.x;
	        		node.props.oldy=node.y;
	        	}
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
		        
		        this._3dValArray = this.projectDown(VArray, 6, 3,.1,.2);
		        
		        for(var rowi : int = 0; rowi < this._3dValArray.length; rowi++)
				{
					var row : Array = this._3dValArray[rowi];
					var norm : Number = Math.sqrt(row[0]*row[0]+row[1]*row[1]+row[2]*row[2]);
				
					row[0] = row[0]/norm; row[1] = row[1]/norm; row[2] = row[2]/norm;
				}
			}
			


			//render
			var worldWind:Array = [.6,.6];
			this._2dValArray = this.render(_t,items,this._3dValArray,layoutBounds,.6,.6,2,4,true,0,.6);
			
			if(dragedNode!=-1)
			{
				var dn : NodeSprite = items[dragedNode];
				var rawPos : Array = _3dValArray[dragedNode];
				var scale : Number = (4-rawPos[2])/2;
				var dx : Number =scale*worldWind[0] * (dn.x- dn.props.oldx)/layoutBounds.width;
				var dy : Number =scale*worldWind[1] * (dn.y- dn.props.oldy)/layoutBounds.height;
				
				if(dx!=0 || dy!=0)
				{
					var xrot : Number = Math.atan(dx/rawPos[2]);
					var yrot : Number = Math.atan(dy/rawPos[2]);
					_3dValArray  = this.performRotation(_3dValArray,xrot,yrot);
				}
				
				//rotate=false;
				
			}
			else if (rotate)
			{
				this._3dValArray = this.performRotation(this._3dValArray,.01);
			}
			
						
	    	
			updateEdgePoints(_t);
		}
		
		
		
	}
	
	
	
	
}