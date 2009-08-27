/*
**    Copyright (C) 2003-2009 Institute for Systems Biology
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
    	this.flashLoading = true;
    	var readyFnc = function()
    	{
    		this.flashLoading = false;
    	};
    	//global function could be bad?
    	this.flashReady = readyFnc.bind(this);
    	//hidden input or div to get around ie 6 foolishness with scope/noscope objects
    	var embedString = "<div></div><object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0\" id=\""+this.SWFid+"\" width=\"100%\" height=\"100%\"><param name=\"movie\" value=\"bionetwork.swf\" /><param name=\"quality\" value=\"high\" /><param name=\"flashvars\" value=\"flashvarsId="+this.SWFid+"\" /><param name=\"bgcolor\" value=\"#FFFFFF\" /> <param name=\"allowScriptAccess\" value=\"sameDomain\" /><embed src=\"bionetwork.swf\" quality=\"high\" bgcolor=\"#FFFFFF\" width=\"100%\" height=\"100%\" name=\""+this.SWFid+"\" flashvars=\"flashvarsId="+this.SWFid+"\" align=\"middle\" play=\"true\" loop=\"false\" quality=\"high\" allowScriptAccess=\"sameDomain\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.adobe.com/go/getflashplayer\"></embed></object>";
		this.containerElement.innerHTML=embedString;
    	
    	},

    // Main drawing logic.

    // Parameter data is of type google.visualization.DataTable.

    // Parameter options is a name/value map of options.

    draw: function(data, options) {

    	
		//wait for swf to be ready...is this necesairy?
		var dataparam = data ==''?'' : this.buildDataParam(data);
		var optionsparam = {};
		for (opt in options){
			if (typeof(options[opt])=='object'){
				//inner loop for checking table
				//if (options[key]['tqx']){
					if (options[opt]['getNumberOfRows']){
						optionsparam[opt] = this.buildDataParam(options[opt]);
					} 
				else{
					optionsparam[opt]=options[opt];
				}	
			}
			else{
				optionsparam[opt] = options[opt];
			}
		}	
    myPe = new PeriodicalExecuter(this.swfPoll.bind(this,dataparam,optionsparam), .01);
	//myPe = new PeriodicalExecuter(this.swfPoll.bind(this,dataparam,optionsparam),.01);
		//alert(Object.toJSON(data));
    },
    
    
    isEmpty : function(object) {
		for (var i in object) { return false; }
		return true;
	},
    
   buildDataParam : function(dataTable){
    	var dataParam = {cols:[], rows:[]};
    	for (var coli=0;coli<dataTable.getNumberOfColumns();coli++) 
		{
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
      
    swfPoll : function(data,options,pe) {

  		if (!this.flashLoading){
  		pe.stop();
  		var swf = this.getSWF(this.SWFid);
		swf.draw(data==""?"":Object.toJSON(data),Object.toJSON(options));

    	}
    },
    	
    getSelection: function() {

        return this._selected;

    },
    
    getSelectionNodes: function() {

        return this._selectedNodes;

    },

    // set's the current selected rows, cols or cells

    setSelection: function(selection, append) {
    	
    	if(append!=true)
    	{
    		this._selectedNodes=new Array();
    		this._selected = new Array();
    	}
    	for (var rowi=0;rowi<selection.length;rowi++) 
		{
			if(selection[rowi].node)
			{
				this._selectedNodes.push(selection[rowi]);
			}
			elsehttp://rbressle.gdxbase.org/images//bullet_red_small.gif
			{
				this._selected.push(selection[rowi]);
			}
		}
        var swf =this.getSWF(this.SWFid);
        swf.selectionSetViaJS(Object.toJSON(this._selected.concat(this._selectedNodes)));

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
	}

    
});









