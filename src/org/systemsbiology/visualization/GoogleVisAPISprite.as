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
	import flash.events.Event;
	import flash.external.ExternalInterface;

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
		protected function _clearSelection() : void {

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
	    protected function _selectionHandeler(eventObject: Event): void {
	    	
	    	if(eventObject.currentTarget.hasOwnProperty("props") && eventObject.currentTarget.props.hasOwnProperty("selection") )
	    	{
	    		this._bubbleSelection(eventObject.currentTarget.props.selection);
	    		return;
	    	}
	    	if(eventObject.currentTarget.hasOwnProperty("row") && eventObject.currentTarget.hasOwnProperty("col"))
	    	{
	    		this._bubbleSelection([{row: eventObject.currentTarget.row, col: eventObject.currentTarget.col}]);
	    		return;	
	    	}
	    	
	    	if( eventObject.currentTarget.hasOwnProperty("col"))
	    	{
	    		this._bubbleSelection([{row: "null",col: eventObject.currentTarget.col}]);
	    		return;	
	    	}
	    	
	    	if( eventObject.currentTarget.hasOwnProperty("row"))
	    	{
	    		this._bubbleSelection([{row: eventObject.currentTarget.row, col: "null"}]);
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
		private function _bubbleSelection(selection:Object) : void {
			var jsstring : String = "function(){"
			jsstring += "isbSWFvisualizations."+this.visindex+".setSelection("+JSON.encode(selection)+");";
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
	    	this._clearSelection();
	    	
	    	for each (var selectionObj : Object in selectionArray)
	    	{
		    	
		    	if( selectionObj.hasOwnProperty("row") && selectionObj.row!=null && selectionObj.hasOwnProperty("col") && selectionObj.col!=null)
		    	{
		    		this._setSelectionCell(selectionObj.row, selectionObj.col);
		    		return;	
		    	}
		    	
		    	if( selectionObj.hasOwnProperty("col") && selectionObj.col!=null)
		    	{
		    		this._setSelectionCol(selectionObj.col);
		    		return;	
		    	}
		    	
		    	if( selectionObj.hasOwnProperty("row") && selectionObj.row!=null)
		    	{
		    		this._setSelectionRow(selectionObj.row);
		    		return;	
		    	}
	    	}
	    	
	    		
	    }
		
	}
}