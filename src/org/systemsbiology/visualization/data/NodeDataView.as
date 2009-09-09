package org.systemsbiology.visualization.data
{
	//DataView for data that is attached to nodes as a list (rather than spread out as properties)
	public class NodeDataView extends DataView
	{
		private var interactor_name:String;
		//public var data:Array = new Array()
		public function NodeDataView(dataJSON:Object, isGoogle:String="")
		{
			trace("CONSTRUCTOR");
			trace(dataJSON);
			super(dataJSON, isGoogle);
		}
		public function getData(rowIndex:int):Array{
			return this.getValue(rowIndex,1);
		}
		public function getNodeId(rowIndex:int):Object{
			return this.getValue(rowIndex,0);
		}
		//returns an array of objects representing time points for a node.
		public function getTimeSeriesData(rowIndex:int):Object{
			trace("get Time Series Data");
			trace(rowIndex);
			var data:Array = new Array();
			for (var j:Number = 1; j < this.getNumberOfColumns(); j++){
				trace("j");
				trace(j);
				trace(this.getColumnLabel(j));
				var indexValue:Number = this.getColumnLabel(j).match(/t_(\d*)/)[1];
				data.push({index: indexValue, value: this.getValue(rowIndex,j)});
			}
			trace(data);
			return data;
		}
//		//	private function importTimeCourseData(nodeDataTable:DataView):void{
//		//var data = {};
//		var data:Array = new Array();
//		for (var i:Number = 0; i<nodeDataTable.getNumberOfRows();i++) {
//			//first column name
//			var interactor_name:String = nodeDataTable.getValue(i,0);
//			for (var j:Number = 1; j < nodeDataTable.getNumberOfColumns(); j++){
//				data.push({index: nodeDataTable.getColumnLabel(j).match(/t_(\d*)/)[1], value: nodeDataTable.getValue(i,j)});
//			}
//			this.network.setTimecourseData(interactor_name, data);
//			data=[]
//		}
//	}
	
	}
}