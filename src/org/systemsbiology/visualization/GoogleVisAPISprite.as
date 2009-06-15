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
**    License along with this library; If not, see <http://www.gnu.org/licenses/>.
*/

package org.systemsbiology.visualization
{
	import com.adobe.serialization.json.JSON;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import org.systemsbiology.visualization.data.DataView;
	import org.systemsbiology.visualization.data.LayoutDataView;

	public class GoogleVisAPISprite extends Sprite
	{
		public var visindex : String;

		////////////////////////////////////////////////////////////////////////
		//functions to be implemented as overrides by the child class
		//
		
		//overriden by base class
		public function draw(dataJSON:String,optionsJSON:String):void
		{
			
		}
		
		//clears the selection in the AS context
		protected function _clearSelectionDisplay() : void {

		}	
			    
		//these 3 functions  do the actuall selecting in the AS context (display)
	    protected function _setSelectionCell(row : *, col : *) : void {

	    }
	    
	    protected function _setSelectionCol(col : *) : void {

	    }
	    
	    protected function _setSelectionRow(row : *) : void {

	    }
	    
		////////////////////////////////////////
		// functions implemented in this class. 
		// Ideally all external interface stuff will go here
		
	    public function GoogleVisAPISprite()
		{
			this.visindex = root.loaderInfo.parameters.flashvarsId;//ExternalInterface.objectID;
			//ensure that coordinate system remians centered at upper left even after resize
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
            ExternalInterface.addCallback("draw", draw);
			ExternalInterface.addCallback("selectionSetViaJS", selectionSetViaJS);
			var callJas:String = "isbSWFvisualizations."+this.visindex+".flashReady";
			ExternalInterface.call(callJas);
			super();
		}
	
		
		//function for imorting and parseing options	
		protected function parseOptions(optionsJSON:String, optionsListObject : Object) : Object {						
			var options : Object = JSON.decode(optionsJSON);
			var parseAs:String;
			//data tables
			//import data JSON
			for( var optionName : String in optionsListObject)
			{
				parseAs = optionsListObject[optionName].parseAs;
				trace(parseAs);
				if (options[optionName]){
					if(parseAs=="dataTable")
					{			
						options[optionName] = new DataView(JSON.encode(options[optionName]),"");
					}
					else if (parseAs=="layoutTable"){
						options[optionName] = new LayoutDataView(JSON.encode(options[optionName]),"");
					}
//					else if (parseAs=="nodeDataTable"){
//						
//					}
					else if (optionsListObject[optionName].parseAs=="color")
					{
						
					}
				}
			}
	        return options;
		}
		
		//return 
		protected function parseUpdatedOptions(newOptions:Object, optionsListObject:Object, currentOptions:Object) : Object {
			var changed = new Object();
			for(var optionName : String in optionsListObject){
				if (newOptions[optionName]){
					if(optionsListObject[optionName].parseAs=="dataTable"){			
						//want to check if data table is same or just go ahead and mark as changed?		
						changed[optionName] = true;			
					}
					else if (optionsListObject[optionName].parseAs=="bundle"){
						for(var optionParam:String in newOptions[optionName]){
							if (newOptions[optionName][optionParam]!=currentOptions[optionName][optionParam]){
								changed[optionName]=true;
								break;
							}
						}	
					}
					else {
						if (newOptions[optionName]!=currentOptions[optionName]){
							changed[optionName]=true;
						}
						else{
							changed[optionName]=false;
						}
					}
				}
			}
			return changed;
		}	
		
		//out puts a message to either the debugger player log file or flexbuilder consol	
        protected function _log (msg : String) : void {
            trace(msg);
        }
	    
	    //resizes the htmle div that is the container
	    protected function resizeContainer (widthPixels:int, heightPixels:int):void
	    {
	    	var resizetxt : String = "function(){";
			resizetxt +="isbSWFvisualizations."+this.visindex+".containerElement.style.height = "+heightPixels+" + \"px\";";
			resizetxt +="isbSWFvisualizations."+this.visindex+".containerElement.style.width = "+widthPixels+" + \"px\";";
			resizetxt +="}";
					
			ExternalInterface.call(resizetxt);
	    }
		
		//interprets events as selections the sends the appropriate notification to the js side
	    protected function _selectionHandeler(eventObject: MouseEvent): void {
	    	var append : Boolean = eventObject.ctrlKey || eventObject.shiftKey;
	    	
	    	if(eventObject.currentTarget.hasOwnProperty("props") && eventObject.currentTarget.props.hasOwnProperty("selection") )
	    	{
	    		this._bubbleSelection(eventObject.currentTarget.props.selection,append);
	    		return;
	    	}
	    	if(eventObject.currentTarget.hasOwnProperty("row") && eventObject.currentTarget.hasOwnProperty("col"))
	    	{
	    		this._bubbleSelection([{row: eventObject.currentTarget.row, col: eventObject.currentTarget.col}],append);
	    		return;	
	    	}
	    	
	    	if( eventObject.currentTarget.hasOwnProperty("col"))
	    	{
	    		this._bubbleSelection([{row: "null",col: eventObject.currentTarget.col}],append);
	    		return;	
	    	}
	    	
	    	if( eventObject.currentTarget.hasOwnProperty("row"))
	    	{
	    		this._bubbleSelection([{row: eventObject.currentTarget.row, col: "null"}],append);
	    		return;	
	    	}
	    	
	    }
	    
	    //function for bubbleing arbitrary events
		protected function _bubbleEvent(eventName: String, paramaterKeyValues : Object = null ) : void {
			var jsstring : String = "function(){"
			jsstring += "google.visualization.events.trigger(isbSWFvisualizations."+this.visindex+", '"+eventName+"', "+JSON.encode(paramaterKeyValues)+");"
			jsstring +="}"
			ExternalInterface.call(jsstring);
		}
		
	    //sends the selection to the js side and makes it available to other visualizations
		private function _bubbleSelection(selection:Object, append : Boolean = false) : void {
			var jsstring : String = "function(){"
			jsstring += "isbSWFvisualizations."+this.visindex+".setSelection("+JSON.encode(selection)+(append ? ",true":"")+");";
			jsstring += "google.visualization.events.trigger(isbSWFvisualizations."+this.visindex+", 'select', null);"
			jsstring +="}"
			ExternalInterface.call(jsstring);// .setSelection('test');}");// google.visualization.events.trigger(isbSWFvisualizations."+this.visindex+", 'select', null);}");
		}
		
		//this function is called by JS when the selection is set. It gets fired via the bubbled event or 
		//any api compliant JS selection change.
		
		public function selectionSetViaJS(selection : String) : void 
		{
	    	//decode
	    	var selectionArray : Array = JSON.decode(selection) as Array;

	    	//draw
	    	this._clearSelectionDisplay();
	    	
	    	
	    	for each (var selectionObj : Object in selectionArray)
	    	{
		    	
		    	if( checkObjProp(selectionObj,"row") && checkObjProp(selectionObj,"col") )
		    	{
		    		this._setSelectionCell(selectionObj.row, selectionObj.col);
		    		continue;	
		    	}
		    	
		    	if( checkObjProp(selectionObj,"col"))
		    	{
		    		this._setSelectionCol(selectionObj.col);
		    		continue;	
		    	}
		    	
		    	if( checkObjProp(selectionObj,"row"))
		    	{
		    		this._setSelectionRow(selectionObj.row);
		    		continue;	
		    	}
	    	}		
	    }
	    
	    protected function checkObjProp(selectionObj:Object, propname : String) : Boolean
	    {
	    	return selectionObj.hasOwnProperty(propname) && selectionObj[propname]!=null && selectionObj[propname]!= "null";
	    }
	    
		
	}
}