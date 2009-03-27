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
// - FlexVisTemplate
// -
// -   Description: A template for google visualization api compliant flex visualizations
// -   Author: rbressler
// -   Version: beta1
// -
// ---------------------------------------------------------------------------------------------------------------------

org.systemsbiology.visualization.FlexVisTemplate = Class.create({
	

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
    	this.SWFid= "flexvistemplate"+this.visindex;
    	isbSWFvisualizations[this.SWFid] = this;
    	
    	},



    // Main drawing logic.

    // Parameter data is of type google.visualization.DataTable.

    // Parameter options is a name/value map of options.

    draw: function(data, options) {
    	
    	this.flashLoading = true;
    	
    	//the flash vis will call this when it is done loadind
    	var readyFnc = function()
    	{
    		this.flashLoading = false;
    	};
    	this.flashReady = readyFnc.bind(this);
    	
 		//the embed string
    	//leading hidden empty div to get around ie 6 foolishness with scope/noscope objects
    	//object tag is for ie
    	//embed tag is for other browsers
    	//flashvars flashvarsId is used in both to hand in the id of the object since linux flash player can't see ExternalInterface.objectID   	
    	var embedString = "<div></div><object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0\" id=\""+this.SWFid+"\" width=\"100%\" height=\"100%\"><param name=\"movie\" value=\"flexvistemplate.swf\" /><param name=\"quality\" value=\"high\" /><param name=\"bgcolor\" value=\"#FFFFFF\" /> <param name=\"allowScriptAccess\" value=\"sameDomain\" /><param name=\"flashvars\" value=\"flashvarsId="+this.SWFid+"\" /><embed src=\"flexvistemplate.swf\" quality=\"high\" bgcolor=\"#FFFFFF\" width=\"100%\" height=\"100%\" flashvars=\"flashvarsId="+this.SWFid+"\" name=\""+this.SWFid+"\" align=\"middle\" play=\"true\" loop=\"false\" quality=\"high\" allowScriptAccess=\"sameDomain\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.adobe.com/go/getflashplayer\"></embed></object>";
		this.containerElement.innerHTML=embedString;
		
		//prepare paramaters and inititiate polling of flashLoading
		var dataparam = this.buildDataParam(data);
		myPe = new PeriodicalExecuter(this.swfPoll.bind(this,dataparam,options), .01);

    },
    
    //google datatable does not have a json export so this function
    //builds the json we need using api compliant functions
    //we can't just serialize the datatable because google has changed
    //its underlying structure in the past.
    buildDataParam : function(dataTable){
 
    	var dataParam = {cols:[], rows:[]};
    	
    	for (var coli=0;coli<dataTable.getNumberOfColumns();coli++) 
		{
			//currently coerces all columns to type string as that is all we have used so far
			dataParam.cols[coli]={id: dataTable.getColumnId(coli), label: dataTable.getColumnLabel(coli), type: 'string'};
			
		}
		
		for (var rowi=0;rowi<dataTable.getNumberOfRows();rowi++) 
		{
			dataParam.rows[rowi]={};
			dataParam.rows[rowi].c=[];
			for (var coli=0;coli<dataTable.getNumberOfColumns();coli++) 
			{
			//will need to add any aditional paramters used here
			dataParam.rows[rowi].c[coli]={v:dataTable.getValue(rowi,coli)};
			if(dataTable.getFormattedValue(rowi,coli))
				dataParam.rows[rowi].c[coli].f=dataTable.getFormattedValue(rowi,coli);
				
			
			}
		}
    	
    	return dataParam;
    },
    
    //the draw function creates a version of this function with data and options set, 
    // bound to this scope and calls it with a periodical executer, pe 
    swfPoll : function(data,options,pe) {

  		if (!this.flashLoading){
  		pe.stop();
  		var swf =this.getSWF(this.SWFid);
  		
		swf.draw(Object.toJSON(data),Object.toJSON(options));

    	}
    	},
    	
    //for use by other visualizations
    getSelection: function() {

        return this._selected;

    },



    // set's the current selected rows, cols or cells
    // called by other visualizations and by the swf object

    setSelection: function(selection) {
        this._selected = selection;
        var swf =this.getSWF(this.SWFid);
        swf.selectionSetViaJS(Object.toJSON(selection));

    },
    

    
    
    	// Gets a reference to the specified SWF file by checking which browser is
	// being used and using the appropriate JavaScript.
	// Unfortunately, newer approaches such as using getElementByID() don't
	// work well with Flash Player/ExternalInterface.
	getSWF: function(movieName) {
			return document[movieName];
	}
    
});









