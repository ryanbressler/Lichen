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
	import org.systemsbiology.visualization.data.NodeDataView;
	import r1.deval.*;

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
	
		
		//function for importing and parsing options
		protected function parseOptions(optionsJSON:String, optionsListObject : Object) : Object {
			trace(optionsJSON);
			var options : Object = JSON.decode(optionsJSON);
			var parseAs:String;
			var evalString:String;
			for (var optionName:String in options){
				trace("test");
				trace(optionName);
				parseAs = optionsListObject[optionName].parseAs;
				trace("PARSE AS");
				trace(parseAs);
				trace(options[optionName]);
////				if (options[optionName]){
					if(parseAs=="dataTable")
					{
						if(optionsListObject[optionName].classname){
//							trace(new NodeDataView(JSON.encode(options[optionName]),""));
							var jsonString:String = JSON.encode(options[optionName]);
							evalString = 'import org.systemsbiology.visualization.data.'+optionsListObject[optionName].classname+';\n'+'new ' + optionsListObject[optionName].classname+'(jsonString, "");';
							trace("json");
							trace(jsonString);
							trace("eval");
							trace(evalString);
							//how to import variable?
							//options[optionName]  = D.eval(evalString, {'jsonString':'{"cols":[{"id":"entrezgene_id","label":"entrezgene_id","type":"string"},{"id":"t_0h","label":"t_0h","type":"string"},{"id":"t_1h","label":"t_1h","type":"string"},{"id":"t_2h","label":"t_2h","type":"string"},{"id":"t_4h","label":"t_4h","type":"string"},{"id":"t_6h","label":"t_6h","type":"string"},{"id":"t_8h","label":"t_8h","type":"string"},{"id":"t_10h","label":"t_10h","type":"string"},{"id":"t_12h","label":"t_12h","type":"string"},{"id":"t_24h","label":"t_24h","type":"string"},{"id":"t_36h","label":"t_36h","type":"string"},{"id":"t_48h","label":"t_48h","type":"string"},{"id":"t_60h","label":"t_60h","type":"string"},{"id":"t_72h","label":"t_72h","type":"string"}],"rows":[{"c":[{"v":"10135","f":"10135"},{"v":"0.0748","f":"0.0748"},{"v":"0.1779","f":"0.1779"},{"v":"0.7904","f":"0.7904"},{"v":"1.1405","f":"1.1405"},{"v":"1.1264","f":"1.1264"},{"v":"0.9434","f":"0.9434"},{"v":"1.2299","f":"1.2299"},{"v":"0.8938","f":"0.8938"},{"v":"0.8302","f":"0.8302"},{"v":"0.7355","f":"0.7355"},{"v":"0.7307","f":"0.7307"},{"v":"0.7307","f":"0.7307"},{"v":"0.7307","f":"0.7307"}]},{"c":[{"v":"5720","f":"5720"},{"v":"0.3038","f":"0.3038"},{"v":"-0.0502","f":"-0.0502"},{"v":"0.152","f":"0.152"},{"v":"0.9552","f":"0.9552"},{"v":"1.6889","f":"1.6889"},{"v":"1.4225","f":"1.4225"},{"v":"1.498","f":"1.498"},{"v":"1.8243","f":"1.8243"},{"v":"1.8366","f":"1.8366"},{"v":"1.549","f":"1.549"},{"v":"1.2482","f":"1.2482"},{"v":"1.2482","f":"1.2482"},{"v":"1.2482","f":"1.2482"}]},{"c":[{"v":"7280","f":"7280"},{"v":"-0.5577","f":"-0.5577"},{"v":"0.2141","f":"0.2141"},{"v":"0.1379","f":"0.1379"},{"v":"-0.1233","f":"-0.1233"},{"v":"0.0604","f":"0.0604"},{"v":"-0.2534","f":"-0.2534"},{"v":"-0.071","f":"-0.071"},{"v":"0.3977","f":"0.3977"},{"v":"-0.1025","f":"-0.1025"},{"v":"0.0086","f":"0.0086"},{"v":"-0.0249","f":"-0.0249"},{"v":"-0.0249","f":"-0.0249"},{"v":"-0.0249","f":"-0.0249"}]},{"c":[{"v":"7706","f":"7706"},{"v":"-0.135","f":"-0.135"},{"v":"0.1437","f":"0.1437"},{"v":"0.508","f":"0.508"},{"v":"0.9174","f":"0.9174"},{"v":"0.6645","f":"0.6645"},{"v":"0.6173","f":"0.6173"},{"v":"0.587","f":"0.587"},{"v":"0.5667","f":"0.5667"},{"v":"0.5268","f":"0.5268"},{"v":"0.2692","f":"0.2692"},{"v":"0.208","f":"0.208"},{"v":"0.208","f":"0.208"},{"v":"0.208","f":"0.208"}]},{"c":[{"v":"7920","f":"7920"},{"v":"0.0238","f":"0.0238"},{"v":"-0.0379","f":"-0.0379"},{"v":"-0.0267","f":"-0.0267"},{"v":"0.3356","f":"0.3356"},{"v":"0.8071","f":"0.8071"},{"v":"0.6586","f":"0.6586"},{"v":"0.6327","f":"0.6327"},{"v":"0.553","f":"0.553"},{"v":"0.3027","f":"0.3027"},{"v":"0.1735","f":"0.1735"},{"v":"-0.0256","f":"-0.0256"},{"v":"-0.0256","f":"-0.0256"},{"v":"-0.0256","f":"-0.0256"}]},{"c":[{"v":"79751","f":"79751"},{"v":"0.0369","f":"0.0369"},{"v":"-0.1323","f":"-0.1323"},{"v":"-0.1204","f":"-0.1204"},{"v":"0.2025","f":"0.2025"},{"v":"0.2982","f":"0.2982"},{"v":"0.3421","f":"0.3421"},{"v":"0.5423","f":"0.5423"},{"v":"0.3364","f":"0.3364"},{"v":"0.4248","f":"0.4248"},{"v":"0.156","f":"0.156"},{"v":"0.1376","f":"0.1376"},{"v":"0.1376","f":"0.1376"},{"v":"0.1376","f":"0.1376"}]},{"c":[{"v":"837","f":"837"},{"v":"-0.3524","f":"-0.3524"},{"v":"-0.2201","f":"-0.2201"},{"v":"0.3905","f":"0.3905"},{"v":"1.5848","f":"1.5848"},{"v":"1.6004","f":"1.6004"},{"v":"1.6682","f":"1.6682"},{"v":"1.5415","f":"1.5415"},{"v":"1.734","f":"1.734"},{"v":"1.6517","f":"1.6517"},{"v":"2.1717","f":"2.1717"},{"v":"1.3875","f":"1.3875"},{"v":"1.3875","f":"1.3875"},{"v":"1.3875","f":"1.3875"}]},{"c":[{"v":"8519","f":"8519"},{"v":"0.1659","f":"0.1659"},{"v":"0.9716","f":"0.9716"},{"v":"2.2091","f":"2.2091"},{"v":"2.3547","f":"2.3547"},{"v":"2.7031","f":"2.7031"},{"v":"2.599","f":"2.599"},{"v":"2.8086","f":"2.8086"},{"v":"2.8297","f":"2.8297"},{"v":"1.8521","f":"1.8521"},{"v":"0.9826","f":"0.9826"},{"v":"1.6282","f":"1.6282"},{"v":"1.6282","f":"1.6282"},{"v":"1.6282","f":"1.6282"}]},{"c":[{"v":"8764","f":"8764"},{"v":"-0.0231","f":"-0.0231"},{"v":"-0.105","f":"-0.105"},{"v":"-0.1957","f":"-0.1957"},{"v":"0.3898","f":"0.3898"},{"v":"-0.1125","f":"-0.1125"},{"v":"0.6697","f":"0.6697"},{"v":"0.185","f":"0.185"},{"v":"0.5053","f":"0.5053"},{"v":"0.2657","f":"0.2657"},{"v":"0.2686","f":"0.2686"},{"v":"0.408","f":"0.408"},{"v":"0.408","f":"0.408"},{"v":"0.408","f":"0.408"}]},{"c":[{"v":"9246","f":"9246"},{"v":"0.4272","f":"0.4272"},{"v":"0.2992","f":"0.2992"},{"v":"0.8659","f":"0.8659"},{"v":"1.5975","f":"1.5975"},{"v":"2.1512","f":"2.1512"},{"v":"2.1465","f":"2.1465"},{"v":"2.3196","f":"2.3196"},{"v":"2.1708","f":"2.1708"},{"v":"1.7027","f":"1.7027"},{"v":"1.4103","f":"1.4103"},{"v":"1.3783","f":"1.3783"},{"v":"1.3783","f":"1.3783"},{"v":"1.3783","f":"1.3783"}]}]}'}) as NodeDataView;
							options[optionName]  = D.eval(evalString, {'jsonString':jsonString});
							//options[optionName] = D.eval('new NodeDataView(jsonString, "")') as NodeDataView;
						}
					}
					else if(parseAs=="bundle"){
							trace("ELSE");
							trace("option name");
							trace(optionName);
							options[optionName] = new DataView(JSON.encode(options[optionName]),"");
					}
					//param
					else{
						continue;
					}
			}
			trace("RETURN");
			return options;
		}
		protected function parseUpdatedOptions(newOptions:Object, optionsListObject:Object, currentOptions:Object) : Object {
			var changed:Object = new Object();
			//for(var optionName : String in optionsListObject){
			for(var optionName : String in newOptions){
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
						trace(optionName);
						trace(newOptions[optionName]);
						trace(currentOptions[optionName]);
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