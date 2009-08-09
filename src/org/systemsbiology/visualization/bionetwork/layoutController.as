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

//this class is responsible for taking the options object and using the various layout and appearnace options
//to configure the operators that will controll how the network object looks
//
//as such it is also responsible for implmenting the default values for the various options
//at the moment some of these varry on an operator by operator basis. As such the code fore each operator
//looks in the option object usually with a snipet like {optionname: options.user_optionname || 2}.
package org.systemsbiology.visualization.bionetwork
{
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.layout.CircleLayout;
	import flare.vis.operator.layout.ForceDirectedLayout;
	
	import org.systemsbiology.visualization.bionetwork.data.Network;
	import org.systemsbiology.visualization.bionetwork.extendedForces.*;
	import org.systemsbiology.visualization.bionetwork.layout.GoogleDataTableDrivenLayout;
	import org.systemsbiology.visualization.bionetwork.layout.ProjectedSVDLayout;
	import org.systemsbiology.visualization.bionetwork.layout.RootInCenterCircleLayout;
	import org.systemsbiology.visualization.data.DataView;
	
	
	public class layoutController
	{
		public function layoutController()
		{
		}
		
		public static function performLayout(network : Network, options : Object):void{

			if (options['layout']=="ForceDirected"){
				forceDirected(network,options);
			}
			else if (options['layout']=="extendedForceDirected"){
				extendedForceDirected(network,options);
			}
			else if (options['layout']=="3dSVD"){
				threeDSVD(network,options);
			}
			else if (options['layout']=="GoogleDataTableDriven"){
				GoogleDataTableDriven(network,options);
			}
			else if (options['layout']=="radialTree")
			{
				radialTree(network,options);			
			}
			else {
				circular(network,options);
			}

		}
		
		public static function circular(network : Network, options : Object):void{
			//default circular layout
			if(options.center)
			{
				//network.findNodeByName(options.center);
				var rootincenterlay:RootInCenterCircleLayout = new RootInCenterCircleLayout();
				
				network.operators.add(rootincenterlay);
			}
			else
			{
				var clay:CircleLayout =  new CircleLayout(null, null, false);
				network.operators.add(clay);
			}
		}
		
		public static function radialTree(network : Network, options : Object):void{
			// prepare data with default settings
			//network.data.nodes.setProperties({
			//	shape: null,                  // no shape, use labels instead
			//	visible: eq("childDegree",0), // only show leaf nodes
			//});
			
			// place around circle by tree structure, radius mapped to depth
			// make a large inner radius so labels are closer to circumference
			network.operators.add(new CircleLayout("depth", null, true));
			CircleLayout(network.operators.last).startRadiusFraction = 3/5;
		}
		
		public static function GoogleDataTableDriven(network : Network, options : Object):void{
			var gddlay: GoogleDataTableDrivenLayout = new GoogleDataTableDrivenLayout();
			network.operators.add(gddlay);
			//shape: flare.util.Shapes.SQUARE,
		}
		
		public static function forceDirected(network : Network, options : Object):void{
			network.data.nodes.setProperties({x:315, y:315});     	
	    	network.continuousUpdates = options.continuousUpdates || false;
	    	//force directed layout

			var fdlay:ForceDirectedLayout = new ForceDirectedLayout(true,120);
	    	fdlay.simulation.dragForce.drag=1;
	    	fdlay.simulation.nbodyForce.gravitation=-128;  
	        fdlay.defaultParticleMass= 6;
	        fdlay.defaultSpringLength=100;
	        fdlay.defaultSpringTension= 0.1;
	        network.operators.add(fdlay);
		}
		
		public static function extendedForceDirected(network : Network, options : Object):void{
			
			//TODO document this
			network.data.nodes.setProperties({x:315, y:315});
	    	network.continuousUpdates = options.continuousUpdates || false;
	    	var fdlay:ForceDirectedLayout = new ForceDirectedLayout(true,options.continuousUpdates?1:120);
	    	fdlay.simulation.nbodyForce.gravitation=-1;  
	        fdlay.defaultParticleMass= 16;
	        fdlay.defaultSpringLength=20;
//	        fdlay.defaultSpringTension;
	    	if(options.nodeClusters)
	    	{
	    		var nodeClusters : DataView = options.nodeClusters;
	    		var labelNodes : Array = new Array;
	    		for (var i:Number = 1; i<nodeClusters.getNumberOfColumns();i++)
	    		{
	    			var y0 : Number = Math.random()*network.bounds.height;
	    			var x0 : Number = Math.random()*network.bounds.width;
	    			var colId : * =nodeClusters.getColumnId(i);
	    			var labelnode : NodeSprite = network.addNodeIfNotExist(nodeClusters.getColumnLabel(i));
	    			var nodes : Array = [labelnode];
	    			labelnode.props.islabel = true;
	    			labelnode.size=0;
	    			labelnode.lineColor=0xffff0000;
	    			labelnode.x=x0;
	    			labelnode.y=y0;
	    			labelNodes.push(labelnode);
	    			for (var j:Number = 0; j<nodeClusters.getNumberOfRows();j++)
	    			{
	    				
	    				if(nodeClusters.getValue(j,i)==1)
	    				{
	    					var datanode : NodeSprite = network.findNodeByName(nodeClusters.getValue(j,0));
	    					if(datanode)
	    					{
	    						if(datanode.props.clusters)
	    						{
	    							datanode.props.clusters.push(i);
	    						}
	    						else
	    						{
	    							datanode.props.clusters=[i];
	    						}
	    						datanode.x=x0;
	    						datanode.y=y0;
	    						nodes.push(datanode);
	    					}
	    				}
	    			}
	    			fdlay.simulation.addForce(new GatheringForce(.05,Math.sqrt(nodes.length)*25,nodes));
	    			//TODO make forces binding labels to nodes and nodes to each other seperate
	    			//TODO make cluster forces only for positive displacement...ie restrict nodes to be within r of each other
	    			//nodes.shift();
	    			//fdlay.simulation.addForce(new NBodyForce(.005,64,nodes));
			
	    		}
	    		
	    		fdlay.simulation.addForce(new NSpringForce(.01,Math.sqrt((network.bounds.width*network.bounds.height)/labelNodes.length),labelNodes));
	    		fdlay.simulation.addForce(new SquaredDragForce(1));
	    		fdlay.simulation.dragForce.drag=.5;
	    		
	    		
	    		

	    		fdlay.restLength = function (es : EdgeSprite) : Number 
	    		{
	    			if(es.source.props.clusters & es.target.props.clusters)
	    			{
	    				for(var i : int=0; i<es.source.props.clusters.length; i++)
	    					if(es.target.props.clusters.indexOf(es.source.props.clusters[i])!=-1)
	    						return fdlay.defaultSpringLength;
	    				return 16*fdlay.defaultSpringLength;
	    			}
	    			else
	    			{
	    				return 16*fdlay.defaultSpringLength;
	    			}
	    		}
	    		
	    		fdlay.mass = function( ns : NodeSprite) : Number
	    		{
	    			if(ns.props.islabel)
	    			{
	    				return 4*fdlay.defaultParticleMass;
	    			}
	    			return fdlay.defaultParticleMass;
	    		}
	    		
	    		fdlay.tension = function( es : EdgeSprite) : Number
	    		{
	    			if(es.source.props.clusters & es.target.props.clusters)
	    			{
	    				for(var i : int=0; i<es.source.props.clusters.length; i++)
	    					if(es.target.props.clusters.indexOf(es.source.props.clusters[i])!=-1)
	    						return fdlay.defaultSpringTension;
	    				return .0001*fdlay.defaultSpringTension;
	    			}
	    			else
	    			{
	    				return .0001*fdlay.defaultSpringTension;
	    			}
	    			
	    		}
	    		
	    	}
	    	//force directed layout

			
	    	
	        network.operators.add(fdlay);
		}
		
		public static function threeDSVD(network : Network, options : Object):void{
			network.continuousUpdates = true;
			var psvdlay:ProjectedSVDLayout = new ProjectedSVDLayout();
			network.operators.add(psvdlay);
			network.data.edges.setProperties({	
			lineAlpha: options.edge_lineAlpha || .3,
			lineWidth: options.edge_lineWidth || 1
			}); 
			
			//shape: flare.util.Shapes.SQUARE,
		}

	}
}