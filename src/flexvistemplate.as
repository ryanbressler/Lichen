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

package 
{

        
        import com.adobe.serialization.json.JSON;
        
        import flash.display.StageAlign;
        import flash.display.StageScaleMode;
        import flash.events.Event;
        import flash.external.ExternalInterface;
        import flash.text.TextFormat;
        
        import org.systemsbiology.visualization.GoogleVisAPISprite;
        import org.systemsbiology.visualization.data.*;
 		
        public class flexvistemplate extends GoogleVisAPISprite
        {

                //paramaters
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

                //constructor
                public function flexvistemplate(){
                	//any additional external interface functions that need to be registered 
                	//should be registered here
                	
            		//call the super class (GoogleVisAPISprite) constructor
            		//which does alot of house keeping
            		super();

                }
          
                public override function draw(dataJSON:String,optionsJSON:String):void
                {
                	this._log("Draw called");
                	this.myData = new org.systemsbiology.visualization.data.DataView(dataJSON,"");

                	this.options = JSON.decode(optionsJSON);
                	
                	this._log("Data decoded");
                	
                	//resize the stage if needed
                	//this.resizeContainer(widthPixels,heightPixels)
                	
                	//drawing logic goes here
                	
                	//wireinto selection events by creating objects that inherit from Sprite
                	//and have row and or column properties or something like
                	// props.selection=[{row:1},{row:2,col:1}]
                	// and attach a the selectionHandler as follows:
                	//someSprite.addEventListener(MouseEvent.CLICK,this._selectionHandeler);
                	
                	

                }
                
                //usefull for visualizations thet might utilize formated values
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
                
                ////////////////////////////////////////////////////////////////////////
                //selection functions
                ////////////////////////////////////////////////////////////////////////
                // these are responsible for the DISPLAY of row, column and cell selection in the as context
                // selection data is persisted in js so that it may be used by other visualizations
                // multiple selection is currently not supported. it may be in the near future in which case expect 
                // multiple setSelection_____ calls between _clearSelection calls
				
				//clears the selection in the AS context
				protected override function _clearSelectionDisplay() : void {

					
					
			    }			    
			    
			    //these 3 functions  do the actuall selecting in the AS context and should be used to update the display
			    protected override function _setSelectionCell(row : *, col : *) : void {
					this._log("cell selected");
					
			    }
			    
			    protected override function _setSelectionCol(col : *) : void {
			    	this._log("cell selected");


			    }
			    
			    protected override function _setSelectionRow(row : *) : void {
			    	this._log("row selected");
			    }
			    
			    
        }
}