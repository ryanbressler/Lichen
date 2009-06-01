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

package 
{

        import com.adobe.serialization.json.JSON;
        
        import flash.display.Shape;
        import flash.display.Sprite;
        import flash.events.MouseEvent;
        import flash.geom.*;
        import flash.text.TextField;
        import flash.text.TextFormat;
        import flash.utils.*;
        
        import org.systemsbiology.visualization.GoogleVisAPISprite;
        import org.systemsbiology.visualization.bioheatmap.ColLabel;
        import org.systemsbiology.visualization.bioheatmap.HeatMapCell;
        import org.systemsbiology.visualization.bioheatmap.RowLabel;
        import org.systemsbiology.visualization.bioheatmap.discretecolorrange;
        import org.systemsbiology.visualization.data.*;
        

 		
        public class bioheatmap extends GoogleVisAPISprite
        {

                //paramaters
                
                public var  myData:Object;// = new Array();
                public var options:Object;// = new Array();
                
                //font
                // We must embed a font so that we can rotate text and do other special effects
                // said font must be installed on your system
			   	[Embed(systemFont='Helvetica', 
			        fontName='myHelveticaFont', 
			        mimeType='application/x-font'
			    )] 
			    // You do not use this variable directly. It exists so that 
			    // the compiler will link in the font.
			    private var _font1:Class;
			    private var _fontHeight:int = 14;			    
			    private var  _labelTextFormat : TextFormat = new TextFormat('myHelveticaFont',14);             
                //private var _font:String = "sans";
		        private var _useRowNames:Boolean = true;	
		        private var _useCellLabels:Boolean = true;	
		        //this._minimumFontHeight = 7;	
		        
				
				//layout
				private var _colSprite : Sprite;
				private var _rowSprite : Sprite;
				private var _mapSprite : Sprite;
				private var _selectionSprite : Sprite; 
				private var _lockHeaders:Boolean = false;
				private var _hideHeaders:Boolean = false;
				private var _hideColHeaders:Boolean = false;
				private var _hideRowHeaders:Boolean = false;
		        private var _cellSpacing:int = 0; // NOT SUPPORTED YET!	
		        private var _cellWidth:int = 15;	
		        private var _cellHeight:int = 15;	
		        private var _SpriteWidth:int;
		        private var _SpriteHeight:int;	
		        private var _cellBorder:Boolean = false;		
		        private var _drawHeatmapBorder:Boolean = true;	
		        private var _fixedSpriteSize:Boolean = false;
				private var _verticalPadding:int = 40;		
		        private var _horizontalPadding:int = 10;		
		        private var _columnLabelBottomPadding:int = 5;		
		        private var _rowLabelRightPadding:int = 10;
		        
		        private var _rowBaseUrl:String="";
		        private var _columnBaseUrl:String="";
		        private var _cellBaseUrl:String="";
		        private var _cellToolTipType:String="value";
		        
		        private var _selectionDisplay : Object = {mode : "flash", 
		        								fill:{color:{ r: 0, g: 0, b: 0, a: .5 }}, 
		        								border:{width:2,color:{ r: 0, g: 0, b: 0, a: 1 }}
		        								};
		        
			
		        // color defaults	
		        private var _maxColors:int = 64; // number of colors		
		        private var _backgroundColor:Object = { r: 0, g: 0, b: 0, a: 1 };		
		        private var _maxColor:Object = { r: 255, g: 0, b: 0, a: 1 };		
		        private var _minColor:Object = { r: 0, g: 255, b: 0, a: 1 };		
		        private var _emptyDataColor:Object = { r: 100, g: 100, b: 100, a: 1 };	
		        private var _specialValueColors:Array = [{value:"Y",color:{ r: 0, g: 0, b: 255, a: .5 }},
		        										{value:"N",color:{ r: 0, g: 0, b: 0, a: 1 }}];	
		        private var _passThroughBlack:Boolean = true;		

		        // events		
		        private var _selected:Array = []; // list of selections		
		       	private var _selectedState:Boolean = false;
		
		        // - calculated		
		        private var _columnLabelHeight:int = 0; // how tall is the tallest column label		
		        private var _rowLabelWidth:int = 0; // how wide is the widest row label		
		        private var _heatMapHeight:int = 0;	
		        private var _heatMapWidth:int = 0;
		        private var _heatMapTopLeftPoint:Object = { x: 0, y: 0 };	
		        private var _heatMapBottomRightPoint:Object = { x: 0, y: 0 };
		        private var _numDataColumns:int = 0;		
		        private var _numColumns:int = 0;		
		        private var _numRows:int = 0;	
		        private var _dataRange:Object = { min: null, max: null };	
		        private var _colorStep:Object = { r: null, g: null, b: null, a: null };
				private var _discreteColorRange:discretecolorrange;
				

				
                
               
                
                //constructor
                public function bioheatmap(){
            		super();

                }
          
                public override function draw(dataJSON:String,optionsJSON:String):void
                {
                	this._log("Draw called");
                	this.myData = new org.systemsbiology.visualization.data.DataView(dataJSON,"");

                	this.options = JSON.decode(optionsJSON);
                	
                	//set up defaults
                	this._log("Setting Options and Data Range");
                	this._setOptionDefaults(this.options);
                	this._calcDataRange(this.myData);
                	
              		this._log("Loading Color Range...");
		            this._discreteColorRange = new org.systemsbiology.visualization.bioheatmap.discretecolorrange(this._maxColors, this._dataRange, { maxColor: this._maxColor,
			                minColor: this._minColor,
			                emptyDataColor: this._emptyDataColor,
			                passThroughBlack: this._passThroughBlack,
			                specialValueColors: this._specialValueColors
			            });
			            
			            
			        this._log("Setting Layout Options");    
					if (this._fixedSpriteSize) {
		
		                this._setDefaultsByHeatMapSize(myData);
		
		            } else {
		
		                this._setDefaultsByCellSize(myData);
		
		            }
					this._log("resize");
					this.resizeContainer(Math.ceil(this._SpriteWidth+this._columnLabelHeight*.85),this._SpriteHeight);


					this._log("Creating Sprites"); 
                	this._colSprite = new Sprite();
                	this._colSprite.y=0;
                	this._colSprite.x=this._rowLabelWidth + this._rowLabelRightPadding + this._horizontalPadding;

					this._rowSprite = new Sprite();
                	this._rowSprite.y=this._columnLabelHeight*.85+this._columnLabelBottomPadding;// + this._verticalPadding;
                	this._rowSprite.x=this._horizontalPadding;

                	
                	this._mapSprite = new Sprite();
                    
                	this._mapSprite.y=this._columnLabelHeight*.85+this._columnLabelBottomPadding;//+ this._verticalPadding;
                	this._mapSprite.x=this._rowLabelWidth + this._rowLabelRightPadding+this._horizontalPadding;
                	
                	this._selectionSprite = new Sprite();
                    
                	this._selectionSprite.y=this._columnLabelHeight*.85+this._columnLabelBottomPadding;//+ this._verticalPadding;
                	this._selectionSprite.x=this._rowLabelWidth + this._rowLabelRightPadding+this._horizontalPadding;
					
                    this._log("adding kids"); 
					
					addChild(this._rowSprite);
					addChild(this._colSprite);
					addChild(this._mapSprite);
					addChild(this._selectionSprite);

                	// Draw heatmap                	
					this._log("Drawing...");
		            var colStartIndex : int = this._useRowNames ? 1 : 0;
		            var rowNameIndex : int = 0;
		            
		           	if (!this._hideHeaders) 
		           	{
		           		if(!this._hideColHeaders)
		           			this._drawColumLabels(colStartIndex); // draw column names
		           		if(!this._hideRowHeaders)
		           			this._drawRowLabels(rowNameIndex); // draw row names if present
		           	}
		
		            for (var row : int = 0; row < myData.getNumberOfRows(); row++) {
						this._log("Row: "+ row + " of " + this._numRows);

		                for (var col : int = colStartIndex; col < myData.getNumberOfColumns(); col++) {
		                	this._log("Col: "+ col +  " of " + myData.getNumberOfColumns());
						
		                    this._drawHeatMapCell(row, col);
		                
		                }
					}
					
					
			
			//this.network.controls.add(ttc);
					


                }
                
                 private function _calcDataRange(data:Object):void
                {
                	
			        // determine the data range if needed
			        var colStartIndex : int = this._useRowNames ? 1 : 0; // skip row label
			        if ((!this._dataRange.min && this._dataRange.min != 0) || (!this._dataRange.max && this._dataRange.max != 0)) {
			            for (var col : int = colStartIndex; col < this.myData.getNumberOfColumns(); col++) {
			                var colRange : * = this.myData.getColumnRange(col);
			                var min : Number = Number(colRange.min);
			                var max : Number = Number(colRange.max);
			                this._dataRange.min = this._dataRange.min != null ? this._dataRange.min : min;
			                if (this._dataRange.min > min)
			                    this._dataRange.min = min;
			                this._dataRange.max = this._dataRange.max != null ? this._dataRange.max : max;
			                if (this._dataRange.max < max)
			                    this._dataRange.max = max;
			                
			            }
			        }
    			}



			    // ------------------------------------
			    // Setup Helper Functions
			    // ------------------------------------
			

			    private function _drawColumLabels(colStartIndex: int): void {
			
			        for (var col : int = colStartIndex; col < this.myData.getNumberOfColumns(); col++) {
			
			            var colName : String = this.myData.getColumnLabel(col);
			
			            var bottomLeftPoint : Object = this._getCellXYTopLeft(0, col);
			
			            bottomLeftPoint.y = this._columnLabelHeight*.85 /*+ this._verticalPadding*/-this._columnLabelBottomPadding;
			
			            var centerX : int = Math.round(this._cellWidth / 2 + (this._fontHeight / 2) - 1);
		                var linkUrl:String = this._columnBaseUrl==""?"":this._columnBaseUrl+this.myData.getColumnId(col);
		                
		                var colSprite : ColLabel = new ColLabel(col,colName,this._columnLabelHeight+this._verticalPadding, linkUrl, this._labelTextFormat);

		                colSprite.x = bottomLeftPoint.x;
		                colSprite.y = bottomLeftPoint.y;
		                
		                colSprite.addEventListener(MouseEvent.CLICK,this._selectionHandeler);
		                this._colSprite.addChild(colSprite);

			
			            
			        }
			
			    }
			
			
			
			    private function _drawRowLabels(rowNameIndex : int) : void {
					if (this._useRowNames) {
			
			            for (var row : int = 0; row < this._numRows; row++) {
			
			                var rowName : String = this._getValueFormattedOrNot(row, rowNameIndex);
			
			                var topLeftPoint : Object = this._getCellXYTopLeft(row, rowNameIndex);
			
			                var linkUrl:String = this._rowBaseUrl==""?"":this._rowBaseUrl+this.myData.getValue(row,rowNameIndex);
			                var rowSprite : RowLabel = new RowLabel(row, rowName, this._rowLabelWidth+this._rowLabelRightPadding, linkUrl, this._labelTextFormat);

			                rowSprite.x = topLeftPoint.x;
			                rowSprite.y = topLeftPoint.y;
			                rowSprite.addEventListener(MouseEvent.CLICK,this._selectionHandeler)
			                
			                this._rowSprite.addChild(rowSprite);

			            }			
			        }			
			    }
			
			
			
			    private function _drawHeatMapCell(row : int, col : int) : void {
					
			        var cellValue : String = this._getValueFormattedOrNot(row, col);			        
			        var topLeftPoint : Object = this._getCellXYTopLeft(row, col);
			        var fillString : String = this._discreteColorRange.getCellColorHex(cellValue); 
					cellValue = cellValue == null ? "NA" : cellValue;
					
					var toolTip : String  = "";
										
					toolTip += _cellToolTipType == "headers" ? this.myData.getColumnLabel(col) + "\n"  : "";
					toolTip += (_cellToolTipType == "headers" && _useRowNames) ? this._getValueFormattedOrNot(row, 0) + "\n"  : "";
					toolTip += (_cellToolTipType && _cellToolTipType!="none")? cellValue : "";
					
					cellValue = this._useCellLabels ? cellValue : "";
					var linkUrl:String = this._cellBaseUrl==""?"":this._cellBaseUrl+this.myData.getValue(row,col);
					
					var cellSprite : HeatMapCell = new HeatMapCell(row, col,this._cellHeight, this._cellWidth, cellValue, toolTip, fillString, linkUrl, this._labelTextFormat);
              
                   cellSprite.x = topLeftPoint.x;
                   cellSprite.y = topLeftPoint.y;
                   
                   cellSprite.addEventListener(MouseEvent.CLICK,this._selectionHandeler);

                    this._mapSprite.addChild(cellSprite);

			
			    }
			    
			    
				public override function selectionSetViaJS(selection : String) : void
				{
					super.selectionSetViaJS(selection);
					
					//if flash clear selection display in 500 ms
					if (this._selectionDisplay.mode == "flash") setTimeout(_clearSelection, 500);
					
				}
				
				//clears the selection in the AS context
				protected override function _clearSelection() : void {
					while(this._selectionSprite.numChildren > 0){
  						this._selectionSprite.removeChildAt(0);
					}
					
			    }			    
			    
			    //these 3 functions  do the actuall selecting in the AS context (display)
			    protected override function _setSelectionCell(row : *, col : *) : void {
					this._log("cell selected");
					var topLeftPoint : Object = this._getCellXYTopLeft(row, col);
					this._drawSelectionRect(topLeftPoint.x,topLeftPoint.y,this._cellWidth,this._cellHeight);
			    }
			    
			    protected override function _setSelectionCol(col : *) : void {
			    	var topLeftPoint : Object = this._getCellXYTopLeft(0, col);
			    	this._drawSelectionRect(topLeftPoint.x,topLeftPoint.y,this._cellWidth,this._heatMapHeight);


			    }
			    
			    protected override function _setSelectionRow(row : *) : void {
			    	var topLeftPoint : Object = this._getCellXYTopLeft(row, 1);
			    	this._drawSelectionRect(0,topLeftPoint.y,this._heatMapWidth,this._cellHeight);
			    }
			    

			    
			    
			    
			    private function _drawSelectionRect(x : int, y : int, width : int, height : int) : void {
			    	if (this._selectionDisplay.mode == "none") return;
			    	
			    	var cellShape : Shape = new Shape()
			    	var num : String = this._discreteColorRange.ObjtoHex(this._selectionDisplay.border.color);
					cellShape.graphics.beginFill(int("0x"+this._discreteColorRange.ObjtoHex(this._selectionDisplay.fill.color)),this._selectionDisplay.fill.color.a)
		    		cellShape.graphics.lineStyle(this._selectionDisplay.border.width, int("0x"+this._discreteColorRange.ObjtoHex(this._selectionDisplay.border.color)),this._selectionDisplay.border.color.a);
		    		cellShape.graphics.drawRect(x,y,width,height);
		    		cellShape.graphics.endFill();
		    		
		    		this._selectionSprite.addChild(cellShape);
		    		


			    }
			

				private function _setOptionDefaults(options:Object):void
				{
			
					// PUBLIC options
					if(options.dataMin)
						this._dataRange.min=options.dataMin;
					if(options.dataMax)
						this._dataRange.max=options.dataMax;	
					if (options.noRowNames)
						this._useRowNames = false;
					if (options.startColor)
						this._minColor = options.startColor;
					if (options.endColor)
						this._maxColor = options.endColor;
					if (options.emptyDataColor)
						this._emptyDataColor = options.emptyDataColor;
					if (options.numberOfColors)
						this._maxColors = options.numberOfColors;
					if (options.passThroughBlack != null && options.passThroughBlack == false)
						this._passThroughBlack = false;
					else if (options.passThroughBlack == true)
						this._passThroughBlack = true;
					if (options.lockHeaders != null && options.lockHeaders == false)
						this._lockHeaders = false;
					else if (options.lockHeaders == true)
						this._lockHeaders = true;
					if (options.hideHeaders == true)
						this._hideHeaders = true;
					if (options.hideColHeaders == true)
						this._hideColHeaders = true;
					if (options.hideRowHeaders == true)
						this._hideRowHeaders = true;
					if (options.useRowLabels != null && options.useRowLabels == false)
						this._useRowNames = false;
					else if (options.useRowLabels == true)
						this._useRowNames = true;
					if (options.useCellLabels != null && options.useCellLabels == false)
						this._useCellLabels = false;
					else if (options.useCellLabels == true)
						this._useCellLabels = true;
					
					if(options.rowBaseUrl)
					{
						this._rowBaseUrl=options.rowBaseUrl;
					}
					if(options.columnBaseUrl)
					{
						this._columnBaseUrl=options.columnBaseUrl;
					}
					if(options.cellBaseUrl)
					{
						this._cellBaseUrl=options.cellBaseUrl;
					}
					
					if(options.cellToolTips)
					{
						this._cellToolTipType=options.cellToolTips;
					}
					
			
					// height/width stuff
			
					if (options.cellWidth)
						this._cellWidth = options.cellWidth;
					if (options.cellHeight)
						this._cellHeight = options.cellHeight;
					if (options.mapWidth)
						this._SpriteWidth = options.mapWidth;
					if (options.mapHeight)
						this._SpriteHeight = options.mapHeight;
					if (options.mapHeight && options.mapWidth)
						this._fixedSpriteSize = true;
					if (options.fontHeight > 0)
					{
						this._fontHeight = options.fontHeight;
						this._labelTextFormat.size = options.fontHeight;
					}
			
					// padding
			
					if (options.horizontalPadding)
						this._horizontalPadding = options.horizontalPadding;
					if (options.horizontalPadding)
						this._verticalPadding = options.horizontalPadding;
					if (options.cellBorder)
						this._cellBorder = options.cellBorder;
			
			
			
					if (options.drawBorder != null && options.drawBorder == false)
						this._drawHeatmapBorder = false;
					else if (options.drawBorder == true)
						this._drawHeatmapBorder = true;
						
					if (options.selectionDisplay)
					{
						this._selectionDisplay.mode = options.selectionDisplay.mode;
						
						if(options.selectionDisplay.fill)
						{
						this._selectionDisplay.fill.color = options.selectionDisplay.fill.color || this._selectionDisplay.fill.color;
						
						}
						
						if(options.selectionDisplay.border)
						{
							this._selectionDisplay.border.color = options.selectionDisplay.border.color || this._selectionDisplay.border.color;
							this._selectionDisplay.border.width = options.selectionDisplay.border.width || this._selectionDisplay.border.width;
						
						}
						
					}
			
					// TODO : more OPTIONAL PARAMETERS?
					// - Row normalize the data to average of 0 and variance +/-1?
			
				}
				
				// calculates default variables based on a specified cell size

			    private function _setDefaultsByCellSize(myData: Object) : void {
			
			        // set h/w if available. otherwise use defaults		
			        if (this.options.cellHeight) {			
			            this._cellHeight = this.options.cellHeight;			
			        }			
			        if (this.options.cellWidth) {			
			            this._cellWidth = this.options.cellWidth;			
			        }			
			        this._calcDataDefaults(myData);			
			        this._calcLabelLengths();
		
			        // calculate the w/h of the heatmap without row or column labels		
			        this._heatMapHeight = this._cellHeight * this._numRows;			
			        this._heatMapWidth = this._cellWidth * this._numDataColumns;					
			
			        // calculate the Sprite's width/height			
			        this._SpriteWidth = this._rowLabelWidth + this._heatMapWidth + (2 * this._horizontalPadding);			
			        this._SpriteHeight = this._columnLabelHeight*.85 + this._heatMapHeight + (2*this._columnLabelBottomPadding);			
			        this._checkCellAndFontSizes();
			
			    }
			
			
			
			    // calculates default variables based on a specified heatmap size
			
			    private function _setDefaultsByHeatMapSize(myData: Object) : void{			

			        // check for reasonable bounds, otherwise call default method			
			        if (!this._SpriteHeight > 0 || !this._SpriteWidth > 0)			
			            this._setDefaultsByCellSize(myData);
								
			        this._calcDataDefaults(myData);			
			        this._calcLabelLengths();
			
			
			
			        // calculate the width of the heatmap
			
			        this._heatMapHeight = this._SpriteHeight - this._columnLabelHeight*.85;// - (2 * this._verticalPadding);			
			        this._heatMapWidth = this._SpriteWidth - this._rowLabelWidth - (2 * this._horizontalPadding);
			
			
			
			        // calculate the cell dimension
			
			        var maxCellWidth : Number = Math.floor(this._heatMapWidth / this._numDataColumns);			
			        var maxCellHeight : Number = Math.floor(this._heatMapHeight / this._numRows);		
			        var cellDimension : Number = 0;
			
			        if (maxCellWidth < maxCellHeight) {		
			            cellDimension = maxCellWidth;		
			        } else {		
			            cellDimension = maxCellHeight;			
			        }
			
			        this._cellWidth = cellDimension;			
			        this._cellHeight = cellDimension;
			        
			        this._heatMapHeight = this._cellHeight * this._numRows;			
			        this._heatMapWidth = this._cellWidth * this._numDataColumns;		
			
			        
			        this._checkCellAndFontSizes();
			
			    }
			
			
			
			
			
			    // checks to make sure font and cell sizes will play nice together on the screen
			
			    private function _checkCellAndFontSizes(): void {
			
			      
			
			    }
			
			
			
			
			
			    // -----------------------------------			
			    // Calculation Helper Functions			
			    // ------------------------------------	
			
			    // sets the row/col counts and (future: set data ranges)
			
			    private function _calcDataDefaults(myData: Object): void {			
			        this._numRows = myData.getNumberOfRows();			
			        this._numColumns = myData.getNumberOfColumns();			
			        this._numDataColumns = myData.getNumberOfColumns();
			
			        if (this._useRowNames) {			
			            this._numDataColumns--;			
			        }
			
			    }
			
			
			
			    // determines the max width of the row labels
			
			    private function _calcLabelLengths() : void {
			    	this._log("calc label lengths"); 
					if(this._hideHeaders)
					{
						this._rowLabelWidth=0;
						this._columnLabelHeight=0;
						return;
					}    
			
			        var  rowLabelIndex : int = 0;
			        var textField : TextField = new TextField();
			        
			        textField.defaultTextFormat = this._labelTextFormat;
					this._log( "rows"); 
			
			        for (var row : int = 0; row < this.myData.getNumberOfRows(); row++) {
						this._log("row " + row); 
			            var rowName : String = this._getValueFormattedOrNot(row, rowLabelIndex);
			            this._log("data " + rowName); 
						textField.text = rowName;
						 
						
			            var rowNameWidth: Number = textField.textWidth;
						this._log(textField.text+" textWidth: "+textField.textWidth);//+" measuredWidth :"+textField.measuredWidth);
						
			            if (rowNameWidth > this._rowLabelWidth) {
			
			                this._rowLabelWidth = Math.ceil(rowNameWidth);
			
			            }
			
			        }
			        
					var colStartIndex : int = this._useRowNames ? 1 : 0;
					
					this._log("cols");
					var sin45 : Number = 0.7071068;
			        for (var col : int = colStartIndex; col < myData.getNumberOfColumns(); col++) {
			
			            var colName : String = myData.getColumnLabel(col);
						textField.text = colName;
			           // var colNameWidth: Number = textField.textWidth;
						//var colNameHeight: Number = textField.textHeight;
						var angledHeight: Number = (textField.textWidth+textField.textHeight);
						//this._log(textField.text+" textWidth: "+textField.textWidth);//+" measuredWidth :"+textField.measuredWidth);
			            if (angledHeight > this._columnLabelHeight) {
			
			                this._columnLabelHeight = Math.ceil(angledHeight);
			
			            }
			        }
			        if(this._hideColHeaders)
					{
						this._columnLabelHeight=0;
					}   
					if(this._hideRowHeaders)
					{
						this._rowLabelWidth=0;
					}   
			        this._log("done"); 
			    }
			
			
			
			    // returns which col contains this point
			
			    private function _getColFromXY(point : Object) : int {
			
			        // calc col
			
			        var xDist : Number = point.x; // - this._heatMapTopLeftPoint.x;
			
			        if (xDist >= 0) {
			
			            
			
			            var xCol : int = Math.floor(xDist / this._cellWidth);
			
			            if (xDist % this._cellWidth > 0)
			
			                xCol++;
			
			            if (!this._useRowNames) xCol--; // for zero indexing
			
			            if (xCol < this._numColumns)
			
			                return xCol;
			
			        }
			        
			        return -1
			
			    }
			
			
			
			    // returns which row contains this point. returns -1 for column header selection
			
			    private function _getRowFromXY(point:Object) : int{
			
			        // calc row
			
			        var yDist : Number = point.y - this._heatMapTopLeftPoint.y;
			
			        if (yDist >= 0) {
			
			            if (false && yDist - this._columnLabelHeight < 0) {
			
			                // user selected column header.
			
			                return -1;
			
			            } else {
			
			                //yDist -= this._columnLabelHeight;
			
			                var yRow : int = Math.floor(yDist / this._cellHeight);
			
			                if (yDist % this._cellHeight > 0)
			
			                    yRow++;
			
			                yRow--; // for zero indexing
			
			                if (yRow < this._numRows)
			
			                    return yRow;
			
			            }
			
			        }
			        
			        return -1;
			
			    }
			
			
			
			    // returns which cell(row/col) contains this point
			
			    private function _getCellFromXY(point : Object) : Object {
			
			        // if within heatmap
			
			        var row : int= this._getRowFromXY(point);
			
			        var col : int = this._getColFromXY(point);
			
			        var cell : Object= { row: row, col: col };
			
			
			
			        
			        if ((cell.row >= 0 || cell.row == -1) && cell.col >= 0)
			
			            return cell;
			            
			            
			        return null;
			
			    }
			
			
			
			
			
			    // ------------------------------------
			
			    // Random helper Functions
			
			    // ------------------------------------
			
			
			
			    // returns the top left position (x,y) of a cell (row,col)
			
			    private function _getCellXYTopLeft(row : int, col : int) : Object {
			
			        var point : Object = { x: 0, y: 0 };
			
			        if (col != 0 && this._useRowNames) {
			
			            //point.x = this._rowLabelWidth;
			
			            col--; // because we've added the "special" first column already
			
			        }
			
			        point.x = point.x + this._heatMapTopLeftPoint.x + col * this._cellWidth;
			
			        point.y = this._heatMapTopLeftPoint.y + row * this._cellHeight; //+ this._columnLabelHeight
			
			        return point;
			
			    }
			
			
			
			    private function _displayError(message : String) : void {
			

			    }
			
			    private function randInt(min : int, max : int) : int {
			
			        if (max) {
			
			            return Math.floor(Math.random() * (max - min + 1)) + min;
			
			        } else {
			
			            return Math.floor(Math.random() * (min + 1));
			
			        }
			
			    }
			
			
			
			    private function _getValueFormattedOrNot(row : int, col : int) : String {
			    	var returnValue : String;
			    	if(this.myData.getFormattedValue(row,col)!=undefined){
			    		returnValue = this.myData.getFormattedValue(row,col)
			    	}
			    	else
			    	{
			    		returnValue = this.myData.getValue(row,col);
			    	}
			    		
					return returnValue;
			    }
        }
}