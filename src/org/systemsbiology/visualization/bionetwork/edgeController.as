package org.systemsbiology.visualization.bionetwork
{
	import flare.query.methods.div;
	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.render.ArrowType;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.operator.layout.BundledEdgeRouter;
	
	import org.systemsbiology.visualization.bionetwork.data.Network;
	import org.systemsbiology.visualization.bionetwork.display.MultiEdgeRenderer;
	import org.systemsbiology.visualization.data.DataView;

	
	public class edgeController
	{

		
		public function edgeController()
		{
			
		}
		
		public static function styleEdges(network : Network, options : Object):void{
			//TODO: optimized loop to style edges
			
			//basic options and defaults
			network.data.edges.setProperties({			
					lineWidth: options.edge_lineWidth || 2,
					lineColor: options.edge_lineColor || 0x66000000,
					buttonMode: true 
				});
			
			
			var edge_data : org.systemsbiology.visualization.data.DataView = options.edge_data;
			var edgedatahash : Object = {};
						
			if(options.edge_data)
			{
				var colorcol : int;
				var widthcol : int;
			
				for (var i : int =0; i<edge_data.getNumberOfColumns();i++)
				{
					if(edge_data.getColumnLabel(i)=="color")
					{
						colorcol=i;
					}
					if(edge_data.getColumnLabel(i)=="shape")
					{
						widthcol=i;
					}
				
				}
				 
				for (var i : int =0; i<edge_data.getNumberOfRows();i++)
				{
					var data : Object = {width:widthcol?edge_data.getValue(i,2):null, color:colorcol?edge_data.getValue(i,colorcol):null};
					if(!edgedatahash[edge_data.getValue(i,0)])
					{
						edgedatahash[edge_data.getValue(i,0)] = {}
					}
					edgedatahash[edge_data.getValue(i,0)][edge_data.getValue(i,1)]=data;
				}
			}
			
			var e : EdgeSprite;
			for (var i : int =0; i<network.data.edges.length;i++) {
				e = network.data.edges[i];
				if(e.directed)
				{
					e.arrowType = e.props.type ? ArrowType[e.props.type] : ArrowType.TRIANGLE;
					e.arrowWidth = 8;
					e.arrowHeight = 8;
				}
				if(e.props.color)
				{
					e.lineColor = e.props.color;
				}
				if(edgedatahash && edgedatahash[e.source.data.name] && edgedatahash[e.source.data.name][e.target.data.name])
				{

						e.lineColor = edgedatahash[e.source.data.name][e.target.data.name].color || e.lineColor;
						e.lineWidth = edgedatahash[e.source.data.name][e.target.data.name].width || e.lineWidth;
				} 
				
			}
//			network.data.edges.setProperties({
//				arrowType: ArrowType.TRIANGLE,
//				arrowWidth: 8,
//				arrowHeight: 8
//				}, null, function(e:EdgeSprite):Boolean{return e.directed==true;});
			
			//delegate to edgeRenderers
			if (options['edge_renderer']=='multiedge'){
				multiEdge(network,options);
			}
			
			if(options['edge_router']=='bundled')
			{
				bundledEdge(network,options);
			}
			
			
			
		}
		
		public static function bundledEdge(network : Network, options : Object):void
		{
			network.data.edges.setProperties({
				lineWidth: options.edge_lineWidth || 2,
				lineColor: options.edge_lineColor || 0xff0055cc,
				mouseEnabled: false//,          // non-interactive edges
				//visible: neq("source.parentNode","target.parentNode")
			});

			network.operators.add(new BundledEdgeRouter(0.95));
			// set the edge alpha values
			// longer edge, lighter alpha: 1/(2*numCtrlPoints)
			
			network.operators.add(new PropertyEncoder({alpha: div(1,"points.length")}, Data.EDGES));	
		}
		
		public static function multiEdge(network : Network, options : Object):void
		{
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

	}
}