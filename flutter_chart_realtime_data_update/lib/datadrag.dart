import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final List<ChartData> chartData = <ChartData>[
    ChartData(1, 14),
    ChartData(2, 30),
    ChartData(3, 23),
    ChartData(4, 47),
    ChartData(5, 30),
    ChartData(6, 41),
  ];

  int? pointIndex;
  ChartSeriesController? _chartSeriesController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SfCartesianChart(
          primaryYAxis: const NumericAxis(
            minimum: 0,
            maximum: 50,
          ),
          onChartTouchInteractionMove: (tapArgs) {
            _updateDataPoint(tapArgs);
          },
          onChartTouchInteractionUp: (tapArgs) {
            _updateDataPoint(tapArgs);
            pointIndex = null;
          },
          series: <CartesianSeries<ChartData, num>>[
            LineSeries<ChartData, num>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: const Color.fromRGBO(99, 85, 199, 1),
              markerSettings: const MarkerSettings(isVisible: true),
              onPointLongPress: (pointInteractionDetails) {
                pointIndex = pointInteractionDetails.pointIndex;
              },
              onRendererCreated: (ChartSeriesController controller) {
                _chartSeriesController = controller;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateDataPoint(ChartTouchInteractionArgs tapArgs) {
    if (pointIndex != null) {
      CartesianChartPoint<dynamic> dragPoint =
          _chartSeriesController!.pixelToPoint(tapArgs.position);
      chartData.removeAt(pointIndex!);

      chartData.insert(
          chartData.length - 1, ChartData(dragPoint.x, dragPoint.y as double?));

      _chartSeriesController!.updateDataSource(updatedDataIndex: pointIndex!);
    }
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final num x;
  final double? y;
}
