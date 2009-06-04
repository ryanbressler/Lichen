package org.systemsbiology.visualization.bionetwork.display
{
	import flare.display.TextSprite;
	import flare.vis.controls.TooltipControl;
	import flare.vis.data.NodeSprite;
	import flare.vis.events.TooltipEvent;
	
	import flash.text.TextFormat;
	
	import org.systemsbiology.visualization.bionetwork.data.Network;
	
	public class tooltip
	{
		public function tooltip()
		{
			
		}
		
		public static function addNodeTooltips(network:Network)
		{
			var fmt:TextFormat = new TextFormat();

		    fmt.color = 0x000000;
		
		    fmt.size = 14;
		
		    fmt.bold = true;
		
		    
		    var ttc:TooltipControl = new TooltipControl(NodeSprite);
		
		    (ttc.tooltip as TextSprite).textFormat = fmt;
		
		      
		
		      ttc.addEventListener(TooltipEvent.SHOW,function(evt:TooltipEvent):void {
		
		        trace("the node you moused over is: " + evt.node.data.name);
		
		        (ttc.tooltip as TextSprite).textField.text = evt.node.data.name;//"HERE IS YOUR TOOLTIP";//evt.node.name;
			
		        (ttc.tooltip as TextSprite).render();
		
		      });
		
		      
		
		      network.controls.add(ttc); 

		}
		
		public static function addEdgeTooltips() :void
		{

/*

    var etc:TooltipControl = new TooltipControl(NodeSprite);

    (etc.tooltip as TextSprite).textFormat = fmt;

      
      etc.addEventListener(TooltipEvent.SHOW,function(evt:TooltipEvent):void {

        trace("the edge you moused over is: " + evt.edge.data.name);

        (etc.tooltip as TextSprite).textField.text = evt.node.data.name;
        (etc.tooltip as TextSprite).render();

      });

      

      this.network.controls.add(etc);

*/
		}

	}
}