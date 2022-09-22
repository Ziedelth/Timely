// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkingTime _$WorkingTimeFromJson(final Map<String, dynamic> json) =>
    WorkingTime(
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      uuid: json['uuid'] as String?,
    );

Map<String, dynamic> _$WorkingTimeToJson(final WorkingTime instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
    };
