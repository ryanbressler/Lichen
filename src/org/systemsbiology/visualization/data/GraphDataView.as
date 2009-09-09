package org.systemsbiology.visualization.data
{
	//interface for basic graph data. required for all network visualizations
	public class GraphDataView extends DataView
	{
		private var interactor_name1:String;		
		private var interactor_name2:String;
		private var directed:Boolean;	
		private var directedIndex:Number;
		private var columnName:String;
		//this breaks the interface; abstract out
		private var sourcesIndex:Number;
		
		public function GraphDataView(dataJSON:Object, isGoogle:String="")
		{
			super(dataJSON, isGoogle);	
			//look for optional parameters
			for (var i:Number=3; i<this.getNumberOfColumns(); i++){
				this.columnName = this.getColumnLabel(i);	
				if (columnName=='directed'){
					this.directedIndex = i;
				}
				else if (this.columnName == 'sources'){
					this.sourcesIndex = i;
				}
			}
		}
		
		public function getInteractor1Name(rowIndex:int):String{
			interactor_name1=this.getFormattedValue(rowIndex,1) || this.getValue(rowIndex,1);
			return this.interactor_name1;
		}	
		
		public function getInteractor2Name(rowIndex:int):String{
			interactor_name2=this.getFormattedValue(rowIndex,2) || this.getValue(rowIndex,2);
			return this.interactor_name2;
		}
		
		public function getDirectionality(rowIndex:int):Boolean{
			if (directedIndex){
        		return Boolean(this.getValue(rowIndex, directedIndex));
        	}
        	else {
        		return false;
        	}
		}
		
		public function getSources(rowIndex:int):Array{
			if (sourcesIndex) {
				var sourcesString:String = this.getValue(rowIndex, sourcesIndex);
			}
			if (sourcesString!=null)
			{
				return sourcesString.split(", ");
			}
			else{
				return [];
			}
		}
		
			
	}
}


