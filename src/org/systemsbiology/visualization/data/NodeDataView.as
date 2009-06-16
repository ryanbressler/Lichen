package org.systemsbiology.visualization.data
{
	//DataView for data that is attached to nodes as a list (rather than spread out as properties
	public class NodeDataView extends DataView
	{
		private var interactor_name:String;
		var data:Array = new Array();
		
		public function NodeDataView(dataJSON:String, isGoogle:String)
		{
			super(dataJSON, isGoogle);
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