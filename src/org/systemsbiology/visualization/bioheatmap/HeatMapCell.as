package org.systemsbiology.visualization.bioheatmap
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class HeatMapCell extends Sprite
	{
		public var row : int;
		public var col : int;
		
		public function HeatMapCell(row : int, col : int, height : *, width: *, cellValue : String, fillString : String,linkUrl:String, defaultTextFormat : *)
		{
			this.row = row;
			this.col = col;

	        var cellText : TextField = new TextField();
	        var cellShape : Shape = new Shape();
	        
	        cellText.defaultTextFormat =  defaultTextFormat;
            cellText.text = cellValue;
            if(linkUrl!="")
            {
            	cellText.htmlText = "<a href='"+linkUrl+"'>"+cellValue+"</a>";
            }
            else
            {
            	cellText.text=cellValue;
            }
            cellText.selectable = false;
            cellText.embedFonts = true;
            
            
            cellShape.graphics.beginFill(parseInt(fillString,16));
    		cellShape.graphics.lineStyle(0, 0);
    		cellShape.graphics.drawRect(0, 0, height, width);
    		cellShape.graphics.endFill();

            
			addChild(cellShape);
            addChild(cellText);

                    
			super();
		}
		
	}
}