import 'package:flutter/material.dart';
import 'package:timely/components/working_time_component.dart';
import 'package:timely/extensions.dart';
import 'package:timely/models/week_working_time.dart';
import 'package:timely/models/working_time.dart';

class WeekPanelList extends StatefulWidget {
  final List<WeekWorkingTime> weeks;
  final VoidCallback onSaved;

  const WeekPanelList({required this.weeks, required this.onSaved, super.key});

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
                            (final WorkingTime e) {
                              final TextEditingController startController =
                                  TextEditingController(
                                text: e.startTime.toIso8601String(),
                              );
                              final TextEditingController endController =
                                  TextEditingController(
                                text: e.endTime?.toIso8601String(),
                              );

                              return GestureDetector(
                                child: WorkingTimeComponent(workingTime: e),
                                onLongPress: () async {
                                  showDialog(
                                    context: context,
                                    builder: (final BuildContext context) =>
                                        AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          TextField(
                                            controller: startController,
                                            decoration: const InputDecoration(
                                              labelText: 'Date de début',
                                            ),
                                          ),
                                          TextField(
                                            controller: endController,
                                            decoration: const InputDecoration(
                                              labelText: 'Date de fin',
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();

                                            e.startTime = DateTime.parse(
                                              startController.text,
                                            );

                                            e.endTime =
                                                endController.text.isNotEmpty
                                                    ? DateTime.parse(
                                                        endController.text,
                                                      )
                                                    : null;

                                            widget.onSaved();
                                          },
                                          child: const Text('Sauvegarder'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
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
