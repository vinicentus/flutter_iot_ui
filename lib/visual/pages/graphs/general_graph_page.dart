import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/check_box.dart';
import 'package:flutter_iot_ui/core/models/sensors/generic_datamodel.dart';
import 'package:flutter_iot_ui/core/util/color_picker.dart';
import 'package:flutter_iot_ui/core/util/db_updates_stream.dart';
import 'package:flutter_iot_ui/core/util/list_contains.dart';
import 'package:flutter_iot_ui/core/util/moving_average.dart';
import 'package:flutter_iot_ui/core/viewmodels/graph_settings_model.dart';
import 'package:flutter_iot_ui/visual/widgets/appbar_trailing.dart';
import 'package:flutter_iot_ui/visual/widgets/checkbox_widget.dart';
import 'package:flutter_iot_ui/visual/widgets/drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class GeneralGraphPage<T extends GenericSensorDataEntry>
    extends StatefulWidget {
  final String title;
  final String route;
  final String unit;
  final List<FlSpot Function(T)> transformFunctions;
  final List<String> checkBoxNames;

  GeneralGraphPage({
    Key? key,
    required this.title,
    required this.route,
    required this.unit,
    this.transformFunctions = const [],
    this.checkBoxNames = const [],
  }) : super(key: key);

  @override
  State<GeneralGraphPage<T>> createState() => _GeneralGraphPageState<T>();
}

class _GeneralGraphPageState<T extends GenericSensorDataEntry>
    extends State<GeneralGraphPage<T>> {
  List<CheckBoxModel> checkBoxes = [];

  var colorPicker = ColorPicker.material();

  @override
  void initState() {
    super.initState();

    for (String name in this.widget.checkBoxNames) {
      print('OK');
      checkBoxes.add(CheckBoxModel(name, colorPicker.next));
    }
  }

  @override
  Widget build(BuildContext context) {
    var model = context.read<GraphSettingsModel>();

    colorPicker.reset();

    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.title),
        actions: [AppbarTrailingInfo()],
      ),
      drawer: NavDrawer(this.widget.route),
      body: StreamBuilder(
        stream: dbUpdatesOfType<T>(
                refreshDuration: model.graphRefreshTime,
                graphTimeWindow: model.graphTimeWindow)
            .map((e) => lineChartBarDatas(e, model)),
        builder: (context, AsyncSnapshot<List<LineChartBarData>> snapshot) {
          // We already check if it has data (a non-null value).
          // That means we can use the !. operator throughout safely,
          // since we know (unlike the dart compiler) that the value won't ever be null.
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              children: [
                Expanded(
                  child: LineChart(lineChartData(context, snapshot.data!)),
                ),
                _wrappedCheckboxes(),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(),
                Text('No data to show (yet).')
              ]),
            );
          }
        },
      ),
    );
  }

  LineChartData lineChartData(
      BuildContext context, List<LineChartBarData> data) {
    return LineChartData(
      lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            showOnTopOfTheChartBoxArea: true,
            getTooltipItems: (List<LineBarSpot> spotList) => spotList
                .map((e) => LineTooltipItem(
                    '${e.y.toStringAsFixed(2)} ${this.widget.unit}',
                    Theme.of(context).textTheme.bodyText1!))
                .toList(),
          )),
      gridData: FlGridData(
        show: true,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          margin: 10,
          // An hour in milliseconds / 2
          interval: 3.6e6 / 2,
          getTitles: (value) {
            var time = DateTime.fromMillisecondsSinceEpoch(value.toInt())
                // Show local time
                .toLocal();
            return '${time.hour}:${time.minute}';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          // TODO: show decimal values if the value range is small enough
          getTitles: (value) =>
              '${value.toStringAsFixed(2)} ${this.widget.unit}',
          // interval: 1,
          margin: 10,
          reservedSize: 50,
        ),
        topTitles: SideTitles(showTitles: false),
        rightTitles: SideTitles(showTitles: false),
      ),
      borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(),
            left: BorderSide(),
          )),
      // TODO:
      // minX: 0,
      // maxX: 14,
      // maxY: 6,
      // minY: 0,
      lineBarsData: data,
    );
  }

  List<LineChartBarData> lineChartBarDatas(
      List<T> event, GraphSettingsModel model) {
    var list = <LineChartBarData>[];
    for (int i = 0; i < this.widget.transformFunctions.length; i++) {
      list.add(
        LineChartBarData(
            spots: transformIntoMovingAverage(
              event.map(this.widget.transformFunctions[i]).toList(),
              model.useMovingAverage,
              model.movingAverageSamples,
            ),
            isCurved: false,
            colors: [colorPicker.next],
            dotData: FlDotData(show: false),
            show:
                checkBoxes.containsElementAt(i) ? checkBoxes[i].checked : true),
      );
    }
    return list;
  }

  Wrap _wrappedCheckboxes() {
    var children = <Widget>[];

    for (var item in this.checkBoxes) {
      children.add(
        CheckboxWidget(
          text: item.text,
          color: item.color,
          value: item.checked,
          callbackFunction: (bool value) {
            setState(() {
              item.checked = value;
            });
          },
        ),
      );
    }

    return Wrap(
      children: children,
    );
  }
}
