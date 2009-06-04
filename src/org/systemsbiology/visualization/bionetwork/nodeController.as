package org.systemsbiology.visualization.bionetwork
{
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.label.Labeler;
	
	import org.systemsbiology.visualization.bioheatmap.discretecolorrange;
	import org.systemsbiology.visualization.bionetwork.data.Network;
	import org.systemsbiology.visualization.bionetwork.display.CircularHeatmapRenderer;
	
	public class nodeController
	{
		public function nodeController()
		{
		}
		
		public static function styleNodes(network : Network, options : Object):void{
			network.data.nodes.setProperties({
				fillColor:options.node_fillColor || 0x880055cc, 
				lineWidth: options.node_lineWidth || 0.5,
				buttonMode: true });

			if (options['nodeRenderer']=="CircularHeatmap"){
				circularHeatmap(network,options);
			}
			setLabels(network);
		}
		
		private static function circularHeatmap(network : Network,options:Object):void {
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
		
		private static function setLabels(network : Network):void {
			var labeller:Labeler = new Labeler(function(d:DataSprite):String {
			return String(d.data.name);
			});
			labeller.yOffset=15;
			labeller.xOffset=5;
			network.operators.add(labeller);
		}

	}
}