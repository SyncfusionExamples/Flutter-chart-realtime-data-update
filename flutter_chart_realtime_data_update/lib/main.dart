import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:charts_with_datagrid/datagrid.dart';

void main() {
  runApp(const MaterialApp(
    home: CartesianChart(),
    debugShowCheckedModeBanner: false,
  ));
}

class CartesianChart extends StatefulWidget {
  const CartesianChart({super.key});

  @override
  CartesianChartState createState() => CartesianChartState();
}

class CartesianChartState extends State<CartesianChart> {
  VoidCallback? _updateChart;
  VoidCallback? _updateSorting;
  late EmployeeDataSource _source;
  SortingOrder _sortingOrder = SortingOrder.none;
  String _sortby = 'x';
  ChartSeriesController? _controller;
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

  @override
  void initState() {
    super.initState();
    _updateChart = _updateDataSource;
    _updateSorting = _updateDataSorting;
    _source = EmployeeDataSource(
      _employees,
      _updateChart!,
      _updateSorting!,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            SizedBox(
              width: width * 0.75,
              height: height,
              child: _buildColumnChart(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: width * 0.2,
                height: height,
                child: _buildDataGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SfDataGrid _buildDataGrid() {
    const TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold);
    return SfDataGrid(
      columnWidthMode: ColumnWidthMode.fill,
      source: _source,
      navigationMode: GridNavigationMode.cell,
      selectionMode: SelectionMode.single,
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      allowEditing: true,
      allowSorting: true,
      allowTriStateSorting: true,
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

  SfCartesianChart _buildColumnChart() {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        minimum: 0,
        maximum: 100,
      ),
      series: <ColumnSeries>[
        ColumnSeries<Employee, String>(
          color: const Color.fromRGBO(99, 85, 199, 1),
          dataSource: _source.employees,
          xValueMapper: (Employee employee, int index) => employee.name,
          yValueMapper: (Employee employee, int index) => employee.yValue,
          sortFieldValueMapper: (Employee employee, int index) =>
              _sortby == 'name' ? employee.name : employee.yValue,
          sortingOrder: _sortingOrder,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          onRendererCreated: (ChartSeriesController controller) {
            _controller = controller;
          },
        ),
      ],
    );
  }

  void _updateDataSource() {
    _controller?.updateDataSource(updatedDataIndex: _source.editedRowIndex);
  }

  void _updateDataSorting() {
    setState(
      () {
        _sortingOrder = _source.sortDirection == DataGridSortingOrder.ascending
            ? SortingOrder.ascending
            : _source.sortDirection == DataGridSortingOrder.descending
                ? SortingOrder.descending
                : SortingOrder.none;
        _sortby = _source.sortedColumnName.toString();
      },
    );
  }

  @override
  void dispose() {
    _updateChart = null;
    _updateSorting = null;
    super.dispose();
  }
}
