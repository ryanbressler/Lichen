package 
{

        
        import flash.display.Sprite;
        import flash.display.StageAlign;
        import flash.display.StageScaleMode;
        
        import flash.events.Event;
        import flash.events.MouseEvent;
        
        import flash.external.ExternalInterface;
        
        import flash.text.TextFormat;
        
        import com.adobe.serialization.json.JSON;     
        
        import org.systemsbiology.visualization.data.*;
 		
        public class flexvistemplate extends Sprite
        {

                //paramaters
                public var visindex : String;
                public var myData:Object;
                public var options:Object;
                
                //font
                // We must embed a font so that we can rotate text and do other special effects
                // You may have to change this to a font instaled on your system
			   	[Embed(systemFont='Helvetica', 
			        fontName='myHelveticaFont', 
			        mimeType='application/x-font'
			    )] 
			    // You do not use this variable directly. It exists so that 
			    // the compiler will link in the font.
			    private var _font1:Class;
			    private var _fontHeight:int = 14;			    
			    private var  _labelTextFormat : TextFormat = new TextFormat('myHelveticaFont',14);             
                		

                
                //out puts a message to either the debugger player log file or flexbuilder consol	
                private function _log (msg : String) : void {
                		trace(msg);
                	}
                
                //constructor
                public function flexvistemplate(){
            		
            		//ExternalInterface.objectID doesn't work under linux so we pass it in manually
					this.visindex = root.loaderInfo.parameters.flashvarsId;
					
					//ensure that coordinate system remians centered at upper left even after resize
					stage.scaleMode = StageScaleMode.NO_SCALE;
					stage.align = StageAlign.TOP_LEFT;

					this._log("Vis Initalized");
					
                    //Expose draw and selection handelers to js
                    ExternalInterface.addCallback("draw", draw);
					ExternalInterface.addCallback("selectionSetViaJS", selectionSetViaJS);
					
					//Inform js that the swf has loaded
					var callJas:String = "isbSWFvisualizations."+this.visindex+".flexvistemplateFlashReady";
					ExternalInterface.call(callJas);

                }
          
                public function draw(dataJSON:String,optionsJSON:String):void
                {
                	this._log("Draw called");
                	this.myData = new org.systemsbiology.visualization.data.DataView(dataJSON,"");

                	this.options = JSON.decode(optionsJSON);
                	
                	//drawing logic goes here
                	
                	

                }
                
                
			    
			    //interprets click events as selections the sends the appropriate notification to the js side
			    //create a display object with int row and col members and use this function as the click
			    //event handeler
			    private function _clickHandeler(eventObject: Event): void {
			    	
			    	if(eventObject.currentTarget.hasOwnProperty("row") && eventObject.currentTarget.hasOwnProperty("col"))
			    	{
			    		this._bubbleSelection({row: eventObject.currentTarget.row, col: eventObject.currentTarget.col});
			    		return;	
			    	}
			    	
			    	if( eventObject.currentTarget.hasOwnProperty("col"))
			    	{
			    		this._bubbleSelection({row: "null",col: eventObject.currentTarget.col});
			    		return;	
			    	}
			    	
			    	if( eventObject.currentTarget.hasOwnProperty("row"))
			    	{
			    		this._bubbleSelection({row: eventObject.currentTarget.row, col: "null"});
			    		return;	
			    	}
			    	
			    }
			    
			    //sends the selection to the js side and makes it available to other visualizations
				private function _bubbleSelection(selection:Object) : void {
					var jsstring : String = "function(){"
					//jsstring += "console.log('calling');";
					jsstring += "isbSWFvisualizations."+this.visindex+".setSelection([{row: "+selection.row+", col: "+selection.col+"}]);";
					jsstring += "google.visualization.events.trigger(isbSWFvisualizations."+this.visindex+", 'select', null);"
					jsstring +="}"
					ExternalInterface.call(jsstring);// .setSelection('test');}");// google.visualization.events.trigger(isbSWFvisualizations."+this.visindex+", 'select', null);}");
				}
				
				//clears the selection in the AS context
				private function _clearSelection() : void {

					
					
			    }			    
			    
			    //these 3 functions  do the actuall selecting in the AS context and should be used to update the display
			    private function _setSelectionCell(row : *, col : *) : void {
					this._log("cell selected");
					
			    }
			    
			    private function _setSelectionCol(col : *) : void {
			    	this._log("cell selected");


			    }
			    
			    private function _setSelectionRow(row : *) : void {
			    	this._log("row selected");
			    }
			    
			    //this function is called by JS when the selection is set. It gets fired via the bubbled event or 
			    //any api compliant JS selection change.
			    
			    public function selectionSetViaJS(selection : String) : void {
			    	//decode
			    	var selectionObj : Object = JSON.decode(selection)[0];

			    	//draw
			    	this._clearSelection();
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
	
				//a usefull function for grabing data values
			    private function _getValueFormattedOrNot(row : int, col : int) : String {
			    	var returnValue : String;
			    	if(this.myData.getFormattedValue(row,col)!=undefined){
			    		returnValue = this.myData.getFormattedValue(row,col)
			    	}
			    	else
			    	{
			    		returnValue = this.myData.getValue(row,col);
			    	}
			    		
					return returnValue;
			    }
			    
			    
        }
}