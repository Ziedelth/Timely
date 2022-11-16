import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timely/const.dart';
import 'package:timely/extensions.dart';
import 'package:timely/models/working_time.dart';

final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');

class WorkingTimeComponent extends StatelessWidget {
  WorkingTimeComponent({required this.workingTime, super.key}) {
    title = Text(dateFormat.format(workingTime.startTime));
    subtitle = Text(
      workingTime.endTime == null
          ? 'Fin prévue à ${dateFormat.format(workingTime.startTime.add(const Duration(minutes: workTimeOnceInMinutes))).split(" ")[1]}'
          : dateFormat.format(workingTime.endTime!),
    );
  }

  final WorkingTime workingTime;
  late final Text title;
  late final Text subtitle;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.timer,
        color:
            workingTime.endTime == null ? Theme.of(context).primaryColor : null,
      ),
      title: title,
      subtitle: subtitle,
      trailing: Text(workingTime.diffInSecs.toTimeFromSeconds()),
    );
  }
}
