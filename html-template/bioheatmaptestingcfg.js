/////////////////////////////////////////////////////
//cfg section
//////////////////////////////////////////////////////
//defaults 

var defaultvalues = {vis:"bioheatmap",data:"penndata"};

//visualisations to test
var visualizations = {
	bioheatmap:{
		classname: "BioHeatMap"}
		};


//data sets to use
var datasets = {
	penndata:{
		url:"penndata_response.txt"
	},
	melrose_webservice:{
		url:"http:\/\/sdee.hdbase.org/meta/datagrid/gene_ids=6891,10107,389376,79136,10255,6890,10554,57176,58538,7922,6293,9278,80352,6222,30834,221504,57827,80741,7940,28973,23564,6046,55937,199,11270,84300,3127,170679,80742,8859,1041,1589/assay_ids=2119,2120,2121,2122,2123,2124,2125,2126,2127,2128,2129,2130,2131,2132,2133,2134,2135,2126/"
	}
};

///////////////////////////////
// testing script
////////////////////////////////
function showTestingScript(){
	console.log("visualization drawn. does it look right?");
	console.log("please select a cell, then a row and a column. Selection events will be logged here.");
}

/////////////////////////////////////////////
// programatic  section
///////////////////////////////////

google.setOnLoadCallback(loadAndInitiate); // Set callback to run when API is loaded
	
function loadAndInitiate() {
       	var data = new google.visualization.DataTable();        
		data.addColumn('string', 'label');
		data.addColumn('string', 'Upregulated');
		data.addColumn('string', 'Downregulated');
		data.addColumn('string', 'No Change/Not Significant');
		data.addColumn('string', 'Significant');
		data.addColumn('string', 'No Data');
		
		data.addRows(1);       
		data.setValue(0, 0, 'Values: ');
		data.setValue(0, 1, '1');
		data.setValue(0, 2, '-1');
		data.setValue(0, 3, '0');
		data.setValue(0, 4, 'Y');
		data.setValue(0, 5, null);

		var leg = new org.systemsbiology.visualization.BioHeatMap($("legenddiv"));
		leg.draw(data, {cellHeight:30,cellWidth:30, startColor: {r:255, g:0, b:0, a:1},
                                  endColor: {r:255, g:255, b:0, a:1},});
		
		var url = datasets[defaultvalues.data].url
		query = new google.visualization.Query(url);
		query.send(processResponseAndDraw);
  }
  
function processResponseAndDraw(response){
      // alert("processResponse");
	if (response.isError()) {
		alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
		return;
	}
	var data = response.getDataTable();

	var viscfg = visualizations[defaultvalues.vis];
	var vis1 = new org.systemsbiology.visualization[viscfg.classname](document.getElementById('exampleVisContainer1'));;
	vis1.draw(data, {cellHeight:30,cellWidth:30});

	var vis2 = new org.systemsbiology.visualization[viscfg.classname](document.getElementById('exampleVisContainer2'));	
	vis2.draw(data, {cellHeight:30,cellWidth:30});
	
	
	var myTable = google.visualization.Table(document.getElementById("dataTableContainer"));	
    myTable.draw(data,{});
    
    google.visualization.events.addListener(vis1, 'select', function() {
    			vis2.setSelection(vis1.getSelection());
    //            myTable.setSelection(vis1.getSelection());
            });
    google.visualization.events.addListener(vis2, 'select', function() {
    			vis1.setSelection(vis2.getSelection());
    //            myTable.setSelection(vis2.getSelection());
            });
    //google.visualization.events.addListener(table, 'select', function() {
    //            vis1.setSelection(table.getSelection());
    //           vis2.setSelection(table.getSelection());
    //        });		
	
}



	  	

	  	
	
	