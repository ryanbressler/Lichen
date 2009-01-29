    
    function sprout(node_id){
          console.log("sprouting");
          console.log(node_id);
  		  url = 'http://sdee.hdbase.org/networkviz/NearestNeighbors/'+node_id+'?format=google&tqx=reqId:1;';
  		  console.log('URL: ' + url);
	  	  update_query = new google.visualization.Query('http://sdee.hdbase.org/networkviz/NearestNeighbors/'+node_id+'?format=google&tqx=reqId:1;');
	  	  console.log("update query");
	  	  console.log(update_query);
	  	  center=node_id;
	  	  update_query.send(processUpdate);
	  	}
	  	
	   function processNetworkData(response){
          // alert("processResponse");
			if (response.isError()) {
				alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
				return;
			}
			data = response.getDataTable();
			query2 = new google.visualization.Query('http://sdee.hdbase.org/networkviz/Attribute/?NET_DATA_URI=http://sdee.hdbase.org/networkviz/NearestNeighbors/'+center+'/&tqx=reqId:1;');
			query2.setTimeout(300);
			query2.send(processAttributeData);
			
			//networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
			//console.log("vis: " + networkvis.toString());

	  	}
      
    function processUpdate(response){
    //need to concatenate data?
      console.log("process update");
      console.log("TEST center" + center);
      console.log("response");
      console.log(response);
      console.log("center: "+center);
      	if (response.isError()) {
			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
			return;
		}
       console.log("update response");
       console.log(response);
       var new_data = response.getDataTable();
       console.log("processUpdate completed");
       console.log("new data log");
       console.log(new_data);
       //need to add new attribute_data
       networkvis.update_data(new_data, {attributes: attribute_data, center: center, data_format: "google"});
      }
      
      
      function processAttributeData(response){
        
        console.log("process attribute data");
        console.log("response");
        console.log(response);
      	if (response.isError()) {
			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
			return;
		}
       console.log("attribute response");
       attribute_data=response.getDataTable();
       console.log(data);
       networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
       networkvis.draw(data, {attributes: attribute_data, center:center, data_format:"google"});

      }
      
	//LAYOUT TEST FUNCTIONS
	  	
	 function processDataAndLayout(response){
		  // alert("processResponse");
			if (response.isError()) {
				alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
				return;
			}
			data = response.getDataTable();
			query2 = new google.visualization.Query('http://sdee.hdbase.org/networkviz/Attribute/?NET_DATA_URI=http://sdee.hdbase.org/networkviz/NearestNeighbors/'+center+'/&tqx=reqId:1;');
			query2.setTimeout(300);
			query2.send(processLayoutData);
			
			//networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
			//console.log("vis: " + networkvis.toString());
	 }
	 
	 function processLayoutData(response){
	 	
	 	console.log("process layout data");
        console.log("response");
        console.log(response);
      	if (response.isError()) {
			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
			return;
		}
       console.log("attribute response");
       attribute_data=response.getDataTable();
       //attribute_data=Object.toJSON(response.getDataTable());
       //attribute_data =  buildDataParam(response.getDataTable());
       console.log("serialized attribute data" + attribute_data);
       networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
       networkvis.draw(data, {attributes: attribute_data, layout: attribute_data, center:center, data_format:"google"});
	 	
	 
	 }
	 
	   function buildDataParam(dataTable){
 		console.log("buildDataParam");
 		console.log(dataTable);
		//console.log(!this.isEmpty(dataTable));
		if (!this.isEmpty(dataTable)){
		//if (true){
    	var dataParam = {cols:[], rows:[]};
    	console.log("Num columns");

    	console.log(dataTable.getNumberOfColumns());
    	for (var coli=0;coli<dataTable.getNumberOfColumns();coli++){
			dataParam.cols[coli]={id: dataTable.getColumnId(coli), label: dataTable.getColumnLabel(coli), type: 'string'};

			for (var rowi=0;rowi<dataTable.getNumberOfRows();rowi++){
				dataParam.rows[rowi]={};
				dataParam.rows[rowi].c=[];
				for (var coli=0;coli<dataTable.getNumberOfColumns();coli++){
					//will need to add any aditional paramters used here
					dataParam.rows[rowi].c[coli]={v:dataTable.getValue(rowi,coli)};
					if(dataTable.getFormattedValue(rowi,coli)){
						dataParam.rows[rowi].c[coli].f=dataTable.getFormattedValue(rowi,coli);
					}
				}
			}
		}
    }
    	//console.log(dump(dataParam));
    	return dataParam;
    	
    }
	 
      
    function isEmpty(object) {
		for (var i in object) { return false; }
		return true;
	}  
	 
	  	
	function dump(arr,level) {
	var dumped_text = "";
	if(!level) level = 0;
	
	//The padding given at the beginning of the line.
	var level_padding = "";
	for(var j=0;j<level+1;j++) level_padding += "    ";
	
	if(typeof(arr) == 'object') { //Array/Hashes/Objects 
		for(var item in arr) {
			var value = arr[item];
			
			if(typeof(value) == 'object') { //If it is an array,
				dumped_text += level_padding + "'" + item + "' ...\n";
				dumped_text += dump(value,level+1);
			} else {
				dumped_text += level_padding + "'" + item + "' => \"" + value + "\"\n";
			}
		}
	} else { //Stings/Chars/Numbers etc.
		dumped_text = "===>"+arr+"<===("+typeof(arr)+")";
	}
	return dumped_text;
}
	