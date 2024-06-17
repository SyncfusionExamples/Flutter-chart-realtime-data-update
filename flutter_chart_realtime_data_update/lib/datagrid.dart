import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource(
      this.employees, this._updateChartData, this._updateChartSorting) {
    _dataGridRows = employees
        .map<DataGridRow>((dataGridRow) => dataGridRow.buildDataGridRow())
        .toList();
  }

  List<Employee> employees = [];
  int editedRowIndex = -1;
  String? sortedColumnName;
  DataGridSortingOrder sortDirection = DataGridSortingOrder.none;
  dynamic newCellValue;

  List<DataGridRow> _dataGridRows = [];
  final VoidCallback _updateChartData;
  final VoidCallback _updateChartSorting;
  DataGridSortingOrder _previousSortDirection = DataGridSortingOrder.none;
  final TextEditingController _editingController = TextEditingController();

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>(
      (dataGridCell) {
        String value = dataGridCell.value.toString();
        if (dataGridCell.columnName == 'yValue') {
          value = double.parse(value).toString();
        }

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    ).toList());
  }

  @override
  Future<void> onCellSubmit(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column) async {
    final dynamic oldValue = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value ??
        '';

    final int dataRowIndex = _dataGridRows.indexOf(dataGridRow);

    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }

    editedRowIndex = dataRowIndex;

    if (column.columnName == 'name') {
      _dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'name', value: newCellValue);
      employees[dataRowIndex].name = newCellValue.toString();
    } else if (column.columnName == 'yValue') {
      num? yValue = newCellValue as num?;
      _dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<num?>(columnName: 'yValue', value: yValue);
      employees[dataRowIndex].yValue = yValue;
    }

    _updateChartData.call();
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    final String displayText = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value
            ?.toString() ??
        '';

    newCellValue = null;
    final bool isNumericType = column.columnName == 'yValue';
    final RegExp regExp = _regExp(isNumericType, column.columnName);

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: isNumericType ? Alignment.centerRight : Alignment.centerLeft,
      child: TextField(
        controller: _editingController..text = displayText,
        textAlign: isNumericType ? TextAlign.right : TextAlign.left,
        autofocus: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 8.0),
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(regExp)
        ],
        keyboardType: isNumericType ? TextInputType.number : TextInputType.text,
        onChanged: (String value) {
          if (value.isNotEmpty) {
            if (isNumericType) {
              newCellValue = double.parse(value);
            } else {
              newCellValue = value;
            }
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) {
          submitCell();
        },
      ),
    );
  }

  RegExp _regExp(bool isNumericKeyBoard, String columnName) {
    return isNumericKeyBoard ? RegExp('[0-9.]') : RegExp('[a-zA-Z ]');
  }

  @override
  Future<void> performSorting(List<DataGridRow> rows) {
    if (sortedColumns.isNotEmpty) {
      sortedColumnName = sortedColumns[0].name;
      sortDirection =
          sortedColumns[0].sortDirection == DataGridSortDirection.ascending
              ? DataGridSortingOrder.ascending
              : DataGridSortingOrder.descending;
    } else {
      sortedColumnName = null;
      sortDirection = DataGridSortingOrder.none;
    }

    if (_previousSortDirection != sortDirection) {
      _updateChartSorting.call();
      _previousSortDirection = sortDirection;
    }
    return super.performSorting(rows);
  }
}

class Employee {
  Employee(this.name, this.yValue);

  String? name;
  num? yValue;

  DataGridRow buildDataGridRow() {
    return DataGridRow(cells: <DataGridCell>[
      DataGridCell<String>(columnName: 'name', value: name),
      DataGridCell<num?>(columnName: 'yValue', value: yValue),
    ]);
  }
}

enum DataGridSortingOrder { ascending, descending, none }
