import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:charts_with_datagrid/datagrid.dart';

void main() {
  runApp(const MaterialApp(
    home: SfChartWithDataGridDemo(),
    debugShowCheckedModeBanner: false,
  ));
}

class SfChartWithDataGridDemo extends StatefulWidget {
  const SfChartWithDataGridDemo({super.key});

  @override
  SfChartWithDataGridDemoState createState() => SfChartWithDataGridDemoState();
}

class SfChartWithDataGridDemoState extends State<SfChartWithDataGridDemo> {
  final List<Employee> _employees = <Employee>[
    Employee('Lara', 80),
    Employee('James', 60),
    Employee('Kathryn', 45),
    Employee('Michael', 65),
    Employee('Charlie', 25),
    Employee('Jack', 50),
    Employee('Balnc', 30),
    Employee('David', 70),
    Employee('Valentino', 55),
  ];
  late EmployeeDataSource _employeeDataSource;
  DataGridController dataGridController = DataGridController();
  VoidCallback? updateChart;
  VoidCallback? updateSorting;
  SortingOrder _sortingOrder = SortingOrder.none;
  String _sortby = 'x';
  bool allowDataEditing = false;
  ChartSeriesController<Employee, String>? seriesController;

  @override
  void initState() {
    super.initState();
    updateChart = _updateDataSource;
    updateSorting = _updateSorting;

    _employeeDataSource =
        EmployeeDataSource(_employees, context, updateChart!, _updateSorting);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar:
          AppBar(title: const Text('Syncfusion Flutter Charts with DataGrid')),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: width * 0.75,
                    height: height,
                    child: _buildLineChart(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: width * 0.2,
                      height: height,
                      child: _buildDataGrid(allowDataEditing: allowDataEditing),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () => {
                  setState(() {
                    allowDataEditing = !allowDataEditing;
                  })
                },
                child: const Text('Edit Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SfDataGrid _buildDataGrid({bool allowDataEditing = false}) {
    const TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold);
    return SfDataGrid(
      columnWidthMode: ColumnWidthMode.fill,
      source: _employeeDataSource,
      controller: dataGridController,
      allowEditing: allowDataEditing,
      navigationMode: GridNavigationMode.cell,
      selectionMode: SelectionMode.single,
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      allowSorting: allowDataEditing,
      allowTriStateSorting: allowDataEditing,
      columns: <GridColumn>[
        GridColumn(
          columnName: 'name',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text('Name',
                style: textStyle, overflow: TextOverflow.ellipsis),
          ),
        ),
        GridColumn(
          columnName: 'yValue',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text('Value',
                style: textStyle, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }

  SfCartesianChart _buildLineChart() {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(),
      primaryYAxis: const NumericAxis(
        minimum: 0,
        maximum: 100,
      ),
      series: <ColumnSeries>[
        ColumnSeries<Employee, String>(
          color: const Color.fromRGBO(99, 85, 199, 1),
          dataSource: _employeeDataSource.employees,
          xValueMapper: (Employee employee, _) => employee.name,
          yValueMapper: (Employee employee, _) => employee.yValue,
          sortingOrder: _sortingOrder,
          sortFieldValueMapper: (Employee employee, _) =>
              _sortby == 'name' ? employee.name : employee.yValue,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          markerSettings: const MarkerSettings(isVisible: true),
          onRendererCreated: (controller) {
            seriesController = controller;
          },
        ),
      ],
    );
  }

  void _updateDataSource() {
    int editedDataIndex = _employeeDataSource.editedRowIndex;
    seriesController?.updateDataSource(updatedDataIndex: editedDataIndex);
  }

  void _updateSorting() {
    setState(
      () {
        _sortingOrder =
            _employeeDataSource.sortDirection == DataGridSortingOrder.ascending
                ? SortingOrder.ascending
                : _employeeDataSource.sortDirection ==
                        DataGridSortingOrder.descending
                    ? SortingOrder.descending
                    : SortingOrder.none;
        _sortby = _employeeDataSource.sortedColumnName.toString();
      },
    );
  }

  @override
  void dispose() {
    updateChart = null;
    super.dispose();
  }
}
