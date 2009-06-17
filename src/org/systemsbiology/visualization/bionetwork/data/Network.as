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

package org.systemsbiology.visualization.bionetwork.data
{
	import flare.query.methods.*;
	import flare.util.Shapes;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import org.systemsbiology.visualization.data.GraphDataView;
	import org.systemsbiology.visualization.data.LayoutDataView;
	
	//wrapper for Flare's network classes-data, edgeSprite, nodeSprite	
	public class Network extends Visualization
	{
		private var changed:Boolean = false;	
		public function Network(data:Data)
		{	
			super(data);
			this.data.addGroup("Annotations");
		}
		
		//functions for placing data in correct parts of network
		public function bind_data(data : *) : void{
			if (data is GraphDataView){
				bind_graph(data);
			}
			else if (data is LayoutDataView){
				bind_layout(data);
			}
				
		}
		
		public function bind_graph(graphDataTable:GraphDataView):void{
			var interactor1_name:String;
			var interactor2_name:String;
			var interactor1:NodeSprite;
			var interactor2:NodeSprite;
			var edge:EdgeSprite;
			var sources:Array;
			for (var i:Number = 0; i<graphDataTable.getNumberOfRows();i++) {
				interactor1_name=graphDataTable.getInteractor1Name(i);
				interactor2_name=graphDataTable.getInteractor2Name(i);
				interactor1 =  this.addNodeIfNotExist(interactor1_name);
				interactor2 = this.addNodeIfNotExist(interactor2_name);
				edge = this.addEdgeIfNotExist(interactor1, interactor2);
				sources=graphDataTable.getSources(i);
				if (sources){
					for (var k:Number=0; k<sources.length; k++){
						this.addEdgeSource(edge, sources[k]);
					}
				}
			}
		}
		
		public function bind_layout(layoutTable:LayoutDataView):void{
			for (var i:Number = 0; i<layoutTable.getNumberOfRows();i++) {
				var interactor_name:String = layoutTable.getValue(i,0);
				this.setNodeColor(interactor_name, layoutTable.getColor(i));
				this.setNodeSize(interactor_name, layoutTable.getSize(i));
				this.setNodeShape(interactor_name, layoutTable.getShape(i));			
			}
		}		
		
		//function from data class tweaked to make it easier to add nodes with type
		public function addNode(n:Object, groupName:String=null):NodeSprite
		{
			var node:NodeSprite=this.data.addNode(n);
			if (groupName!=null){
				this.data.group(groupName).add(node);
			}
			return node;
		}
		
		//wrapper function
		public function addEdge(source:NodeSprite, target:NodeSprite, directed:Object = false):EdgeSprite
		{
			return this.data.addEdgeFor(source, target, directed);
		}
		
		//add edge if doesn't already exist; if exist returns node
		public function addEdgeIfNotExist(source:NodeSprite, target:NodeSprite, directed:Object = false):EdgeSprite
		{
			if (!checkEdge(source.name, target.name,directed)){
				return this.data.addEdgeFor(source, target, directed);
			}
			else {
				return this.findEdgeByNodes(source.name,target.name);
			}
		}
		
		//tie a source to an edge
		public function addEdgeSource(edge:EdgeSprite, source:String):void{
			if (edge.props.ixnsources==null){
				edge.props.ixnsources = [source];
			}
			else{
				edge.props.ixnsources.push(source); 
			}
		}
		
		public function getEdgeSource(edge:EdgeSprite):Array
		{
			return edge.props.ixsources;
		}
		
		//warning: findEdgesByNode causes you to loop through network edges each time
		public function isOrphan(nodeName:String):Boolean{
			var edges:Array;
			edges = this.findEdgesByNode(nodeName);
			trace("EDGES" + edges);
			if (edges.length>0){
				return false;
			}
			else {
				return true;
			}		
		}
		
		public function isSelfInteractor(nodeName:String):Boolean{
			var edges:Array;
			var node:NodeSprite;
			edges = this.findEdgesByNode(nodeName);
			for (var i:Number=0; i < edges.length; i++){
				var edge:EdgeSprite=edges[i];
				if (edge.source.data.name!=nodeName || edge.target.data.name!=nodeName){
					return false;
				}
			}
			return true;
		}
		
		//checks to see if a node already exist
		public function checkNode(name:String):Boolean
		{
			trace("check node: " + name);
			var nodes:Array = [];
			nodes = select("data")
				.eval(this.data.nodes);
			var names:Array = nodes.map(extractNames);
			return -1!=names.indexOf(name);
		}
		
		//for parameters that aren't build into the network. they go in a catch all attributes called "props"
		public function updateNodeParams(name:String, params:Object):void{
			trace("updateNodeParams");
			var node:NodeSprite=this.findNodeByName(name);
			for(var param:String in params){
				trace("PARAMS " + param);
				this.data.nodes.setProperty("props."+param, params[param], null, function(n:NodeSprite):Boolean{return n.data.name==name;});				
			}
		}	
		
		//creates a attributes under "props" to store timecourse data for a node
		public function setTimecourseData(name:String, timecourse_data:Object) :void{
			trace("setTimecourseData");
			trace(name);
			this.data.nodes.setProperty("props.timecourse_data", timecourse_data, null, function(n:NodeSprite):Boolean{return n.data.name==name;});			
		}
		
		//need to work in backword direction too or just accept edge
		public function setEdgeColor(source:NodeSprite, target:NodeSprite, color:String):void{
			
		}
		
		public function setNodeColor(name:String, color:String):void{
			trace("setNodeColor");
			this.data.nodes.setProperty("fillColor", color, null, function(n:NodeSprite):Boolean{return n.data.name==name;}); 
		}	
		
		public function setNodeShape(name:String, shape:String):void{
			trace("setNodeShape");
			trace(shape);
			this.data.nodes.setProperty("shape", Shapes[shape], null,  function(n:NodeSprite):Boolean{return n.data.name==name;});
//			this.data.nodes.setProperty("size", 10); 
		}		
		
		public function setNodeSize(name:String, size:Number):void{
			trace("setNodeSize");
			this.data.nodes.setProperty("size", size, null, function(n:NodeSprite):Boolean{return n.data.name==name;}); 
		}	
		
		public function checkEdge(name1:String, name2:String, directed:Object = null):Boolean 
		{
			trace("check edge");
			var targets:Array = [];
			var sources:Array = [];	
			targets=getTargets();
			sources==getSources();	
			for (var i:Number = 0; i<targets.length; i++){
				var source:NodeSprite = targets[i];
				var target:NodeSprite = targets[i];
				if (source==null || target==null){
					continue;
				}	
				if (eq(source.data.name,name1) && (eq(target.data.name,name2))){
					return true;
				}
				else if (eq(source.name,name1) && (eq(source.name,name2))){
					return true;
				} 
			}
			return false;
		}
//		
		public function findNodeByName(name:String):NodeSprite
		{
			trace("find node: " + name);
			var nodes:Array = [];
			nodes = select("data")
				.eval(this.data.nodes);
			var names:Array = nodes.map(extractNames);
			var node_index:int=names.indexOf(name);
			if (neq(node_index, -1)){
				return this.data.nodes[node_index];
			}
				return null;
		}
		
		public function findEdgesByNode(nodeName:String):Array{
			var edges:DataList = this.data.edges;
			var edgesWNode:Array = [];
			var edge:EdgeSprite;
			for (var i:Number = 0; i<edges.length; i++){
				edge = edges[i];
				if (edge.source.data.name==nodeName || edge.target.data.name==nodeName){
					edgesWNode.push(edge);
				}
			}
			return edgesWNode;
		}
		
		public function findEdgeByNodes(source_name:String, target_name:String):EdgeSprite{
			//TODO : optimize this to get source node and check only outgoing edges
			var edge_index:int = -1;
			var edges:DataList = this.data.edges;
			
			for (var i:Number = 0; i<edges.length; i++){
				var edge:EdgeSprite = edges[i];
				//var target:NodeSprite = targets[i];
				if (edge.source.data.name==source_name && edge.target.data.name ==target_name){
					edge_index = i;
					break;
				}
				else if (edge.source.data.name==source_name && edge.source.data.name==target_name){
					edge_index = i;
					break;
				} 
			}	
			
			if (neq(edge_index,-1)){
				return this.data.edges[edge_index];
			}
			else {
				return null;
			}		
		}
			
		//helper functions
		public function addNodeIfNotExist(name:String):NodeSprite
		{
			trace("adding" + name);
			var interactor:NodeSprite;
			if (!this.checkNode(name)){
					trace("create");
					interactor=this.addNode({name:name});
				}
			else{
					interactor=this.findNodeByName(name);
				}
			return interactor;
		}
		
		public function addAnnotation(geneName:String, annotationName:String):NodeSprite
		{
			var annotation:NodeSprite=this.addNode({name:geneName},"Annotations");
			var interactor:NodeSprite=this.findNodeByName(geneName);
			this.addEdgeIfNotExist(interactor, annotation);
			return annotation;
		}
		
//		public function addEdgeToAttribute(name:String):EdgeSprite
//		{
//			return null;
//		}
		
		private function getTargets():Array {
			var edges:Array = this.data.edges.toDataArray();
			return edges.map(extractTargets);
		}
		
		private function getSources():Array {
			var edges:Array = this.data.edges.toDataArray();
			return edges.map(extractSources);
		}
		
		private function extractNames(element:*, index:int, arr:Array):String {
            return String(element.data.name);
        }

		private function extractTargets(element:*, index:int, arr:Array):EdgeSprite {
            return element.target;
        }		

		private function extractSources(element:*, index:int, arr:Array):EdgeSprite {
            return element.source;
        }		

		//look for attribute as target and node as source
//		public function findAttributesByNode()
//		{
//			
//		}
//	
		public function toggleChanged():void
		{
			this.changed = !this.changed;
		}	

//		
	}
}