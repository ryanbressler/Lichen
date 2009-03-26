package org.systemsbiology.visualization
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
   	import flash.external.ExternalInterface;

	public class GoogleVisAPISprite extends Sprite
	{
		public var visindex : String;
		
		public function GoogleVisAPISprite()
		{
			this.visindex = root.loaderInfo.parameters.flashvarsId;//ExternalInterface.objectID;
			//ensure that coordinate system remians centered at upper left even after resize
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
            ExternalInterface.addCallback("draw", draw);
			ExternalInterface.addCallback("selectionSetViaJS", selectionSetViaJS);
			var callJas:String = "isbSWFvisualizations."+this.visindex+".bioheatmapFlashReady";
			ExternalInterface.call(callJas);
			super();
		}
		
		//overriden by base class
		public function draw(dataJSON:String,optionsJSON:String):void
		{
			
		}
		
		public function selectionSetViaJS(selection : String) : void 
		{
//	    	//decode
//	    	var selectionObj : Object = JSON.decode(selection)[0];
//
//	    	//draw
//	    	this._clearSelection();
//	    	if( selectionObj.hasOwnProperty("row") && selectionObj.row!=null && selectionObj.hasOwnProperty("col") && selectionObj.col!=null)
//	    	{
//	    		this._setSelectionCell(selectionObj.row, selectionObj.col);
//	    		return;	
//	    	}
//	    	
//	    	if( selectionObj.hasOwnProperty("col") && selectionObj.col!=null)
//	    	{
//	    		this._setSelectionCol(selectionObj.col);
//	    		return;	
//	    	}
//	    	
//	    	if( selectionObj.hasOwnProperty("row") && selectionObj.row!=null)
//	    	{
//	    		this._setSelectionRow(selectionObj.row);
//	    		return;	
//	    	}
	    	
	    		
	    }
		
	}
}