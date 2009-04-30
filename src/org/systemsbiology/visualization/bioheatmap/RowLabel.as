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