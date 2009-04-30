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