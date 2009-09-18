package org.systemsbiology.visualization.bionetwork
{
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.label.Labeler;
	
	import org.systemsbiology.visualization.bioheatmap.discretecolorrange;
	import org.systemsbiology.visualization.bionetwork.data.Network;
	import org.systemsbiology.visualization.bionetwork.display.CircularHeatmapRenderer;
	import org.systemsbiology.visualization.data.LayoutDataView;
	
	public class nodeController
	{
		public function nodeController()
		{
		}
		
		public static function styleNodes(network : Network, options : Object):void{
			var i:Number = 0;
			var n : NodeSprite;
			var propHash : Object = new Object;

			var defaultProps : Object = {
				fillColor:  0x880055cc, 
				lineWidth: 0.5,
				size: 1,
				shape: Shapes["CIRCLE"]
			}
			
			if(options["layout_data"])
			{
				var layoutTable : LayoutDataView = options["layout_data"];

				for (i=0; i<layoutTable.getNumberOfRows();i++) {
					propHash[layoutTable.getValue(i,0)] = {
						fillColor: layoutTable.getColor(i)||defaultProps.fillColor, 
						size: layoutTable.getSize(i)==-1?defaultProps.size:layoutTable.getSize(i), 
						shape: layoutTable.getShape(i)!=""?Shapes[layoutTable.getShape(i)]:defaultProps.shape
						};			
				}
			}
			for (i=0; i<network.data.nodes.length;i++) {
				
				n =network.data.nodes[i];
				
				
				n.lineWidth= options.node_lineWidth || defaultProps.lineWidth;
				n.buttonMode= true;
				if(propHash[n.data.name])
				{
					n.fillColor= propHash[n.data.name].fillColor || options.node_fillColor || defaultProps.fillColor; 
					n.size = propHash[n.data.name].size || n.size;
					n.shape = propHash[n.data.name].shape || n.shape;
				}
				else
				{
					n.fillColor= options.node_fillColor || defaultProps.fillColor;
				}
				
			    //n.setNodeProperties(propHash[n.data.name]);
			    
			}
			
//			network.data.nodes.setProperties({
//				fillColor:options.node_fillColor || 0x880055cc, 
//				lineWidth: options.node_lineWidth || 0.5,
//				buttonMode: true });

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
			var dataRange : Object = { min: minvalue, max: maxvalue };
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