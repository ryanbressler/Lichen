/*
**    Copyright (C) 2003-2008 Institute for Systems Biology
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
**    License along with this library; if not, write to the Free Software
**    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

// setup namespace if not already defined
if(!org) {
    var org = {};
    if(!org.systemsbiology)
        org.systemsbiology = {};
    if(!org.systemsbiology.visualization)
        org.systemsbiology.visualization = {};
}


// ---------------------------------------------------------------------------------------------------------------------
// - BioNetwork
// -
// -   Description: Draws a gene expression style heatmap using Canvas
// -   Author: dburdick
// -   Version: 1.0
// -
// ---------------------------------------------------------------------------------------------------------------------

org.systemsbiology.visualization.BioNetwork = Class.create({



    // --------------------------------------------------------

    // PUBLIC METHODS

    // --------------------------------------------------------

    initialize: function(container) {
    	this.containerElement = container;
    	//create or preserve the global array used by swf visualizations to acces their js counterparts
    	if(window.isbSWFvisualizations === undefined)
    	{
    		isbSWFvisualizations = [];
    		isbSWFvisualizations["SWFcount"]=0;
    	}
    	else
    	{
    		isbSWFvisualizations["SWFcount"]++;
    	}
    	this.visindex = isbSWFvisualizations["SWFcount"];
    	this.SWFid= "bionetwork"+this.visindex;
    	isbSWFvisualizations[this.SWFid] = this;
    	
    	},



    // Main drawing logic.

    // Parameter data is of type google.visualization.DataTable.

    // Parameter options is a name/value map of options.

    draw: function(data, options) {
    	log("draw");
    	log("check data");
    	log(data.getNumberOfColumns());
    	log(data.getValue(1,1));
    	
    	//log(dump(options));
    	
    	this.flashLoading = true;
    	var readyFnc = function()
    	{
    		this.flashLoading = false;
    	};
    	
    	//global function could be bad?
    	this.bioheatmapFlashReady = readyFnc.bind(this);
    	//hidden input or div to get around ie 6 foolishness with scope/noscope objects
    	var embedString = "<div></div><object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0\" id=\""+this.SWFid+"\" width=\"100%\" height=\"100%\"><param name=\"movie\" value=\"bionetwork.swf\" /><param name=\"quality\" value=\"high\" /><param name=\"flashvars\" value=\"flashvarsId="+this.SWFid+"\" /><param name=\"bgcolor\" value=\"#FFFFFF\" /> <param name=\"allowScriptAccess\" value=\"sameDomain\" /><embed src=\"bionetwork.swf\" quality=\"high\" bgcolor=\"#FFFFFF\" width=\"100%\" height=\"100%\" name=\""+this.SWFid+"\" flashvars=\"flashvarsId="+this.SWFid+"\" align=\"middle\" play=\"true\" loop=\"false\" quality=\"high\" allowScriptAccess=\"sameDomain\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.adobe.com/go/getflashplayer\"></embed></object>";
		this.containerElement.innerHTML=embedString;
		//this.containerElement.innerHTML ="<object id=\"bioheatmap\" codebase=\"http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab\"> <param name=\"movie\" value=\"bioheatmap.swf\" /> <param name=\"quality\" value=\"high\" /> <param name=\"bgcolor\" value=\"#FFFFFF\" /> <param name=\"allowScriptAccess\" value=\"sameDomain\" /> <embed src=\"bioheatmap.swf\" quality=\"high\" bgcolor=\"#FFFFFF\" name=\"bioheatmap\" align=\"middle\" play=\"true\" loop=\"false\" quality=\"high\" allowScriptAccess=\"sameDomain\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.adobe.com/go/getflashplayer\"> </embed> </object>"
		
		//wait for swf to be ready...is this necesairy?
		log("dataparam");
		var dataparam = this.buildDataParam(data);
		//log(dataparam);
		//onsole.log("building options param");
		//log(dump(options));
		//var optionsparam = this.buildDataParam(options);
		
    myPe = new PeriodicalExecuter(this.swfPoll.bind(this,data,options), .01);
	//myPe = new PeriodicalExecuter(this.swfPoll.bind(this,dataparam,optionsparam),.01);

		//alert(Object.toJSON(data));
    },
    
    update_data : function(data,options) {
		swf = this.getSWF(this.SWFid);
        if (!this.flashLoading) {
           //swf.update_data("hello");
           //this.swfPoll.bind(this,data,options);
           log("viz_id"+ this.SWFid);
           log(data);
           log(options);
           log(swf);
           var dataparam = this.buildDataParam(data);
           var optionsparam = this.buildDataParam(options['attributes']);
           //this.swf.draw(data,options);
		  swf.redraw(Object.toJSON(data),Object.toJSON({attributes: optionsparam, center: options['center'], data_format: "google"}));
          
           //this.swfPoll.bind(this,dataparam, {attributes: optionsparam, center: '3630', data_format: "static"});
           // myPe = new PeriodicalExecuter(this.swfPoll.bind(this,data,options), .01);
		   log("js update_data");
		}
    },
    
    isEmpty : function(object) {
		for (var i in object) { return false; }
		return true;
	},
    
    buildDataParam : function(dataTable){
 		log("buildDataParam");
 		log(dataTable);
		log(!this.isEmpty(dataTable));
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
    	
    },
      
    swfPoll : function(data,options,pe) {

  		if (!this.flashLoading){
  		pe.stop();
  		var swf = this.getSWF(this.SWFid);
  		log("drawing "+this.SWFid);
  		
		swf.draw(Object.toJSON(data),Object.toJSON(options));

    	}
    },
    	
    getSelection: function() {

        return this._selected;

    },

    // set's the current selected rows, cols or cells

    setSelection: function(selection) {
    	//log("set selection called");
        //log("selection is"+ selection.toString());
        this._selected = selection;
        //log(this.SWFid);
        var swf =this.getSWF(this.SWFid);
        swf.selectionSetViaJS(Object.toJSON(selection));

    },
   
    
    	// Gets a reference to the specified SWF file by checking which browser is
	// being used and using the appropriate JavaScript.
	// Unfortunately, newer approaches such as using getElementByID() don't
	// work well with Flash Player/ExternalInterface.
	getSWF: function(movieName) {
		//alert("doc:"+ document[movieName]);
		//alert("window:"+ window[movieName]);
		//return this.containerElement[movieName];
		//if (navigator.appName.indexOf("Microsoft") != -1) {
			//alert("ie");
		//	return window[movieName];
		//} else {
			return document[movieName];
		//}
	},
	
	dump: function (arr,level) {
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
},

    
});









