package {
	import com.adobe.serialization.json.JSON;
	
	import flare.animate.Pause;
	import flare.animate.Sequence;
	import flare.animate.Transitioner;
	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.events.SelectionEvent;
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.layout.ForceDirectedLayout;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.*;
	import flash.geom.Rectangle;
	import flash.text.*;
	
	import org.systemsbiology.visualization.bionetwork.data.Network;
	import org.systemsbiology.visualization.bionetwork.display.MultiEdgeRenderer;
	import org.systemsbiology.visualization.bionetwork.layout.*;
	import org.systemsbiology.visualization.control.ClickDragControl;
	import org.systemsbiology.visualization.data.DataView;
	public class bionetwork extends Sprite
	{	
		private var data:Data = new Data();
		private var network:Network = new Network(data);		
		//config variables
		private var options:Object; 
		private var centerNode:int;
		private var layout:DataView;
		private var containerId:String;
		private var dataTable:DataView
		private var attributes:DataView;
		private var visWidth:int = stage.stageWidth;
		private var visHeight:int = stage.stageHeight;
		private var vis:Visualization;
		private var _fmt:TextFormat = new TextFormat("Verdana", 14);
		private var _detail:TextSprite;
		private var maxLabelWidth:Number;
		private var maxLabelHeight:Number;
		private var _trans:Object = { };
		private var _nodes:Array;
		private var regularColor:uint = 0xff0000ff;
		private var rootColor:uint = 0xffff0000;
		private var frameSize:int=40;
		private var lastRoot:NodeSprite = null;
		private var info1:TextSprite;
		private var info2:TextSprite;
		
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
		this.containerId = root.loaderInfo.parameters.flashvarsId;
		//ensure that coordinate system remians centered at upper left even after resize
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.addEventListener(Event.ACTIVATE, activateHandler);
        ExternalInterface.addCallback("draw", draw);
        ExternalInterface.addCallback("redraw", redraw);		
        //ExternalInterface.addCallback("update_data", update_data);		
		var callJas:String = "isbSWFvisualizations."+this.containerId+".bioheatmapFlashReady";
		ExternalInterface.call(callJas);
		trace("Vis Initalized");		
	}
		
	//for sprouting
	public function redraw(dataJSON:String, optionsJSON:String) :void {			
//			var newDataTable:DataView;
//			trace("REDRAW");
//			trace(this.map);
//			trace(this.centerNode);
//			trace(dataJSON);
//			trace(optionsJSON);
//			this.datat = JSON.decode(dataJSON);
//			this.options = JSON.decode(optionsJSON);	
////			this.centerNode=this.options['center'];
//			this.dataFormat=this.options['data_format'];
//			if (this.dataFormat=='static'){
//				trace("static");
//				dataTable = new DataView(JSON.encode(this.datat), "False");
//			}
//			else{
//				trace("google");
//				dataTable = new DataView(JSON.encode(this.datat), "True");
//			}
//			trace("attribute encoding");
//			//need to loop through datatable to see what already exists, currently writes over data
//			this.attributes = new DataView(JSON.encode(this.options['attributes']), "False");
//            this.resizeStage(containerId, dataTable, options);
//            drawAfterResize(dataTable,{},{});         
		}
			
		//basic graph drawing
	public function draw(dataJSON:String, optionsJSON:String) :void {						
		trace("DATAJSON: " + dataJSON);	
		this.options = JSON.decode(optionsJSON);	
		this.centerNode=this.options['center'];	
		var layoutValues:Array = new Array();
		
		if (this.options['layout_data']){			
			trace("test layout");	
			trace(this.options['layout_data']);
//					this.dataTable = new DataView(dataJSON, "");
			//need to change and mak
			trace(options['layout_data']);
			this.layout = new DataView(JSON.encode(this.options['layout_data']),"");
		}
		else{
			this.layout=null;
		}

		this.dataTable = new DataView(dataJSON, "");
		trace("Test data table");
		trace(this.dataTable);

		if (this.options['attributes']){
			this.attributes = new DataView(JSON.encode(this.options['attributes']), "True");	
		}
		else{
			this.attributes=null;
		}
		
        this.resizeStage(containerId, dataTable, options);
        drawAfterResize(this.dataTable, this.attributes, this.layout);         
	}

	//redraw without loading new data
	private function updateLayoutParams():void{
		
	}
	
//	public function update_data(testString:String):void {
//		trace("update_data");
//		ExternalInterface.call("update_data");
//		showText(info1,"update",0xff0000);
//	}

		// draw!
	private function drawAfterResize(dataTable:DataView, attributeTable:*=null, layoutTable:*=null) :void {            			

		trace("draw after resize");	
		var interactor_name1:String;
		var interactor_value1:String;
		var interactor_name2:String;
		var interactor_value2:String;
		var interactor1:NodeSprite;
		var interactor2:NodeSprite;
		var ixnsources:Array;
		var edge:EdgeSprite;
		trace("EDGE DATA");
		for (var i:Number = 0; i<dataTable.getNumberOfRows(); i++) {
			interactor_name1=dataTable.getFormattedValue(i,1);
			trace("formatted_name1" + interactor_name1);
			interactor_value1=dataTable.getValue(i,1);
			trace("formatted_value1" + interactor_value1);
			interactor_name2=dataTable.getFormattedValue(i,2);
			interactor_value2=dataTable.getValue(i,2);
			trace(dataTable.getValue(i,3));
			ixnsources = dataTable.getValue(i,3).split(", ");
			trace("IXN_SOURCES" + ixnsources[0]);	
			interactor1=this.network.addNodeIfNotExist(interactor_value1);
			interactor2=this.network.addNodeIfNotExist(interactor_value2);			
			edge=this.network.addEdgeIfNotExist(interactor1, interactor2);
			//this.network.addEdge(interactor1, interactor2);
			trace("length" + ixnsources.length);
			for (var j:Number=0; j<ixnsources.length; j++){
				trace("j" + j);
				this.network.addEdgeSource(edge, ixnsources[j]);
			}		
		}
		
		var params:Object = {};
		trace("LAYOUT DATA");
		//layout from layoutTable
		if (layoutTable!=null){
			for (var i:Number = 0; i<layoutTable.getNumberOfRows(); i++) {
				//first column name
				var interactor_name:String = layoutTable.getValue(i,0);
				//rest of columns layout attributes (first two are x,y)
				for (var j:Number = 1; j < layoutTable.getNumberOfColumns(); j++){
					var columnName:String = layoutTable.getColumnLabel(j);
					var layoutAttributeValue:String = layoutTable.getValue(i,j);
					trace(columnName + layoutAttributeValue);
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
			
		//attributes-user defined node params
		if (attributeTable!=null){
			trace("attributes");
			for (var i:Number = 0; i<attributeTable.getNumberOfRows(); i++) {
				var interactor_name:String = attributeTable.getFormattedValue(i,0);
				for (var j:Number = 1; j < attributeTable.getNumberOfColumns(); j++){
					var columnName:String = layoutTable.getColumnLabel(j);
					var attributeValue:int = layoutTable.getValue(i,j);
					params[columnName]=attributeValue;
					this.network.updateNodeParams(interactor_name,params);
				}
			}
		}

		
		//set defaults
		this.network.data.nodes.setProperties({fillColor:0xff0055cc, fillAlpha: 0.2, lineWidth:0.5, visible:true});     
		//this.network.data.nodes.setProperties({renderer: CircularHeatmapRenderer.instance});
		//var lay:CircleLayout =  new CircleLayout(null, null, false);
		//var lay:GoogleDataTableDrivenLayout = new GoogleDataTableDrivenLayout();
		if (this.options['layout']=="ForceDirected"){
			this.network.data.nodes.setProperties({x:315, y:315});     	
	    	this.network.continuousUpdates = true;
	    	//force directed layout
			var lay:ForceDirectedLayout = new ForceDirectedLayout(true,120);
	    	lay.simulation.dragForce.drag=1;
	    	lay.simulation.nbodyForce.gravitation=-128;  
	        lay.defaultParticleMass= 6;
	        lay.defaultSpringLength=100;
	        lay.defaultSpringTension= 0.1;
	        this.network.operators.add(lay);
		
		}
		else{
		
			var lay2:GoogleDataTableDrivenLayout = new GoogleDataTableDrivenLayout();
			this.network.operators.add(lay2);
		}
		
		
		this.network.data.edges.setProperties({
			lineWidth: 0.5,
			lineAlpha: 1,
			lineColor: 0xff0000bb,
			mouseEnabled: true,
			visible:true,
			renderer: MultiEdgeRenderer.instance
		});
			var cdc:ClickDragControl = new ClickDragControl(NodeSprite,1,true);
//			cdc.addEventListener(SelectionEvent.SELECT,onSingleClick);
//			cdc.addEventListener(SelectionEvent.DESELECT, onSingleClickDeselect);
//		
//		//this.network.data.nodes.setProperties({renderer: CircularHeatmapRenderer.instance});
//		//var lay:CircleLayout =  new CircleLayout(null, null, false);
//		//var lay:GoogleDataTableDrivenLayout = new GoogleDataTableDrivenLayout();
//		if (this.options['layout']=="ForceDirected"){
//			this.network.data.nodes.setProperties({x:315, y:315});     	
//	    	this.network.continuousUpdates = true;
//	    	//force directed layout
//	    	var lay:ForceDirectedLayout = new ForceDirectedLayout(true,1);
//	    	lay.simulation.dragForce.drag= 4;
//	    	lay.simulation.nbodyForce.gravitation=-128;  
//	        lay.defaultParticleMass= 16;
//	        lay.defaultSpringLength= 120;
//	        lay.defaultSpringTension= .1;
//	        this.network.operators.add(lay);
//		
//		}
//		else{
//			var lay2:GoogleDataTableDrivenLayout = new GoogleDataTableDrivenLayout();
//			this.network.operators.add(lay2);
//		}
		
		var fmt:TextFormat = new TextFormat("Verdana", 7);
//		this.network.operators.add(new Labeler(
//				function(d:NodeSprite):String {
//					var txt:String = d.data.name;
//					return txt;
//				}, this.network.data.NODES, fmt, function():Boolean {return true}));
	var labeller:Labeler = new Labeler(function(d:DataSprite):String {
	//trace(String(d.data.name)); 
		return String(d.data.name);
	});
	labeller.yOffset=15;
	labeller.xOffset=5;
	this.network.operators.add(labeller);
        this.network.x = 0;
        this.network.y = 0;
		this.network.controls.add(cdc);
		addChild(this.network);
		this.network.update();
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
		
	private function resizeStage(containerId:String, dataTable:DataView, options:Object) :void {
     	//calculate width and height ...			
     	var width:int = 630;
     	var height:int = 630;         	
		//resize containing div to resize the flash movie (which is set to height/width 100%)
        ExternalInterface.call("function(){isbSWFvisualizations."+this.containerId+".containerElement.style.height = "+ height +" + \"px\"; $(\""+ containerId +"\").style.width = "+ width +" + \"px\";  }");
        ExternalInterface.call("function(){isbSWFvisualizations."+this.containerId+".containerElement.style.scroll = yes;  }");
		this.network.bounds = new Rectangle(0, 0, width, height);
		// resizeHandler(event) is now called!
	}
		
	private function updateRoot(n:NodeSprite):void {	
		vis.data.root = n; // needed for RootInCenterCircleLayout 
		var t1:Transitioner = getTransitioner("rootUpdate",2);
		setNodeColor(lastRoot,t1,regularColor);
		setNodeColor(n,t1,rootColor);
		lastRoot = n;	
		vis.update(t1).play();
	}
		
	private function setNodeColor(ns:NodeSprite,t:Transitioner,color:int):void {
		if (ns != null) {
			var rs:RectSprite = ns.getChildAt(0) as RectSprite;
			t.$(rs).fillColor = color; 
			t.$(rs).lineColor = color; 
		}	
	}
		
	//methods for ClickDragControl
		
	private function onComplete(evt:Event):void {
			var li:LoaderInfo = evt.target as LoaderInfo;
			var ns:NodeSprite = li.loader.parent as NodeSprite;	
			li.loader.x = -li.width / 2;
			li.loader.y = -li.height / 2;
			var t:Transitioner = new Transitioner(4);
			t.$(ns).alpha = 1;
			var es:EdgeSprite;
			ns.visitEdges(function(es:EdgeSprite):void {
				if ((es.target != ns && es.target.parent.alpha > 0) || (es.source != ns && es.source.parent.alpha > 0)) {
					t.$(es).alpha = 1;
				}
			});
			
			t.play();
		}
		
//		private function onSingleClick(evt:SelectionEvent):void {
////			ExternalInterface.call("test");
//			showText(info1,"single click on node " + evt.node.data.name);
//			ExternalInterface.call("test");
//			trace("click");
//		}
		private function onSingleClickDeselect(evt:SelectionEvent):void {
//			if (info1.alpha > 0) //deselect info only if text is shown at the moment
//			showText(info1,"single click deselect",0xff0000);
		}
		
//		private function onDoubleClick(evt:SelectionEvent):void {
//			showText(info2,"double click on node " + evt.node.data.name);
//			ExternalInterface.call("sprout", evt.node.data.name);
//			
//			trace("sprouted on " + evt.node.data.name);
//		}
//		private function onDoubleClickDeselect(evt:SelectionEvent):void {
////			if (info2.alpha > 0)
////			showText(info2,"double click deselect",0xff0000);
//		}
		
//		private function showText(info:TextSprite,text:String,co:uint=0x000000):void {
//			var t1:Transitioner = getTransitioner(info.name + "-in",1); //info.name to distinquish info1 and info2 
//			var t2:Transitioner = getTransitioner(info.name + "-out",1);
//			t1.$(info).alpha = 1;
//			t2.$(info).alpha = 0;
//			info.text = text;
//			info.color = co;
//			new Sequence(t1,new Pause(2),t2).play();
//		}
		
		// called when movie is left-clicked on (aka "activated")
		private function activateHandler(event:Event):void {
            
        }

		// called when the movie's area is resized (by browser or javascript manipulation)
        private function resizeHandler(event:Event):void {
         
            //this.drawAfterResize(dataTable = new DataView("{}","False"));
           // this.drawAfterResize({},{},{});
        }		
	}
}
