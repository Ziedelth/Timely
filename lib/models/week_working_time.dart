import 'package:intl/intl.dart';
import 'package:timely/models/working_time.dart';

class WeekWorkingTime {
  final String name;
  final Iterable<WorkingTime> times;
  bool isExpanded;

  WeekWorkingTime(this.name, this.times, {this.isExpanded = false});

  static int numOfWeeks(final int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat('D').format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  static int weekNumber(final DateTime date) {
    int dayOfYear = int.parse(DateFormat('D').format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  static String weekNumberName(final DateTime date) =>
      '${weekNumber(date)}-${date.year}';

  static Iterable<WeekWorkingTime> getWeeks(
    final List<WorkingTime> workingTimes,
  ) {
    return workingTimes.reversed
        .map((final WorkingTime e) => weekNumberName(e.startTime))
        .toSet()
        .map(
          (final String e) => WeekWorkingTime(
            e,
            workingTimes.where(
              (final WorkingTime element) =>
                  weekNumberName(element.startTime) == e,
            ),
            isExpanded: e == weekNumberName(DateTime.now()),
          ),
        );
  }
}
