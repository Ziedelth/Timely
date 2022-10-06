import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timely/extensions.dart';
import 'package:timely/models/working_time.dart';

class StatsView extends StatefulWidget {
  final Iterable<WorkingTime> times;

  const StatsView({required this.times, super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class Data {
  final String day;
  final double data;

  Data(this.day, this.data);
}

class _StatsViewState extends State<StatsView> {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  final List<Series<Data, String>> seriesList = <Series<Data, String>>[];

  double get sum {
    return widget.times.fold(
      0,
      (final double previousValue, final WorkingTime element) =>
          previousValue + element.diffInSecs,
    );
  }

  List<Data> get getDayData {
    // Get all days of times
    final List<String> days = widget.times
        .map((final WorkingTime e) => dateFormat.format(e.startTime))
        .toSet()
        .toList();
    // Get all datas of times
    final List<double> datas = days
        .map(
          (final String e) => widget.times
              .where(
                (final WorkingTime element) =>
                    dateFormat.format(element.startTime) == e,
              )
              .map((final WorkingTime e) => e.diffInSecs / 3600)
              .reduce(
                (final double value, final double element) => value + element,
              ),
        )
        .toList();

    // Get all 15 last days
    final List<String> lastDays =
        days.length > 15 ? days.sublist(days.length - 15, days.length) : days;

    // Get all 15 last datas
    final List<double> lastDatas = datas.length > 15
        ? datas.sublist(datas.length - 15, datas.length)
        : datas;

    // Return all datas
    return List<Data>.generate(
      lastDays.length,
      (final int index) =>
          Data(lastDays[index].split('/').take(2).join('/'), lastDatas[index]),
    );
  }

  List<Data> get getDayDataAverage {
    // Get all days of times
    final List<String> days = widget.times
        .map((final WorkingTime e) => dateFormat.format(e.startTime))
        .toSet()
        .toList();
    // Get all average datas of times
    final List<double> datas = days
        .map(
          (final String e) =>
              widget.times
                  .where(
                    (final WorkingTime element) =>
                        dateFormat.format(element.startTime) == e,
                  )
                  .map((final WorkingTime e) => e.diffInSecs / 3600)
                  .reduce(
                    (final double value, final double element) =>
                        value + element,
                  ) /
              widget.times
                  .where(
                    (final WorkingTime element) =>
                        dateFormat.format(element.startTime) == e,
                  )
                  .length,
        )
        .toList();

    // Get all 15 last days
    final List<String> lastDays =
        days.length > 15 ? days.sublist(days.length - 15, days.length) : days;

    // Get all 15 last datas
    final List<double> lastDatas = datas.length > 15
        ? datas.sublist(datas.length - 15, datas.length)
        : datas;

    // Return all datas
    return List<Data>.generate(
      lastDays.length,
      (final int index) =>
          Data(lastDays[index].split('/').take(2).join('/'), lastDatas[index]),
    );
  }

  @override
  void initState() {
    super.initState();
    seriesList.addAll(<Series<Data, String>>[
      Series<Data, String>(
        id: 'Data',
        colorFn: (final Data _, final int? __) =>
            MaterialPalette.blue.shadeDefault,
        domainFn: (final Data data, final int? _) => data.day,
        measureFn: (final Data data, final int? _) => data.data,
        data: getDayData,
      ),
      Series<Data, String>(
        id: 'Data Average',
        colorFn: (final Data data, final int? __) => MaterialPalette.black,
        domainFn: (final Data data, final int? _) => data.day,
        measureFn: (final Data data, final int? _) => data.data,
        data: getDayDataAverage,
      )..setAttribute(rendererIdKey, 'customLine'),
      Series<Data, String>(
        id: 'Fixed data average',
        colorFn: (final Data data, final int? __) => MaterialPalette.red.shadeDefault,
        domainFn: (final Data data, final int? _) => data.day,
        measureFn: (final Data data, final int? _) => 3.5,
        data: getDayDataAverage,
      )..setAttribute(rendererIdKey, 'customLine'),
    ]);
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: const Text('Statistiques'),
          subtitle: Text(sum.toTimeFromSeconds()),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: OrdinalComboChart(
                seriesList,
                animate: false,
                defaultRenderer: BarRendererConfig<String>(
                  groupingType: BarGroupingType.grouped,
                ),
                customSeriesRenderers: <SeriesRendererConfig<String>>[
                  LineRendererConfig<String>(customRendererId: 'customLine'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
