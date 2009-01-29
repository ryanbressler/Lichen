package org.systemsbiology.visualization.layout
{
	import com.clevr.matrixalgebra.RealMatrix;
	import com.clevr.matrixalgebra.SingularValueDecomposition;
	
	import flare.animate.Transitioner;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.layout.Layout;
	
	import flash.geom.Rectangle;

	public class SVDLayout extends Layout
	{
		private var _padding:Number = .05;
		
		public function SVDLayout()
		{
			super();
		}
		
		public override function operate(t:Transitioner=null):void
		{
			_t = (t!=null ? t : Transitioner.DEFAULT);
			
			var d:Data = visualization.data;
			var nn:uint = d.nodes.length;
			
			
			//nn X nn RealMatrix for svd
			var adjMat : RealMatrix = new RealMatrix(nn,nn,0.0); 
			var adjArrayRef : Array = adjMat.getArray();
			
			
			var items:Array = new Array();
	        for (var i:int = 0; i<nn; i++)
	        {
	        	var node : NodeSprite = d.nodes[i];
	        	for (var j:int = 0; j<nn; j++)
	        	{
	        		if(node.isConnected(d.nodes[j])) adjArrayRef[i][j] = 1.0; //TODO: handle directed
	        	}
	        	
	        	items.push(node);
	        	//populate adjMatrix
	        	
	        	
	        }  
	        
	        var SVD : SingularValueDecomposition = new SingularValueDecomposition(adjMat);
	     	//var s : Array = SVD.getSingularValues();
	        //var UArray : Array = SVD.getU().getArray();
	        var VArray : Array = SVD.getV().getArray();
	        nn = items.length;
	        
			//Index of the column (eigenvector in symetric case) we want
			var xindex : int = 0;
			var yindex : int = 1;
			
			
			var r:Rectangle = layoutBounds;
			var cx:Number = (r.x + r.width) / 2;
			var cy:Number = (r.y + r.height) / 2;
			var rx:Number = (0.5 - _padding) * r.width;
			var ry:Number = (0.5 - _padding) * r.height;
			//var scaleX : Number = SVD.getU().;
			//var scaleY : Number = 1;
			
			for (i = 0; i<items.length; i++) {
				var n:NodeSprite = items[i];
				var x : Number = VArray[i][xindex];
				var y : Number = VArray[i][yindex];
				var normalizer : Number = .25;// Math.sqrt(x*x+y*y);
				x = x/normalizer;
				y = y/normalizer;
				_t.$(n).x=cx+rx*x;
				_t.$(n).y=cy+ry*y;
	    	}
	    	

			
			updateEdgePoints(_t);
			_t = null;
		}
	}
	
	
}