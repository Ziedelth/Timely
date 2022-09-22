import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'working_time.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class WorkingTime {
  late final String uuid;
  final DateTime startTime;
  DateTime? endTime;

  WorkingTime({required this.startTime, this.endTime, final String? uuid}) {
    this.uuid = uuid ?? const Uuid().v4();
  }

  factory WorkingTime.fromJson(final Map<String, dynamic> data) =>
      _$WorkingTimeFromJson(data);

  Map<String, dynamic> toJson() => _$WorkingTimeToJson(this);

  double get diffInSecs {
    if (endTime == null) {
      return DateTime.now().difference(startTime).inSeconds.toDouble();
    }

    return endTime!.difference(startTime).inSeconds.toDouble();
  }

  void end() {
    endTime = DateTime.now();
  }

  static double sumWorkingTime(final Iterable<WorkingTime> workingTimes) =>
      workingTimes.fold(
        0.0,
        (final double previousValue, final WorkingTime element) =>
            previousValue + element.diffInSecs,
      );
}
