    
    DEBUG=1;
    
    function log(message){
    	
    	if (DEBUG){
    		console.log(message);
    	}
    }
    
    function sprout(node_id){
          log("sprouting");
          log(node_id);
  		  url = 'http://sdee.hdbase.org/networkviz/NearestNeighbors/'+node_id+'?format=google&tqx=reqId:1;';
  		  log('URL: ' + url);
	  	  update_query = new google.visualization.Query('http://sdee.hdbase.org/networkviz/NearestNeighbors/'+node_id+'?format=google&tqx=reqId:1;');
	  	  log("update query");
	  	  log(update_query);
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
			query2 = new google.visualization.Query('http://sdee.hdbase.org/networkviz/Attribute/?NET_DATA_URI=http://sdee.hdbase.org/networkviz/NearestNeighbors/23645/&tqx=reqId:1;');
			query2.setTimeout(300);
			query2.send(processAttributeData);
			//networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
			//log("vis: " + networkvis.toString());
	  	}
      
    function processUpdate(response){
    //need to concatenate data?
      log("response");
      log(response);
      log("center: "+center);
      	if (response.isError()) {
			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
			return;
		}
       log("update response");
       log(response);
       var new_data = response.getDataTable();
       log("processUpdate completed");
       log("new data log");
       log(new_data);
       //need to add new attribute_data
       networkvis.update_data(new_data, {attributes: attribute_data, center: center, data_format: "google"});
      }
      
      
      function processAttributeData(response){
        
        log("process attribute data");
        log("response");
        log(response);
      	if (response.isError()) {
			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
			return;
		}
       log("attribute response");
       attribute_data=response.getDataTable();
       log(data);
       networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
       networkvis.draw(data, {attributes: attribute_data, center:center, data_format:"google"});

      }
      
     function fetch_urls(){
     	log("fetch urls");
      	reqId=1;
      	cnt=0;
      	number_urls=0;
      	urls={data: 'http://sdee.hdbase.org/networkviz/NearestNeighbors/23645/?tqx=reqId:0;&format=google', layout: 'http://sdee.hdbase.org/networkviz/layout/random/?NET_DATA_URI=http://sdee.hdbase.org/networkviz/NearestNeighbors/23645/&tqx=reqId:1;'};
      	//layout: 'http://sdee.hdbase.org/networkviz/layout/random/?NET_DATA_URI=http://sdee.hdbase.org/networkviz/NearestNeighbors/23645/&tqx=reqId:1;&format=google
      	//layout: 'http://sdee.hdbase.org/networkviz/layout/random/?NET_DATA_URI=http://sdee.hdbase.org/networkviz/NearestNeighbors/7157/?tqx=reqId:1;'
		center='23645';
		for (var i in urls) {
			log("key " + i);
			log(eval('urls.' + i));
			//url = eval('urls.' + i)+'&tqx=reqId:'+reqId+';';
			url = eval('urls.' + i);
			log("url " + url);
			query=new google.visualization.Query(url);
			query.setTimeout(400);
			log("query " + query);
			if (i==='data'){
				func = 'processData';
			}
			else if (i==='attributes'){
				func='processAttributes';
			}
			else if (i==='layout'){
				func='processLayout';
			}
			query.send(eval(func));
			reqId+=1;
			number_urls+=1;
		} 
		
	   log("url size" + (number_urls).toString());
	   //wait
       	log("center" + center);
       		
      }


	function draw_vis(){
		log("draw_visualization");
		networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
       	networkvis.draw(data, {layout: layout_data, center:center, data_format:"google"});
	}
	  	
	 function processLayout(response){
	 	log("processLayout");
	 	if (response.isError()) {
			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
		}
		log(response);
		layout_data = response.getDataTable();
		cnt+=1;
		if (cnt===number_urls){
			draw_vis();
		}
	 } 	
	 
	 function processData(response){
	 	data='';
	 	log("processData");
	 	if (response.isError()) {
			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
		}
		data = response.getDataTable();
		while(true){
			if (!(data==='')){
				cnt+=1;
				break;
			}
		}
		if (cnt===number_urls){
			draw_vis();
		}
		log("data is" + data);
	 }
	 
	 function processAttributes(response){
	 	log("processAttributes");
	 	if (response.isError()) {
			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());	
		}
	 	attribute_data = response.getDataTable();
	 	cnt+=1;
	 }
	  	
// function processDataAndLayout(response){
// 	  // alert("processResponse");
// 		if (response.isError()) {
// 			alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
// 			return;
// 		}
// 		data = response.getDataTable();
// 		//query2 = new google.visualization.Query('http://sdee.hdbase.org/networkviz/Attribute/?NET_DATA_URI=http://sdee.hdbase.org/networkviz/NearestNeighbors/'+center+'/&tqx=reqId:1;');
// 		query2 = new google.visualization.Query('http://sdee.hdbase.org/networkviz/layout/random/?NET_DATA_URI=http://sdee.hdbase.org/networkviz/NearestNeighbors/'+23645+'/&tqx=reqId:1;');
// 		query2.setTimeout(300);
// 		query2.send(processLayoutData);	
// 		//networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
// 		//log("vis: " + networkvis.toString());
// }
// 
// function processLayoutData(response){
// 	
// 	log("process layout data");
//    log("response");
//    log(response);
//  	if (response.isError()) {
// 		alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
// 		return;
// 	}
// 	
//   log("layout response");
//   layout_data=response.getDataTable();
//   //attribute_data=Object.toJSON(response.getDataTable());
//   //attribute_data =  buildDataParam(response.getDataTable());
//   log("serialized attribute data" + layout_data);
//   networkvis = new org.systemsbiology.visualization.BioNetwork(document.getElementById('exampleVisContainer'));
//   networkvis.draw(data, {layout: layout_data, center:center, data_format:"google"});
// }
	 
	   function buildDataParam(dataTable){
 		log("buildDataParam");
 		log(dataTable);
		//log(!this.isEmpty(dataTable));
		if (!this.isEmpty(dataTable)){
		//if (true){
    	var dataParam = {cols:[], rows:[]};
    	log("Num columns");

    	log(dataTable.getNumberOfColumns());
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
    	//log(dump(dataParam));
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
	