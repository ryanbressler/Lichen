package org.systemsbiology.visualization.data
{



public class DataView {
    private var dataTable:DataTable;
    private var table2ViewColumnIndex:Object;
    private var view2TableColumnIndex:Object;
    private var columnIndicies:Array;

    public function DataView(dataJSON:String, isGoogle:String) {
        this.dataTable = new DataTable();
        if(isGoogle) {
        	this.dataTable.importGoogleDataTableJSON(dataJSON);
        } else {
        	this.dataTable.importDataJSON(dataJSON);
        }
        		
        // setup initial mapping
        var dataTableNumCols:int = this.dataTable.getNumberOfColumns();
        this.columnIndicies = new Array();
        this.table2ViewColumnIndex = new Object();
        this.view2TableColumnIndex = new Object();

        for(var col:int=0; col<dataTableNumCols; col++) {
            this.columnIndicies.push(col);
            this.table2ViewColumnIndex[col] = col;
            this.view2TableColumnIndex[col] = col;
        }
    }

    // THESE ARE DataView SPECIFIC:
    
    public function getTableColumnIndex(viewColumnIndex:int) :int {
        return this.view2TableColumnIndex[viewColumnIndex];
    }

    public function getViewColumnIndex(tableColumnIndex:int) :int {
        if(this.table2ViewColumnIndex[tableColumnIndex] >=0) {
            return this.table2ViewColumnIndex[tableColumnIndex];
        }
        return -1;
    }

    public function setColumns(columnIndicies:Array) :void {
        if(!columnIndicies || columnIndicies.length<0 || columnIndicies.length>this.dataTable.getNumberOfColumns()) {
            //Debug.trace("ERROR - setColumns: columnIndicies out of bounds");
            //Debug.traceObj(columnIndicies);
        }
        this.columnIndicies = columnIndicies;
        this.table2ViewColumnIndex = new Object();
        this.view2TableColumnIndex = new Object();
        for(var colindex:int=0; colindex<columnIndicies.length; colindex++) {
            this.table2ViewColumnIndex[columnIndicies[colindex]] = colindex;
            this.view2TableColumnIndex[colindex] = columnIndicies[colindex];
        }
    }
    

    // pass through functions to DataTable:

    public function getColumnId(columnIndex:int) :* {
        return this.dataTable.getColumnId(this.getViewColumnIndex(columnIndex));
    }

    public function getColumnLabel(columnIndex:int) :String {
        return this.dataTable.getColumnLabel(this.getViewColumnIndex(columnIndex));
    }

    public function getColumnPattern(columnIndex:int) :String {
        return this.dataTable.getColumnPattern(this.getViewColumnIndex(columnIndex));
    }

    public function getColumnProperty(columnIndex:int, name:String) :* {
        return this.dataTable.getColumnProperty(this.getViewColumnIndex(columnIndex), name);
    }

    public function getColumnRange(columnIndex:int) :Object {
        return this.dataTable.getColumnRange(this.getViewColumnIndex(columnIndex));
    }

    public function getColumnType(columnIndex:int) :String {
        return this.dataTable.getColumnType(this.getViewColumnIndex(columnIndex));
    }

    public function getDistinctValues(columnIndex:int) :Array {
        return this.dataTable.getDistinctValues(this.getViewColumnIndex(columnIndex));
    }

    public function getFilteredRows(filters:Array) :void {
       // Debug.trace("WARNING - DataView.as: method NYI");
        //return this.dataTable.getFilteredRows(filters);
    }

    public function getFormattedValue(rowIndex:int, columnIndex:int) :* {
        return this.dataTable.getFormattedValue(rowIndex, this.getViewColumnIndex(columnIndex));
    }

    public function getNumberOfColumns() :int {
    	return this.columnIndicies.length;
    }

    public function getNumberOfRows() :int {
        return this.dataTable.getNumberOfRows();
    }

    public function getProperty(rowIndex:int, columnIndex:int, name:String) :* {
        return this.dataTable.getProperty(rowIndex, this.getViewColumnIndex(columnIndex), name);
    }

    public function getSortedRows(sortColumns:Array) :void {        
       // Debug.trace("WARNING - DataView.as: method NYI");
        //return this.dataTable.getSortedRows(sortColumns);
    }

    public function getValue(rowIndex:int, columnIndex:int) :* {
        return this.dataTable.getValue(rowIndex, this.getViewColumnIndex(columnIndex));
    }

}
}

