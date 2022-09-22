import 'package:flutter/material.dart';
import 'package:timely/components/working_time_component.dart';
import 'package:timely/extensions.dart';
import 'package:timely/models/week_working_time.dart';
import 'package:timely/models/working_time.dart';

class WeekPanelList extends StatefulWidget {
  const WeekPanelList({required this.weeks, super.key});

  final List<WeekWorkingTime> weeks;

  @override
  State<WeekPanelList> createState() => _WeekPanelListState();
}

class _WeekPanelListState extends State<WeekPanelList> {
  bool isCurrentWeek(final WeekWorkingTime week) =>
      week.times.any((final WorkingTime element) => element.endTime == null);

  @override
  Widget build(final BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (final int index, final bool isExpanded) {
        setState(() {
          widget.weeks[index].isExpanded = !isExpanded;
        });
      },
      children: widget.weeks
          .map(
            (final WeekWorkingTime week) => ExpansionPanel(
              headerBuilder:
                  (final BuildContext context, final bool isExpanded) {
                return ListTile(
                  leading: Icon(
                    Icons.calendar_month,
                    color: isCurrentWeek(week)
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                  title: Text(week.name),
                  trailing: Text(
                    WorkingTime.sumWorkingTime(week.times).toTimeFromSeconds(),
                  ),
                );
              },
              body: week.isExpanded
                  ? Column(
                      children: week.times
                          .map(
                            (final WorkingTime e) =>
                                WorkingTimeComponent(workingTime: e),
                          )
                          .toList()
                          .reversed
                          .toList(),
                    )
                  : Container(),
              isExpanded: week.isExpanded,
            ),
          )
          .toList(),
    );
  }
}
