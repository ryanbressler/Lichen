package org.systemsbiology.visualization.data
{
	//Sub-class for data used by GoogleVisualizationDrivenLayout
	public class LayoutDataView extends DataView
	{
		private var shapeIndex:Number;
		private var sizeIndex:Number;
		private var colorIndex:Number;
		private var columnName:String;
		
		public function LayoutDataView(dataJSON:String, isGoogle:String)
		{
			super(dataJSON, isGoogle);
			//map expected columns to column indices
			for (var i:Number = 0; i<this.getNumberOfColumns(); i++){
				 columnName = this.getColumnLabel(i);	
				 if (columnName=='shape'){
				 	shapeIndex = i;
				 }
				 else if (columnName == 'color'){
				 	colorIndex = i;
				 }
				 else if (columnName == 'size'){
				 	sizeIndex = i;
				 }
			}
		}
		
		public function getShape (rowIndex:int):String {
        	if (shapeIndex){
        		return this.getValue(rowIndex, shapeIndex);
        	}
        	else return 'CIRCLE';
    	}
    	
    	public function getSize (rowIndex:int):int {
    		if (sizeIndex){
    			return this.getValue(rowIndex, sizeIndex);
    		}
    		else { 
    			return 1;
    		}
    	}
    	
    	public function getColor (rowIndex:int):String {
    		if (colorIndex){
    			return this.getValue(rowIndex, colorIndex);
    		}
    		else {
    			return '0xff0000ff'
    		}
    	}
    	
	}
}

