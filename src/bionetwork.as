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

package {
	import com.adobe.serialization.json.JSON;
	
	import flare.animate.Transitioner;
	import flare.display.TextSprite;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.legend.Legend;
	import flare.vis.operator.label.Labeler;
	
	import flash.events.MouseEvent;
	import flash.external.*;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.utils.*;
	
	import org.systemsbiology.visualization.GoogleVisAPISprite;
	import org.systemsbiology.visualization.bionetwork.data.Network;
	import org.systemsbiology.visualization.bionetwork.display.tooltip;
	import org.systemsbiology.visualization.bionetwork.layout.*;
	import org.systemsbiology.visualization.bionetwork.layoutControler;
	import org.systemsbiology.visualization.control.ClickDragControl;
	import org.systemsbiology.visualization.data.DataView;
	import org.systemsbiology.visualization.bionetwork.display.tooltip;
	//This class is primarily responsible for configuring the network from the data in Google data tables and options passed in from the view.
	//for now, updates cause the sprite to be redrawn completely. The data update is sort of smart (appends to data table rather than rewriting).
	//the network object persists the data
	public class bionetwork extends GoogleVisAPISprite
	{	
		private var data:Data = new Data();
		private var network:Network = new Network(data);		
		//config variables
		private var options:Object; 
		private var centerNode:int;
		private var layoutTable:DataView;
		private var nodeDataTable:DataView;
		private var tempTable:DataView;
		private var layoutType:String;
		private var dataTable:DataView;
		private var attributesTable:DataView;
		private var visWidth:int = stage.stageWidth;
		private var visHeight:int = stage.stageHeight;
		private var vis:Visualization;
		private var _fmt:TextFormat = new TextFormat("Verdana", 14);
		private var _detail:TextSprite;
		private var maxLabelWidth:Number;
		private var maxLabelHeight:Number;
		private var _trans:Object = {};
		private var _nodes:Array;
		private var regularColor:uint = 0xff0000ff;
		private var rootColor:uint = 0xffff0000;
		private var frameSize:int=40;
		private var lastRoot:NodeSprite = null;
		private var info1:TextSprite;
		private var info2:TextSprite;
		private var legend:Legend;
		
		
		//font
        // We must embed a font so that we can rotate text and do other special effects
           [Embed(systemFont='Helvetica', 
            fontName='myHelveticaFont', 
            mimeType='application/x-font'
        )] 
        // You do not use this variable directly. It exists so that 
        // the compiler will link in the font.
        private var _font1:Class;
        private var _fontHeight:int = 14;                
        private var  _labelTextFormat : TextFormat = new TextFormat('myHelveticaFont',14);

	//for basic network	
	public function bionetwork() {
		
		super();	
	}

			
		//de-serialize
	private function importFromJSON(dataJSON:String, optionsJSON:String) :void {						
		this.options = JSON.decode(optionsJSON);
		this.layoutType = this.options['layout'];	
		this.centerNode=this.options['center'];	
		
		//data tables
		//import data JSON
		if (this.dataTable!=null){
			//loop through datatable and add rows; does the table need to be updated?
			this.tempTable = new DataView(dataJSON, "");
			this.constructGraph(this.tempTable);
		}
		else {
			this.dataTable = new DataView(dataJSON, "");
		}
		
		if (this.options['layout_data']){				
			this.layoutTable = new DataView(JSON.encode(this.options['layout_data']),"");
		}
		else{
			this.layoutTable=null;
		}
		
		if (this.options['node_data']){				
			this.nodeDataTable = new DataView(JSON.encode(this.options['node_data']),"");
		}
		else{
			this.nodeDataTable=null;
		}
		
		if (this.options['attributes']){
			//already exist
			if (this.attributesTable!=null){
				
			}
			else {
				this.attributesTable = new DataView(JSON.encode(this.options['attributes']), "");
			}	
		}
		else{
			this.attributesTable=null;
		}
        this.resizeStage(visindex, dataTable, options);
               
	}



		// draw!
	public override function draw(dataJSON:String, optionsJSON:String) :void {            			
		this.importFromJSON(dataJSON, optionsJSON);
		this.resizeStage(visindex, this.dataTable, options);
		this.constructGraph(this.dataTable);

		trace("LAYOUT DATA");
		//layout from layoutTable
		if (this.layoutTable!=null){
			this.importLayout(this.layoutTable);
		}		
		
		if (this.nodeDataTable!=null){
			this.importTimeCourseData(this.nodeDataTable);
		}
		if(options.node_tooltips)
			tooltip.addNodeTooltips(network);	
		layoutControler.performLayout(network,options);
		
		if (options['clickdrag']!=false){
			var cdc:ClickDragControl = new ClickDragControl(NodeSprite,1,true);
			this.network.controls.add(cdc);
		}
		this.setLabels();
        this.network.x = 0;
        this.network.y = 0;
		
		if (this.options['legend'] && this.options['legend']!='false' ){
			this.createLegend();
		}
		addChild(this.network);
		trace("update network sprite");
		this.network.update();
}	
	private function createLegend():void {
		var legend_fmt:TextFormat = new TextFormat("Verdana",14);
		legend = Legend.fromValues(null, options.legend_values || [
				{color: 0x3366CC, size: 0.75, label: "HPRD"},
				{color: 0x339900, size: 0.75, label: "MINT"},
				{color: 0xA2627A, size: 0.75, label: "IntAct"},
				{color: 0xFF6600, size: 0.75, label: "MIPS"},
				{color: 0xFF0000, size: 0.75, label: "BioGRID"}
			]);
			legend.labelTextFormat = legend_fmt;
			//legend.labelTextMode = TextSprite.EMBED;
			legend.update();
			addChild(legend);
	}

	//DATA IMPORT FUNCTIONS

	private function constructGraph(dataTable:DataView):void {
		trace("construct graph");
		var interactor_name1:String;
		var interactor_value1:String;
		var interactor_name2:String;
		var interactor_value2:String;
		var interactor1:NodeSprite;
		var interactor2:NodeSprite;
		var ixnsources:Array;
		var edge:EdgeSprite;
		var directed:Boolean=false;	
		for (var i:Number = 0; i<dataTable.getNumberOfRows(); i++) {
			interactor_name1=dataTable.getFormattedValue(i,1);
			trace("formatted_name1" + interactor_name1);
			interactor_value1=dataTable.getValue(i,1);
			trace("value1" + interactor_value1);
			interactor_name2=dataTable.getFormattedValue(i,2);
			interactor_value2=dataTable.getValue(i,2);
			
		if (interactor_value1==interactor_value2){
			continue;
		}
			//for other columns
			trace(dataTable.getNumberOfColumns());
//			if (dataTable.getNumberOfColumns()>2){
				for(var j:Number=3; j<dataTable.getNumberOfColumns(); j++){
					var cellValue:String = dataTable.getValue(i,j);
					trace("Cell" + cellValue);
					var columnName:String = dataTable.getColumnLabel(j);
					if (columnName=='sources'){
						trace("SOURCES");
						ixnsources=cellValue.split(", ");
					}
					else if (columnName=='directed'){
						directed = Boolean(cellValue=='true');
						trace("dir:" + directed);
					}
				//}
			}
			
			//this section replace network.addnodeifnotexsistant calls
			//i needed to be able to do things to nodes once on creation for selection stuff
			//
			//
			var interactors : Array = new Array();
			for each(var name : * in [interactor_name1 || interactor_value1,interactor_name2 || interactor_value2])
			{	
				if (!network.checkNode(name)){
					trace("create");
					var interactor : NodeSprite = network.addNode({name:name});
					//things that need to be done to each node once
					interactor.addEventListener(MouseEvent.CLICK,this._selectionHandeler);
					_appendSelectionInfo(interactor,{node:name});					
					interactors.push(interactor);
				}
				else{
					interactors.push(network.findNodeByName(name));
				}
				
			}
			interactor1 = interactors[0];
			interactor2 = interactors[1];
			
					
			edge=this.network.addEdgeIfNotExist(interactor1, interactor2, directed);
			_addSelectionCapabilities(edge,interactor1,interactor2,i);
			//loop through ixn sources
			if (ixnsources){
				for (var k:Number=0; k<ixnsources.length; k++){
					this.network.addEdgeSource(edge, ixnsources[k]);
				}
			}
			
		
		}
		if(options.center)
		{
			this.data.root = network.findNodeByName(options.center);
		}
	}

    private function importLayout(layoutTable:DataView):void {
    	var layoutValues:Array = new Array();
    	var layoutAttributeValue:String;
    	var params:Object = {};
   		for (var i:Number = 0; i<layoutTable.getNumberOfRows();i++) {
			//first column name
			var interactor_name:String = layoutTable.getValue(i,0);
			//rest of columns layout attributes (first two are x,y)
			for (var j:Number = 1; j < layoutTable.getNumberOfColumns(); j++){
				var columnName:String = layoutTable.getColumnLabel(j);
				layoutAttributeValue = layoutTable.getValue(i,j);
				//branch to set main nodesprite properties
				if (columnName=='shape'){
					this.network.setNodeShape(interactor_name, layoutAttributeValue);
				}
				else if (columnName == 'color'){
					this.network.setNodeColor(interactor_name, layoutAttributeValue);
				}
				else if (columnName == 'size'){
					this.network.setNodeSize(interactor_name, int(layoutAttributeValue));
				}
				else {
					params[columnName]=int(layoutAttributeValue);
					this.network.updateNodeParams(interactor_name,params);
				}
			}	
		}
    }
	
	private function importTimeCourseData(nodeDataTable:DataView):void{
		trace("IMPORT_TIME_COURSE_DATA");
		//var data = {};
		var data:Array = new Array();
		for (var i:Number = 0; i<nodeDataTable.getNumberOfRows();i++) {
			//first column name
			var interactor_name:String = nodeDataTable.getValue(i,0);
			for (var j:Number = 1; j < nodeDataTable.getNumberOfColumns(); j++){
				trace(nodeDataTable.getColumnLabel(j));
				//data[nodeDataTable.getColumnLabel(j)]=nodeDataTable.getValue(i,j);
				//data[nodeDataTable.getColumnLabel(j).match(/t_(\d*)/)[1]]=nodeDataTable.getValue(i,j);
				data.push({index: nodeDataTable.getColumnLabel(j).match(/t_(\d*)/)[1], value: nodeDataTable.getValue(i,j)});
			}
			this.network.setTimecourseData(interactor_name, data);
			data=[]
		}
	}
	
	//Currently written specifically for GO
	private function importAnnotations(annotationTable:DataView):void{
		var columnName:String;
		var attributeValue:String;
		if (annotationTable!=null){
			for (var i:Number = 0; i<annotationTable.getNumberOfRows(); i++) {
				var interactor_name:String = annotationTable.getFormattedValue(i,0);
				var annotation_id:String = annotationTable.getValue(i,1);
				var annotation_name:String = annotationTable.getValue(i,2);
				this.network.addAnnotation(interactor_name, annotation_name);
			}
		}
	}
	
	/////////////////////////////////////////////////////////////////////////
	// selection functions
	
	//over ride functions to add node selection capabilities
	//fired by mouse click
	
	protected override function _selectionHandeler(eventObject: MouseEvent): void {
		if(eventObject.currentTarget is NodeSprite)
		{
			var ns : NodeSprite = eventObject.currentTarget as NodeSprite;
			
			this._bubbleEvent("nodeclick",{node:{name:ns.data.name}});
		}
		if(eventObject.currentTarget is EdgeSprite)
		{
			var es : EdgeSprite = eventObject.currentTarget as EdgeSprite;
			this._bubbleEvent("edgeclick",{edge:{}}); //TODO: put something in here
		}
		
		super._selectionHandeler(eventObject);
	}
	
	private function _addSelectionCapabilities(edge:EdgeSprite, interactor1 :NodeSprite, interactor2:NodeSprite, i:int) : void
	{
		edge.addEventListener(MouseEvent.CLICK,this._selectionHandeler);
		_appendSelectionInfo(edge,{row:i});
	
	}
	
	private function _appendSelectionInfo(ds:DataSprite,selection : Object) : void
	{
		if(ds.props.hasOwnProperty("selection"))
		{
			ds.props.selection.push(selection);
		}
		else
		{
			ds.props.selection = [selection];
		}
	}
	
	private function addNodeSelectionInfo (ns:NodeSprite):Boolean {
		_appendSelectionInfo(ns,{node:ns.name});
		return true;
		}
	
	private function addSelectListener (ds:DataSprite):Boolean {
		ds.addEventListener(MouseEvent.CLICK,this._selectionHandeler); 
		return true;
		}
	
			
	///////////////////////////////////////////////////////
	//Selection display functions
	
	//handle nodes in the incoming selection from js
	public override function selectionSetViaJS(selection : String) : void 
		{
			//TODO: clear selections
	    	super.selectionSetViaJS(selection);
	    	//decode
	    	var selectionArray : Array = JSON.decode(selection) as Array;
	    	
	    	for each (var selectionObj : Object in selectionArray)
	    	{
		    	
		    	if( selectionObj.hasOwnProperty("node"))
		    	{
		    		this._setSelectionNode(selectionObj.node);
		    		continue;	
		    	}
	    	}
	    	if (options.hasOwnProperty("selection_persistDisplay") && !options.selection_persistDisplay) setTimeout(_clearSelectionDisplay, 500);  		
	    }
	    
	protected override function _clearSelectionDisplay() : void{
			this.network.data.visit(
				function(ds:DataSprite):void{ 
					if(ds.props.hasOwnProperty("deselect")) {
						ds.props.deselect();
						delete(ds.props.deselect);
						}
					}
				);
		}
	    
	protected override function _setSelectionRow(row : *) : void {
			var name1 : String = dataTable.getFormattedValue(row as int,1) || dataTable.getValue(row as int,1);
			var name2 : String = dataTable.getFormattedValue(row as int,2) || dataTable.getValue(row as int,2);
			var es : EdgeSprite = network.findEdgeByNodes(name1,name2);
		    
			if(!options.selection_display || (options.selection_display != "none" || options.selection_display != "nodes"))
			_doSelectionDisplay(es as DataSprite);
			
	    }
	
	protected function _setSelectionNode(nodeName : *) : void {
			var ns : NodeSprite = this.network.findNodeByName(nodeName);
			if(!options.selection_display || (options.selection_display != "none" || options.selection_display != "edges"))
			_doSelectionDisplay(ns as DataSprite);
			
			}
	    
	protected function _doSelectionDisplay(ds : DataSprite) : void
		{
			//var fillColor : uint = ds.fillColor;
			//var fillAlpha ds.fillAlpha;
			var lineColor : Number = ds.lineColor;
			var lineWidth : Number = ds.lineWidth;
			var lineAlpha : Number = ds.lineAlpha;
			
			
			ds.props.deselect = function():void{
				ds.lineColor = lineColor;
				ds.lineWidth = lineWidth;
				ds.lineAlpha = lineAlpha;
			};
			ds.lineColor = options.selection_lineColor || lineColor;
			ds.lineWidth = options.selection_lineWidth || 3;
			ds.lineAlpha = options.selection_lineAlpha || 1;
		}

	

	private function setLabels():void {
			var labeller:Labeler = new Labeler(function(d:DataSprite):String {
		return String(d.data.name);
		});
		labeller.yOffset=15;
		labeller.xOffset=5;
		this.network.operators.add(labeller);
	}
	
	private function getTransitioner(taskname:String,duration:Number=1,easing:Function=null,optimize: Boolean = false):Transitioner {
                
		if (_trans[taskname] != null) {    //here we could also check for running but disposing never harms ...        
	        _trans[taskname].stop();
	        _trans[taskname].dispose();
	    }               
		    _trans[taskname] = new Transitioner(duration,easing,optimize);
		    return _trans[taskname];
		}

		// calculates the size of the visualization from the data and options
		// then resizes the container element via javascript
		
	private function resizeStage(visindex:String, dataTable:DataView, options:Object) :void {
     	//calculate width and height ...			
     	var width:int = options.width || 630;
     	var height:int = options.height || 630;
     	var padding:int = options.padding || 5;
     	
     	this.resizeContainer(width,height);         	
		this.network.bounds = new Rectangle(padding, padding, width-2*padding, height-2*padding);

	}
		
	
	}
}
