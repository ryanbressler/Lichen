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
	
	import flare.display.TextSprite;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.legend.Legend;
	
	import flash.events.MouseEvent;
	import flash.external.*;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.utils.*;
	
	import org.systemsbiology.visualization.GoogleVisAPISprite;
	import org.systemsbiology.visualization.bionetwork.*;
	import org.systemsbiology.visualization.bionetwork.data.Network;
	import org.systemsbiology.visualization.bionetwork.display.tooltip;
	import org.systemsbiology.visualization.bionetwork.layout.*;
	import org.systemsbiology.visualization.control.ClickDragControl;
	import org.systemsbiology.visualization.data.DataView;
	import org.systemsbiology.visualization.data.GraphDataView;
	import org.systemsbiology.visualization.data.LayoutDataView;
	import org.systemsbiology.visualization.data.NodeDataView;
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
		private var layoutTable:LayoutDataView;
		private var nodeDataTable:NodeDataView;
		private var tempTable:DataView;
		private var layoutType:String;
		private var dataTable:DataView;
		private var graphTable:GraphDataView;
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
		private var update:Boolean;

		
		
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
       //obj holding configuration options
       //maybe this object should store defaults too?
        private var optionsListObject : Object = {
/*<<<<<<< HEAD:src/bionetwork.as
        	layout_data:{parseAs:"dataTable", affects:["layout"]},
        	node_data:{parseAs:"dataTable", affects: ["nodes"]},
        	nodeClusters:{parseAs:"dataTable", affects: ["layout"]},
        	nodeClusterPositions:{parseAs:"param", affects: ["layout"]},
        	attributes:{parseAs:"dataTable", affects: ["nodes", "edges", "layout"]},
        	clickdrag:{parseAs:"param", affects: ["nodes"]},
        	sproutable:{parseAs:"param", affects: ["nodes"]},
        	legend:{parseAs:"bundle", affects:[]},
        	layout_type: {parseAs:"param", affects:["layout"]},
        	CircularHeatmap:{parseAs:"bundle", affects:["nodes"]},
        	MultiEdge:{parseAs:"bundle", affects:["edges"]}, //needs to be bundle so you can assign colors to sourcenames?
        	padding:{parseAs:"param", affects:["workspace"]},
        	width:{parseAs:"param", affects:["workspace"]},
        	height:{parseAs:"param", affects:["workspace"]},
        	legend:{parseAs:"bundle", affects: []},
        	node_fillColor:{parseAs:"color", affects:["nodes"]},
        	node_lineWidth:{parseAs:"param", affects:["nodes"]},
        	node_tooltips:{parseAs:"param", affects:["nodes"]},
        	edge_lineWidth:{parseAs:"param", affects:["edges"]},
        	edge_lineColor:{parseAs:"param", affects:["edges"]},
        	edge_router:{parseAs:"param", affects:["edges"]},
        	selection_display:{parseAs:"param", affects:["all"]}, //this is tricky b/c the value determines what if affects
        	selection_persistDisplay:{parseAs:"param", affects:[]},
        	selection_lineColor:{parseAs:"param", affects: []},
        	selection_lineWdith:{parseAs:"param", affects:[]},
        	selection_lineAlpha:{parseAs:"param", affects:[]},
       		events: {parseAs:"bundle", affects:[]}
=======*/
		nodeClusters:{parseAs:"dataTable", affects: ["layout"]},
        nodeClusterPositions:{parseAs:"param", affects: ["layout"]},
        layout_data:{parseAs:"dataTable", affects:["layout"], classname:"LayoutDataView"},
        node_data:{parseAs:"dataTable", affects: ["nodes"], classname:"NodeDataView"},
        graph_data:{parseAs:"dataTable", affects:["layout","edges"],classname:"GraphDataView"},
        layout_url:{parseAs:"dataTable", affects: ["nodes", "edges", "layout"]},
        attributes:{parseAs:"dataTable", affects: ["nodes", "edges", "layout"]},
        clickdrag:{parseAs:"param", affects: ["nodes"]},
        sproutable:{parseAs:"param", affects: ["nodes"]},
        //should become bundle
        legend:{parseAs:"param", affects:[]},
        layout_type: {parseAs:"param", affects:["layout"]},
        layout: {parseAs:"param", affects:["layout"]},
        CircularHeatmap:{parseAs:"bundle", affects:["nodes"]},
        nodeRenderer:{parseAs:"param", affects:["nodes"]},
        edgeRenderer:{parseAs:"param", affects:["edges"]},
        center:{parseAs:"param", affects:["layout"]},
        MultiEdge:{parseAs:"bundle", affects:["edges"]}, //needs to be bundle so you can assign colors to sourcenames?
        padding:{parseAs:"param", affects:["stage"]},
        width:{parseAs:"param", affects:["stage"]},
        height:{parseAs:"param", affects:["stage"]},
        node_fillColor:{parseAs:"color", affects:["nodes"]},
        node_lineWidth:{parseAs:"param", affects:["nodes"]},
        node_tooltips:{parseAs:"param", affects:["nodes"]},
        edge_lineWidth:{parseAs:"param", affects:["edges"]},
        edge_lineColor:{parseAs:"param", affects:["edges"]},
        edge_router:{parseAs:"param", affects:["edges"]},
        selection_display:{parseAs:"param", affects:[]}, //this is tricky b/c the value determines what if affects
        selection_persistDisplay:{parseAs:"param", affects:[]},
        selection_lineColor:{parseAs:"param", affects: []},
        selection_lineWdith:{parseAs:"param", affects:[]},
        selection_lineAlpha:{parseAs:"param", affects:[]},
       events: {parseAs:"bundle", affects:[]},
       maxval: {parseAs:"param", affects:["nodes"]},
       minval: {parseAs:"param", affects:["nodes"]}
        };

	//for basic network	
	public function bionetwork() {
		var relayout : Function = function () : void { draw("","{\"updateObj\":{\"layout\" : true, \"nodes\": true,\"edges\": true,\"stage\": true}}"); };
		ExternalInterface.addCallback("add_edge_from_to", function(n1:String,n2:String) : void { 
				network.add_edge_by_names(n1,n2);
				relayout();
			});
		ExternalInterface.addCallback("remove_node_by_name", function(n1:String) : void { 
				network.remove_node(n1);
				relayout();
			});
		ExternalInterface.addCallback("remove_edge_from_to", function(n1:String,n2:String) : void { 
				network.remove_edge(n1,n2);
				relayout();
			});
		super();
			
	}
	// draw!
	public override function draw(dataJSON:String, optionsJSON:String) :void {            			
		
		//import data
		this.options ||= new Object();
		var newoptions : Object = this.parseOptions(optionsJSON as String,optionsListObject);
		for( var name : String in newoptions)
			this.options[name] = newoptions[name];

		//TO DO: Make the way DataViews are created consistent
		if (dataJSON!=''){
			this.graphTable = new GraphDataView(dataJSON, "");
			this.network.bind_data(this.graphTable);
			this.options.updateObj.layout = true;
			this.options.updateObj.nodes = true;
			this.options.updateObj.edges = true;
			this.options.updateObj.stage = true;
		}

		this.layoutTable = this.options['layout_data'] as LayoutDataView|| null;
		this.nodeDataTable = this.options['node_data'] || null;


		if (this.layoutTable!=null){
			this.network.bind_data(this.layoutTable);
		}
		if (this.nodeDataTable!=null){
			trace("calling bind_data");
			//this.importTimeCourseData(this.nodeDataTable);
			this.network.bind_data(this.nodeDataTable);
		}

		
		if(this.options.updateObj.stage)
			this.resizeStage(visindex, options);

		//position the nodes
		if(this.options.updateObj.layout)	
			layoutController.performLayout(network, options);
		//determine the edge appearance (this has to be after the layout or the bundled edge thing will crash)
		if(this.options.updateObj.edges)
			edgeController.styleEdges(network,options);
		//determine the node appearance
		if(this.options.updateObj.nodes)
			nodeController.styleNodes(network,options);
		
		_setSelectionListeners();
		
		//add optional controls and legend
		if (options.node_tooltips){
			tooltip.addNodeTooltips(network);
		}
		if (options['clickdrag']!=false){
			var cdc:ClickDragControl = new ClickDragControl(NodeSprite,1,true);
			this.network.controls.add(cdc);
		}
		if (this.options['legend'] && this.options['legend']!='false' ){
			this.createLegend();
		}

		addChild(this.network);
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
	
	private function importTimeCourseData(nodeDataTable:DataView):void{
		//var data = {};
		var data:Array = new Array();
		for (var i:Number = 0; i<nodeDataTable.getNumberOfRows();i++) {
			//first column name
			var interactor_name:String = nodeDataTable.getValue(i,0);
			for (var j:Number = 1; j < nodeDataTable.getNumberOfColumns(); j++){
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
	protected function _setSelectionListeners() :void{
		for (var i:Number = 0; i<this.network.data.nodes.length; i++){
			var node:NodeSprite = this.network.data.nodes[i];

			node.addEventListener(MouseEvent.CLICK,this._selectionHandeler);

			if(!node.props.islabel)
				_appendSelectionInfo(node,{node:node.data.name});
					

		}
		
		for (var i:Number=0; i<this.network.data.edges.length; i++){
			var edge:EdgeSprite = this.network.data.edges[i];
			edge.addEventListener(MouseEvent.CLICK,this._selectionHandeler);
			_appendSelectionInfo(edge,{row:i});
		}
	}
	
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
			if(ds.props.hasOwnProperty("deselect"))
				return;
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

//	private function getTransitioner(taskname:String,duration:Number=1,easing:Function=null,optimize: Boolean = false):Transitioner {
//                
//		if (_trans[taskname] != null) {  //here we could also check for running but disposing never harms ...        
//	        _trans[taskname].stop();
//	        _trans[taskname].dispose();
//	    }               
//		    _trans[taskname] = new Transitioner(duration,easing,optimize);
//		    return _trans[taskname];
//		}

		// calculates the size of the visualization from the data and options
		// then resizes the container element via javascript
	private function resizeStage(visindex:String, options:Object) :void {
     	//calculate width and height ...			
     	var width:int = options.width || 630;
     	var height:int = options.height || 630;
     	var padding:int = options.padding || 5;
     	this.resizeContainer(width,height);         	
		this.network.bounds = new Rectangle(padding, padding, width-2*padding, height-2*padding);
	}
		
	
	}
}
