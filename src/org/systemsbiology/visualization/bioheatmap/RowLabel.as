package org.systemsbiology.visualization.bioheatmap
{
	import flash.display.Sprite;
	import flash.text.TextField;

	public class RowLabel extends Sprite
	{
		public var row : int;
		
		public function RowLabel(rownum : int,text : String, width : int, linkUrl:String, textformat : *)
		{
			this.row=rownum;
			var rowLabel : TextField = new TextField();
            rowLabel.defaultTextFormat = textformat;
            rowLabel.width = width;
            //rowLabel.text = text;
            //rowLabel.htmlText = "<a href='event:'>"+text+"</a>";
            if(linkUrl!="")
            {
            	rowLabel.htmlText = "<a href='"+linkUrl+"'>"+text+"</a>";
            }
            else
            {
            	rowLabel.text=text;
            }
            rowLabel.selectable=false;	
            rowLabel.embedFonts = true;

            this.addChild(rowLabel);
            
			super();
		}
		
	}
}