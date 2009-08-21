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
	
	import flare.vis.operator.layout.CircleLayout;
	import flare.vis.operator.layout.ForceDirectedLayout;
	
	
	
	import org.systemsbiology.visualization.bionetwork.data.Network;
	import org.systemsbiology.visualization.bionetwork.layout.GoogleDataTableDrivenLayout;
	import org.systemsbiology.visualization.bionetwork.layout.ProjectedSVDLayout;
	import org.systemsbiology.visualization.bionetwork.layout.RootInCenterCircleLayout;
	
	
	public class layoutController
	{
		public function layoutController()
		{
		}
		
		public static function performLayout(network : Network, options : Object):void{

			if (options['layout']=="ForceDirected"){
				forceDirected(network,options);
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