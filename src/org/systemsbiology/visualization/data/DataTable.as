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

package org.systemsbiology.visualization.data
{
import com.adobe.serialization.json.JSON;



public class DataTable {
    private var columns:Array;
    private var rowData:Array;
    private var columnTypeAbrevationMap:Object = {N:"number", T:"string", B:"boolean", D:"date", S:"datetime", M:"timeofday",
                                                  NUMBER:"number", STRING:"string", BOOLEAN:"boolean", DATE:"date", DATETIME:"datetime", TIMEOFDAY:"timeofday"};

    public function DataTable() {
        this.columns = new Array();
        this.rowData = new Array();
    }

    /*
    * PUBLIC METHODS
    *
    */

    public function importDataJSON(dataJSON:String) :void {
        var decoded:Object = JSON.decode(dataJSON);
        this.importData(decoded.cols, decoded.rows);
    }

    public function importGoogleDataTableJSON(dataJSON:String) :void {
        var decoded:Object = JSON.decode(dataJSON);
		this.importData(decoded.A, decoded.C);
    }

    public function addColumn(type:String, label:String, id:String) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function addRow() :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
        var rowIndex:int=this.getNumberOfRows();
        for (var i:int=0;i<this.getNumberOfColumns(); i++){
        	rowData[rowIndex].c[i] = {v: null};
        }
        
    }
	
	//All the cells of the new rows are assigned a null value.
    public function addRows(numberOfRow:int) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
        for (var i:int=0; i<this.rowData.length; i++){
  			addRow();      
        }
  
    }

    public function clone() :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function getColumnId(columnIndex:int) :* {
        if(this.indexOutOfBounds(this.columns, columnIndex, "ERROR - getColumnId: columnIndex outside of columns bounds")) {
            return undefined;
        }
        return this.columns[columnIndex].id;
    }

    public function getColumnLabel(columnIndex:int) :String {
        if(this.indexOutOfBounds(this.columns, columnIndex, "ERROR - getColumnLabel: columnIndex outside of columns bounds")) {
            return undefined;
        }
        return this.columns[columnIndex].label;
    }

    public function getColumnPattern(columnIndex:int) :String {
        if(this.indexOutOfBounds(this.columns, columnIndex, "ERROR - getColumnPattern: columnIndex outside of columns bounds")) {
            return undefined;
        }
        return this.columns[columnIndex].pattern;
    }

    public function getColumnProperty(columnIndex:int,name:String) :* {
        if(this.indexOutOfBounds(this.columns, columnIndex, "ERROR - getColumnProperty: columnIndex outside of columns bounds")) {
            return undefined;
        }
        if(!this.columns[columnIndex].p) {
            //Debug.trace("ERROR - getColumnProperty: column has no properties");
        }
        return this.columns[columnIndex].p[name];
    }

    public function getColumnRange(columnIndex:int) :Object {
        if(this.indexOutOfBounds(this.columns, columnIndex, "ERROR - getColumnRange: columnIndex outside of columns bounds")) {
            return undefined;
        }
        var range:Object = {min:undefined, max:undefined};
		
        // test that column is type numeric
        var columnType:String = this.getColumnType(columnIndex); 
       // if(columnType == "number") {	
	        for(var row:int=0; row<this.getNumberOfRows(); row++) {
	            var value:* = this.getValue(row, columnIndex);
	            if(value == undefined) continue; // skip undefs in range
	            if(range.min == undefined || range.min>value) {
	                range.min = value;
	            }
	            if(range.max == undefined || range.max<value) {
	                range.max = value;
	            }
	        }
        //}
        return range;
    }

    public function getColumnType(columnIndex:int) :String {
        if(this.indexOutOfBounds(this.columns, columnIndex, "ERROR - getColumnType: columnIndex outside of columns bounds")) {
            return undefined;
        }
        var coltype:String = this.columns[columnIndex].type;
        return this.columnTypeAbrevationMap[coltype.toUpperCase()];
    }

    public function getDistinctValues(columnIndex:int) :Array {
        if(this.indexOutOfBounds(this.columns, columnIndex, "ERROR - getColumnType: columnIndex outside of columns bounds")) {
            return undefined;
        }
        var distinct:Object = new Object();        
        for(var row:int; row<this.rowData.length; row++) {
            var value:* = this.getValue(row,columnIndex);
            if(distinct[value] != 1) {
                distinct[value] = 1;
            }
        }
        var distinctVals:Array = new Array();
        for(var key:String in distinct) {
            distinctVals.push(key);
        }
        return distinctVals;
    }

    public function getFilteredRows(filters:Array) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function getFormattedValue(rowIndex:int, columnIndex:int) :* {
        if(this.indexOutOfBounds(this.columns, columnIndex, "ERROR - getFormattedValue: columnIndex outside of columns bounds")) {
            return undefined;
        }
        if(this.indexOutOfBounds(this.rowData, rowIndex, "ERROR - getFormattedValue: rowIndex outside of bounds")) {
            return undefined;
        }
        var value:* = this.rowData[rowIndex].c[columnIndex].f;
        value = value != "" ? value : undefined;
        return value;
    }

    public function getNumberOfColumns() :int {
        return this.columns.length;
    }

    public function getNumberOfRows() :int {
        return this.rowData.length;
    }

    public function getProperty(rowIndex:int, columnIndex:int, name:String) :* {
        if(this.indexOutOfBounds(this.columns, columnIndex, "ERROR - getProperty: columnIndex outside of columns bounds")) {
            return undefined;
        }
        if(this.indexOutOfBounds(this.rowData, rowIndex, "ERROR - getProperty: rowIndex outside of bounds")) {
            return undefined;
        }

        var value:* = undefined;
        if(!this.rowData[rowIndex].c[columnIndex].p) {
            //Debug.trace("ERROR - getProperty: column has no properties");
        }
        if(!this.rowData[rowIndex].c[columnIndex].p[name]) {
            //Debug.trace("ERROR - getProperty: property: '"+ name +"' does not exist");
        }

        var propval:* = this.rowData[rowIndex].c[columnIndex].p[name];
        return propval; 
    }

    public function getSortedRows(sortColumns:Array) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
        // TODO : need this for full DataView integration
    }

    public function getValue(rowIndex:int, columnIndex:int) :* {
        if(this.indexOutOfBounds(this.columns, columnIndex, "ERROR - getValue: columnIndex outside of columns bounds")) {
            return undefined;
        }
        if(this.indexOutOfBounds(this.rowData, rowIndex, "ERROR - getValue: rowIndex outside of bounds")) {
            return undefined;
        }
        var value:* = this.rowData[rowIndex].c[columnIndex].v;;
        return value;
    }
    

    public function insertColumn(columnIndex:int, type:String, label:String, id:String) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function insertRows(rowIndex:int, numberOfRows:int) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");

    }

    public function removeColumn(columnIndex:int) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function removeColumns(columnIndex:int, numberOfColumns:int) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function removeRow(rowIndex:int) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function removeRows(rowIndex:int, numberOfRows:int) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function setCell(rowIndex:int, columnIndex:int, value:Object, formattedValue:String, properties:Object) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
        // TODO: properties type? hash class?
    }

    public function setColumnLabel(columnIndex:int, label:String) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function setColumnProperty(columnIndex:int, name:String, value:String) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
        // TODO : value string?
    }

    public function setColumnProperties(columnIndex:int, properties:Array) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function setFormattedValue(rowIndex:int, columnIndex:int, formattedValue:String) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function setProperty(rowIndex:int, columnIndex:int, name:String, value:String) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function setProperties(rowIndex:int, columnIndex:int, properties:Object) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function setValue(rowIndex:int, columnIndex:int, value:String) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }

    public function sort(sortColumns:Array) :void {
        //Debug.trace("WARNING - DataTable.as: method NYI");
    }


    /*
     * Private Methods
     */

 	private function importData(columns:Array, rowData:Array) :void {	
        // insure symetrical data between rows & cols
        var errorMsg:String = "";
        var numcols:int = columns.length;
        for(var row:int=0; row<rowData.length; row++) {        	
        	var thisRow:Array = rowData[row].c;
        	if(thisRow.length != numcols) {
        		errorMsg = "ERROR - importData: number of columns not equal in all rows of data";
        	}
        }
        
        // insure all column types are known
        for(var col:int=0; col<columns.length; col++) {
        	var coltype:String = columns[col].type;
        	var coltypeTrans:String = this.columnTypeAbrevationMap[coltype.toUpperCase()]; 
			if(coltypeTrans == null){
				errorMsg = "ERROR - importData: unknown column type: "+ columns[col].type;
			}        	
        }
               
        if(errorMsg != "") {
        	//Debug.trace(errorMsg);
        	this.columns = new Array();
        	this.rowData = new Array();
        	return;
        }
        
        this.columns = columns;
        this.rowData = rowData;
	}

   private function indexOutOfBounds(array:Array, index:int, debugMsg:String) :Boolean {
        if(index<0 || index>=array.length) {
            if(debugMsg) {
                //Debug.trace(debugMsg);
            }
            return true;
        }
        return false;
    }
    
}
}