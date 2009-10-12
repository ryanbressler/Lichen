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
	//import com.hexagonstar.util.debug.Debug;
	
	public class discretecolorrange
    {

    // --------------------------------
    // constants
    // --------------------------------
    
	private var MINCOLORS:int = 2;
	private var PASS_THROUGH_BLACK_MINCOLORS:int = 2;
	private var NO_PASS_THROUGHBLACK_MINCOLORS:int= 2;
	private var MINRGB:int= 0;
	private var MAXRGB:int= 255;
    private var BLACK_RGBA:Object= {r:0, g:0, b:0, a:1};

   // --------------------------------
    // Private Attributes
    // --------------------------------

    // setable option defaults
    private var _maxColors:int= 64; // number of colors to divide space into
    private var _backgroundColor:Object= {r:0, g:0, b:0, a:1};
    private var _maxColor:Object= {r:255, g:0, b:0, a:1};
    private var _minColor:Object= {r:0, g:255, b:0, a:1};
    private var _emptyDataColor:Object= {r:100, g:100, b:100, a:1};
    private var _specialValueColors:Array = [];
    private var _passThroughBlack:Boolean= true;

    // other
    private var _dataRange:Object= {min:null, max:null};
    private var _debug:Boolean= false;
    private var _colorRange:Object= null;

    // calculated
    private var _colorStep:Object= {r:null, g:null, b:null, a:null};
    private var _dataStep:Number= 0;
    private var _maxDataSpace:Number= 0;


    // --------------------------------
    // Public Methods
    // --------------------------------

    // constructor
    public function discretecolorrange(maxColors:int,dataRange:Object,options:Object){
    	this._log("discrete color range initalized");
        // check required parameters
        if(maxColors>=1 && dataRange) {
            this._maxColors = maxColors;
            this._dataRange = dataRange;
        } else {
            throw('Error in org.systemsbiology.visualization.DiscreteColorRange instantiation. required parameters not provided');
        }

        // set optional parameters
        if (options) {
            if(options.maxColor)
                this._maxColor = this.niceRGBAColor(options.maxColor);
            if(options.minColor)
                this._minColor = this.niceRGBAColor(options.minColor);
            if(options.emptyDataColor)
                this._emptyDataColor = this.niceRGBAColor(options.emptyDataColor);
            if(options.passThroughBlack!=null && options.passThroughBlack == false) {
                this._passThroughBlack = false;
            }
            if(options.specialValueColors) {
                this._specialValueColors=options.specialValueColors;
            }
        }
        // setup color space
        this._colorRange = new Array();
        //this._log("calling set up...");
        this._setupColorRange();
        //this._log("returning");

    }


    // when given an RBGA object it returns a canvas-formatted string for that color
    // if the RGBA is empty or ill-defined it returns a string for the empty data color
    public function getCellColorString(dataValue:String):String {
        var colorValue:Object = this.getCellColorRGBA(dataValue);
        var colorString:String;
        if (colorValue.r >= 0 && colorValue.g >= 0 && colorValue.b >= 0 && colorValue.a >= 0) {
            colorString = this.getRgbaColorString(colorValue);
        } else {
            colorString = this.getRgbaColorString(this._emptyDataColor);
        }

//        this._log("Value="+dataValue+", colorString="+colorString);
        return colorString;
    }

    // returns an RBGA object with the color for the given dataValue
    public function getCellColorRGBA(dataValue:String):Object {
        if(dataValue == null) {
            return this._emptyDataColor;
        }
        for(var ii : int = 0; ii<this._specialValueColors.length; ii++)
        {
        	var specialVal : Object = this._specialValueColors[ii];
        	if(dataValue == specialVal.value) {
            	return specialVal.color;
        	}
        }

		var dataNum : Number = Number(dataValue);
        var dataBin : Number = dataNum / this._dataStep;
        var binOffset : Number = this._dataRange.min/this._dataStep;
        var newDataBin : Number = (dataBin - binOffset);
        // round
        if(newDataBin<0)
            newDataBin = Math.ceil(newDataBin);
        else
            newDataBin = Math.floor(newDataBin);

        // assure bounds
        if(newDataBin<0)
            newDataBin=0;
        if(newDataBin>=this._colorRange.length)
            newDataBin = (this._colorRange.length)-1;
        return this._colorRange[newDataBin];
    }

    // returns the Hex color for the given dataValue
    public function getCellColorHex(dataValue:String):String {
        var rgba:Object = this.getCellColorRGBA(dataValue);
        trace(dataValue);
        return this._RGBtoHex(rgba.r, rgba.g, rgba.b);
    }

    public function getRgbaColorString(rgba:Object):String {
        if (rgba.r >= 0 && rgba.g >= 0 && rgba.b >= 0 && rgba.a >= 0) {
            return "rgba(" + rgba.r + "," + rgba.g + "," + rgba.b + "," + rgba.a + ")";
        }
        return "";
    }

    // makes sure each value of the RGBA is in a reasonable range
    public function niceRGBAColor(rgbaColor:Object):Object {
        var newRgbaColor:Object = {r:null, g:null, b:null, a:null};
        newRgbaColor.r = this.niceIndividualColor(rgbaColor.r);
        newRgbaColor.g = this.niceIndividualColor(rgbaColor.g);
        newRgbaColor.b = this.niceIndividualColor(rgbaColor.b);
        if (rgbaColor.a < 0)
            newRgbaColor.a = 0;
        else if (rgbaColor.a > 1)
            newRgbaColor.a = 1;
        else
            newRgbaColor.a = rgbaColor.a
        return newRgbaColor;
    }

    // keeps a value between MINRGB and MAXRGB
    public function niceIndividualColor(individualColor:Number):int {
        if(individualColor<this.MINRGB)
            return this.MINRGB;
        if(individualColor>this.MAXRGB)
            return this.MAXRGB;
        return Math.floor(individualColor);
    }

    // --------------------------------
    // Private Methods
    // --------------------------------

    // maps data ranges to colors
    private function _setupColorRange():void {
        var dataRange:Object = this._dataRange;
        var maxColors:int = this._maxColors;
        var centerColor:Object = this.BLACK_RGBA;
        var colorStep:Object;

        if (maxColors > 256)
            maxColors = 256;
        if (maxColors < 1) {
            maxColors = 1;
        }
        this._maxDataSpace = Math.abs(dataRange.min) + Math.abs(dataRange.max);
        this._log("range max "+dataRange.max+"range min "+dataRange.min + "  max data Space " + this._maxDataSpace + " maxColors " + maxColors)
        this._dataStep = this._maxDataSpace / maxColors;

        if(this._passThroughBlack) {
            // determine the color step for each attribute of the color
            colorStep = {
                r: 2*this._calcColorStep(this._minColor.r, centerColor.r, maxColors),
                g: 2*this._calcColorStep(this._minColor.g, centerColor.g, maxColors),
                b: 2*this._calcColorStep(this._minColor.b, centerColor.b, maxColors),
                a: 2*this._calcColorStep(this._minColor.a, centerColor.a, maxColors)
            };
            this._addColorsToRange(this._minColor,colorStep,maxColors/2);

            colorStep = {
                r: 2*this._calcColorStep(centerColor.r, this._maxColor.r, maxColors),
                g: 2*this._calcColorStep(centerColor.g, this._maxColor.g, maxColors),
                b: 2*this._calcColorStep(centerColor.b, this._maxColor.b, maxColors),
                a: 2*this._calcColorStep(centerColor.a, this._maxColor.a, maxColors)
            };
            this._addColorsToRange(centerColor,colorStep,(maxColors/2)+1);

        } else {
            // single continue range
            colorStep = {
                r: this._calcColorStep(this._minColor.r, this._maxColor.r, maxColors),
                g: this._calcColorStep(this._minColor.g, this._maxColor.g, maxColors),
                b: this._calcColorStep(this._minColor.b, this._maxColor.b, maxColors),
                a: this._calcColorStep(this._minColor.a, this._maxColor.a, maxColors)
            };
            this._addColorsToRange(this._minColor,colorStep,maxColors);
        }

        // calc data step
        this._maxDataSpace = Math.abs(dataRange.min) + Math.abs(dataRange.max);
        trace("calc data space");
        trace(this._maxDataSpace);
        trace(maxColors);
        this._dataStep = this._maxDataSpace / maxColors;

        this._log('dataStep: '+this._dataStep);

    }

    private function _calcColorStep(minColor: Number, maxColor: Number, numberColors: Number): Number {
        if (numberColors <= 0) return 0;
        var numColors : Number = numberColors==1 ? 1 : numberColors-1;
        return ((maxColor - minColor) / numColors);
    }

    // append colors to the end of the color Range, splitting the number of colors up evenly
    private function _addColorsToRange(startColor : Object, colorStep : Object,numberColors: int) : void {
        var currentColor : Object = this.niceRGBAColor(startColor);
        for(var i : int =0; i<numberColors; i++) {
            this._colorRange[this._colorRange.length] = currentColor;
            currentColor = this.niceRGBAColor({
                r: currentColor.r + colorStep.r,
                g: currentColor.g + colorStep.g,
                b: currentColor.b + colorStep.b,
                a: currentColor.a + colorStep.a
            });

        }
    }

    private function _log(message : String) : void {
        //if (this._debug) {
            trace(message);
        //}
    }
	
	public function ObjtoHex(Obj : Object) : String
	{
		return this._RGBtoHex(String(Obj.r), String(Obj.g), String(Obj.b));
	}
    private function _RGBtoHex(R:String,G:String,B:String) : String {
        return this._toHex(R)+this._toHex(G)+this._toHex(B);
    }

    private function _toHex(Num	:String) : String {
        if (Num == null) return "00";
        var N : int = parseInt(Num);
        if (N == 0 || isNaN(N)) return "00";
        N = Math.max(0, N);
        N = Math.min(N, 255);
        N = Math.round(N);
        return "0123456789ABCDEF".charAt((N - N % 16) / 16)
                + "0123456789ABCDEF".charAt(N % 16);
    }

}
}