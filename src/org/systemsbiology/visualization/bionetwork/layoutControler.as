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
	import flare.animate.Transitioner;
	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.legend.Legend;
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.operator.layout.BundledEdgeRouter;
	import flare.vis.operator.layout.CircleLayout;
	import flare.vis.operator.layout.ForceDirectedLayout;
	import flare.vis.data.render.ArrowType;
	import flare.query.methods.div;
	
	import org.systemsbiology.visualization.bioheatmap.discretecolorrange;
	import org.systemsbiology.visualization.bionetwork.data.Network;
	import org.systemsbiology.visualization.bionetwork.display.CircularHeatmapRenderer;
	import org.systemsbiology.visualization.bionetwork.layout.GoogleDataTableDrivenLayout;
	import org.systemsbiology.visualization.bionetwork.layout.ProjectedSVDLayout;
	import org.systemsbiology.visualization.bionetwork.layout.RootInCenterCircleLayout;
	import org.systemsbiology.visualization.bionetwork.display.MultiEdgeRenderer;
	
	public class layoutControler
	{
		public function layoutControler()
		{
		}
		
		public static function performLayout(network : Network, options : *):void{
		//set some defaults

		network.data.nodes.setProperties({fillColor:options.node_fillColor || 0xff0055cc, lineWidth: options.node_lineWidth || 0.5});
		network.data.edges.setProperties({			
			lineWidth: options.edge_lineWidth || 2,
			lineColor: options.edge_lineColor || 0x77000000
			});     

  
		
		if (options['nodeRenderer']=="CircularHeatmap"){
			var maxvalue:Number = int(options['maxval']);
			var minvalue:Number = int(options['minval']);
			trace(options['maxvalue']);
			trace(options['minvalue']);
			var dataRange : * = { min: minvalue, max: maxvalue };
			var discreteColorRange : discretecolorrange = new discretecolorrange(64, dataRange, {});
			//network.data.nodes.setProperties({renderer: CircularHeatmapRenderer.instance});
			for each (var target_node:NodeSprite in network.data.nodes){
				var chr:CircularHeatmapRenderer = new CircularHeatmapRenderer(discreteColorRange);
				target_node.setNodeProperties({renderer: chr});
			}
		}

		if (options['layout']=="ForceDirected"){
			network.data.nodes.setProperties({x:315, y:315});     	
	    	network.continuousUpdates = false;
	    	//force directed layout

			var fdlay:ForceDirectedLayout = new ForceDirectedLayout(true,120);
	    	fdlay.simulation.dragForce.drag=1;
	    	fdlay.simulation.nbodyForce.gravitation=-128;  
	        fdlay.defaultParticleMass= 6;
	        fdlay.defaultSpringLength=100;
	        fdlay.defaultSpringTension= 0.1;
	        network.operators.add(fdlay);	
		}
		else if (options['layout']=="3dSVD"){
			network.continuousUpdates = true;
			var psvdlay:ProjectedSVDLayout = new ProjectedSVDLayout();
			network.operators.add(psvdlay);
			network.data.edges.setProperties({	
			lineAlpha: options.edge_lineAlpha || .3,
			lineWidth: options.edge_lineWidth || 1
			}); 
			
			//shape: flare.util.Shapes.SQUARE,
		}
		else if (options['layout']=="GoogleDataTableDriven"){
			var gddlay: GoogleDataTableDrivenLayout = new GoogleDataTableDrivenLayout();
			network.operators.add(gddlay);
			
			//shape: flare.util.Shapes.SQUARE,
		}
		else if (options['layout']=="bundledEdges")
		{
			//network.data.nodes.sortBy("-data.name.length");	
			// prepare data with default settings
			network.data.nodes.setProperties({
			//	shape: null,                  // no shape, use labels instead
			//	visible: eq("childDegree",0), // only show leaf nodes
				buttonMode: true              // show hand cursor
			});
			network.data.edges.setProperties({
				lineWidth: options.edge_lineWidth || 2,
				lineColor: options.edge_lineColor || 0xff0055cc,
				mouseEnabled: false//,          // non-interactive edges
				//visible: neq("source.parentNode","target.parentNode")
			});
						
			// place around circle by tree structure, radius mapped to depth
			// make a large inner radius so labels are closer to circumference
			network.operators.add(new CircleLayout("depth", null, true));
			CircleLayout(network.operators.last).startRadiusFraction = 3/5;
			// bundle edges to route along the tree structure
			
			network.operators.add(new BundledEdgeRouter(0.95));
			// set the edge alpha values
			// longer edge, lighter alpha: 1/(2*numCtrlPoints)
			
			network.operators.add(new PropertyEncoder(
			{alpha: div(1,"points.length")}, Data.EDGES));
		}
		else {
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
		
		if (options['edgeRenderer']=='multiedge'){
			network.data.edges.setProperties({
				lineWidth: options.edge_lineWidth || 3,
				lineAlpha: options.edge_lineAlpha || 1,
				arrowType: "TRIANGLE",
				lineColor: 0xff0000bb,
				mouseEnabled: true,
				visible:true,
				renderer: MultiEdgeRenderer.instance
			});
		}
		
		network.data.edges.setProperties({
			arrowType: ArrowType.TRIANGLE,
			arrowWidth: 15,
			arrowHeight: 15
			}, null, function(e:EdgeSprite):Boolean{return e.directed==true;}
		);
			
		//alpha stuff must be here since color are long 0xAARRGGBB form	
		network.data.nodes.setProperties({
			fillAlpha: options.node_fillAlpha || 0.5
			});
		if(options.edge_lineAlpha)	
		network.data.edges.setProperties({			
			lineAlpha: options.edge_lineAlpha || .4
			}); 
		
		}

	}
}