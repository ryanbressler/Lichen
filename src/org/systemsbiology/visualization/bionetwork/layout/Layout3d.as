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
	
	import flare.animate.Transitioner;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.layout.Layout;
	
	import flash.geom.Rectangle;
	
	public class Layout3d extends Layout
	{
		public function Layout3d() 
		{
			super();
		}

		//TODO: cache objects, upgrade to use fo 10 matrix thingies
		
		public function performRotation(VArray : Array,rotateBy:Number,rotateByAboutWidth:Number=0):Array
		{
			var dataMat : RealMatrix = new RealMatrix(VArray.length, 3,0);
			var valArray : Array = dataMat.getArray();
			for(var ii : int =0; ii<valArray.length; ii++)
			{
				for(var jj : int =0; jj< valArray[0].length; jj++)
				{
					valArray[ii][jj]=VArray[ii][jj];
				}
			}
			
			//construct rotation matrix of form
			// cos theta, -sin thete
			// sin theta, cos theta
			
			var rotationMat : RealMatrix = RealMatrix.identity(3,3);
			var rotValArray : Array = rotationMat.getArray();
			rotValArray[0][0] = Math.cos(rotateBy);
			rotValArray[0][2] = -Math.sin(rotateBy);
			rotValArray[2][2] = Math.cos(rotateBy);
			rotValArray[2][0] = Math.sin(rotateBy);
			
			if(rotateByAboutWidth!=0)
			{
				rotValArray[1][1] = Math.cos(rotateByAboutWidth);
				rotValArray[1][2] = -Math.sin(rotateByAboutWidth);
				rotValArray[2][2] = Math.cos(rotateByAboutWidth);
				rotValArray[2][1] = Math.sin(rotateByAboutWidth);
			}
			
			dataMat = rotationMat.times(dataMat.transpose()).transpose();
			return dataMat.getArrayCopy();
					
			
		} 
		
		public function projectDown(VArray : Array, fromDim : int, toDim: int, dist : Number =0.6, translate : Number = 0.7):Array
		{
			//TODO : move all this to a helper MATH file, add sizing of nodes
			//var dist : Number = .6; // distance of screen from user (in px...yuck)
			//var translate : Number = .7; //distance of user from center of visualization coords
			
			// construct data matrix of first dim eigenvectors, 1s (1s are for projection);
			var dataMat : RealMatrix = new RealMatrix(VArray.length, fromDim+1,1);
			var valArray : Array = dataMat.getArray();
			for(var ii : int =0; ii<valArray.length; ii++)
			{
				for(var jj : int =0; jj< valArray[0].length-1; jj++)
				{
					valArray[ii][jj]=VArray[ii][jj];
				}
			}
			
			//to avoid transposes during iteration
			dataMat=dataMat.transpose();

			//project down one dimension at a time
			for(var reducedby :int = 0; fromDim - reducedby >toDim; reducedby++)
			{
				var sourcedim : int = fromDim - reducedby;
				//construct the perspective projection matrix. in for 3d to 2d:
				// 1   0   0   0
				// 0   1   0   0
				// 0   0   1   0
				// 0   0  1/d  0
				// and translation matrix of form
				// 1   0   0   0
				// 0   1   0   0
				// 0   0   1   t
				// 0   0   0   1 
				var PerspectiveProjMat : RealMatrix = RealMatrix.identity(sourcedim+1,sourcedim+1);
				var TranslationMat : RealMatrix = RealMatrix.identity(sourcedim+1,sourcedim+1);
				
				var PValueArray : Array = PerspectiveProjMat.getArray();
				var TValueArray : Array = TranslationMat.getArray();
				
				PValueArray[PValueArray.length-1][PValueArray.length-1]=0;
				PValueArray[PValueArray.length-1][PValueArray.length-2]=1/dist;
				TValueArray[TValueArray.length-2][TValueArray.length-1]=translate;
							
				//apply trans
//				valArray = dataMat.getArray();
				dataMat = TranslationMat.timesMatrix(dataMat);
				//valArray = dataMat.getArray();
				
				//apply projection			
				dataMat = PerspectiveProjMat.timesMatrix(dataMat);
				valArray = dataMat.getArray();
				
				//normalize and create reduced dimension dataMat for next interation
				var newDataMat : RealMatrix = new RealMatrix(fromDim-reducedby, VArray.length,1);
				var newValArray : Array = newDataMat.getArray();
				for(ii  =0; ii < newValArray[0].length; ii++)
				{
					for(jj  =0; jj< newValArray.length-1; jj++)
					{
						newValArray[jj][ii]=valArray[jj][ii]/valArray[valArray.length-1][ii];
					}
					if(toDim==2)
					{
						//store scale factor if projecting into 2d
						newValArray[2][ii] =1/valArray[valArray.length-1][ii];
					}
				}
				dataMat = newDataMat;
			
			}
			
			//to avoid transposes during iteration
			dataMat=dataMat.transpose();
			valArray = dataMat.getArray();
			return valArray;
		}
		
		public function render(_t : Transitioner, items : Array, coordinates : Array, layoutBounds : Rectangle, worldWindowWidth : Number = 10, worldWindowHeight : Number = 10, viewerWindowDist : Number = 0.6, viewerOrigDist : Number = 0.7, zSort : Boolean = true, resizeNodes : Number = 1, alphaFade: Number = 0):Array 
		{
			var n : int = items.length;
			
			//available space
			var rx:Number = layoutBounds.width/2;
			var ry:Number = layoutBounds.height/2;
			var cx:Number = layoutBounds.x + rx
			var cy:Number = layoutBounds.y + ry
			
			//TODO: dynamical ajust world window size?
			var normalizer : Number = Math.max(worldWindowWidth,worldWindowHeight);
			 
			
			
			//render
			var valArray : Array  = this.projectDown(coordinates, 3, 2,viewerWindowDist,viewerOrigDist);
			
			var zMax : Number = valArray[0][2], zMin : Number = valArray[0][2];
			for (var i : int = 0; i<n; i++) {
				var node: * = items[i];
				var x : Number = valArray[i][0];
				var y : Number = valArray[i][1];
				//var zRad : Number = viewerOrigDist-viewerWindowDist;
				//var zNormd : Number = Math.min(Math.max((zRad+coordinates[i][2])/(2*zRad),0),1);
				x = x/normalizer;
				y = y/normalizer;
				
				
				//resize node and ajust alpha
				_t.$(node).setNodeProperties({size:(resizeNodes?valArray[i][2]*resizeNodes:1),alpha:(alphaFade?alphaFade/valArray[i][2]:1)});
				
				if(zSort){
					if(zMin>valArray[i][2])
					{
						zMin = valArray[i][2];
					}
					else if ( zMax < valArray[i][2])
					{
						zMax = valArray[i][2];
					}
				}
				valArray[i][0]=_t.$(node).x=Math.floor(cx+rx*x);
				valArray[i][1]=_t.$(node).y=Math.floor(cy+ry*y);
			}
			var zDepth : Number = zMax-zMin;
			var zBase : int = items[0].parent.numChildren-n-1;
			for (i = 0; i<n; i++) {
				//larger numbers closer 
				items[i].parent.setChildIndex(items[i],zBase+Math.floor(n*((valArray[i][2]-zMin)/zDepth)));
			}
			
			return valArray;
		}

	}
	

}