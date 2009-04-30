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