package org.systemsbiology.visualization.data
{
	//Sub-class for data used by GoogleVisualizationDrivenLayout
	public class LayoutDataView extends DataView
	{
		private var shapeIndex:Number;
		private var sizeIndex:Number;
		private var colorIndex:Number;
		private var columnName:String;
		private var xIndex:Number;
		private var yIndex:Number;
		
		public function LayoutDataView(dataJSON:Object, isGoogle:String="")
		{
			trace("LayoutDataView");
			trace("dataJSON");
			trace(dataJSON);
			super(dataJSON, isGoogle);
			//map expected columns to column indices
			for (var i:Number = 0; i<this.getNumberOfColumns(); i++){
				 columnName = this.getColumnLabel(i);	
				 if (columnName=='shape'){
				 	this.shapeIndex = i;
				 }
				 else if (columnName == 'color'){
				 	this.colorIndex = i;
				 }
				 else if (columnName == 'size'){
				 	this.sizeIndex = i;
				 }
				 else if (columnName == 'x'){
				 	this.xIndex=i;
				 }
				 else if (columnName == 'y'){
				 	this.yIndex=i;
				 }
			}
		}
		
		public function getX (rowIndex:int):int {
			return this.getValue(rowIndex, xIndex);
		}
		
		public function getY(rowIndex:int):int {
			return this.getValue(rowIndex, yIndex);	
		}
		
		public function getShape (rowIndex:int):String {
        	if (shapeIndex){
        		return this.getValue(rowIndex, shapeIndex);
        	}
        	else {
        		return null;
        	}
    	}
    	
    	public function getSize (rowIndex:int):Number {
    		if (sizeIndex){
    			return this.getValue(rowIndex, sizeIndex);
    		}
    		else { 
    			return -1;
    		}
    	}
    	
    	public function getColor (rowIndex:int):String {
    		if (colorIndex){
    			return this.getValue(rowIndex, colorIndex);
    		}
    		else {
    			return null
    		}
    	}
    	
	}
}

