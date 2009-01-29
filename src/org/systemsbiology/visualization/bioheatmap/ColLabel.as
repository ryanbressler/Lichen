package org.systemsbiology.visualization.bioheatmap
{
	import flash.display.Sprite;
	import flash.text.TextField;
    
    
	public class ColLabel extends Sprite
	{
		public var col : int;
		public var colLabel : TextField;
		public function ColLabel(colnum : int,text : String, width : int,linkUrl:String, textformat : *)//,labelEventType : *, labelEventHandeler : *)
		{
			col = colnum;
			colLabel = new TextField();
            colLabel.defaultTextFormat = textformat;
            colLabel.width = width;
            if(linkUrl!="")
            {
            colLabel.htmlText = "<a href='"+linkUrl+"'>"+text+"</a>";
            }
            else
            {
            	colLabel.text=text;
            }
            colLabel.selectable=false;		                
            colLabel.embedFonts = true;
            //colLabel.addEventListener(labelEventType,labelEventHandeler);

            this.addChild(colLabel);
     
            this.rotation = -45;
			super();
		}
		
	}
}