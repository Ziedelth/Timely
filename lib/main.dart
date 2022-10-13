import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/components/week_panel_list.dart';
import 'package:timely/extensions.dart';
import 'package:timely/models/week_working_time.dart';
import 'package:timely/models/working_time.dart';
import 'package:timely/views/stats_view.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Paris'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final SharedPreferences _sharedPreferences;
  late final List<WorkingTime> _workingTimes;
  bool isInitialized = false;
  final FlutterLocalNotificationsPlugin flnp =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings ais =
      const AndroidInitializationSettings('splash');

  List<WorkingTime> get savedWorkingTimes {
    final List<String> workingTimesJson =
        _sharedPreferences.getStringList('working_times') ?? <String>[];
    return workingTimesJson
        .map((final String e) => WorkingTime.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> setWorkingTimes() async {
    final List<String> workingTimesJson = _workingTimes
        .map((final WorkingTime e) => jsonEncode(e.toJson()))
        .toList();
    await _sharedPreferences.setStringList('working_times', workingTimesJson);
  }

  Future<void> export() async {
    final String workingTimesJson = jsonEncode(
      _workingTimes
          .map((final WorkingTime e) => jsonEncode(e.toJson()))
          .toList(),
    );

    // Compress workingTimesJson with gzip
    final List<int> compressedWorkingTimesJson =
        gzip.encode(utf8.encode(workingTimesJson));
    // Pick a directory to save the file
    final String? directory = await FilePicker.platform.getDirectoryPath();

    if (directory == null) {
      return;
    }

    // Save compressedWorkingTimesJson to file
    final File file = File('$directory/working_times.json.tly');
    await file.writeAsBytes(compressedWorkingTimesJson);
  }

  Future<void> import() async {
    // Pick a file to import
    final FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      return;
    }

    final String path = result.files.single.path!;

    if (!path.endsWith('.tly')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid file type',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      return;
    }

    // Read file
    final File file = File(path);
    final List<int> compressedWorkingTimesJson = await file.readAsBytes();

    // Decompress compressedWorkingTimesJson with gzip
    final String workingTimesJson =
        utf8.decode(gzip.decode(compressedWorkingTimesJson));
    // Parse workingTimesJson
    final List<dynamic> workingTimesJsonList = jsonDecode(workingTimesJson);

    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text("Type d'importation"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final List<WorkingTime> workingTimes = workingTimesJsonList
                    .map(
                      (final dynamic e) => WorkingTime.fromJson(jsonDecode(e)),
                    )
                    .toList();

                if (workingTimes.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No new working times found',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return;
                }

                _workingTimes.clear();
                _workingTimes.addAll(workingTimes);
                _workingTimes.sort(
                  (final WorkingTime a, final WorkingTime b) =>
                      a.startTime.compareTo(b.startTime),
                );
                await setWorkingTimes();

                if (mounted) {
                  setState(() {});
                }
              },
              child: const Text('Entière'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final List<WorkingTime> workingTimes = workingTimesJsonList
                    .map(
                      (final dynamic e) => WorkingTime.fromJson(jsonDecode(e)),
                    )
                    .where(
                      (final WorkingTime element) => !_workingTimes.any(
                        (final WorkingTime wt) => wt.uuid == element.uuid,
                      ),
                    )
                    .toList();

                if (workingTimes.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No new working times found',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return;
                }

                _workingTimes.addAll(workingTimes);
                _workingTimes.sort(
                  (final WorkingTime a, final WorkingTime b) =>
                      a.startTime.compareTo(b.startTime),
                );
                await setWorkingTimes();

                if (mounted) {
                  setState(() {});
                }
              },
              child: const Text('Partielle'),
            ),
          ],
        );
      },
    );
  }

  WorkingTime? get currentWorkingTime {
    final List<WorkingTime> currentWorkingTimes = _workingTimes
        .where((final WorkingTime e) => e.endTime == null)
        .toList();

    if (currentWorkingTimes.isEmpty) {
      return null;
    }

    return currentWorkingTimes.first;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((final Duration _) async {
      await flnp.initialize(
        InitializationSettings(android: ais),
      );

      await flnp
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();

      _sharedPreferences = await SharedPreferences.getInstance();
      _workingTimes = savedWorkingTimes;
      isInitialized = true;

      setState(() {});

      // Create timer to update UI every minute
      Timer.periodic(const Duration(minutes: 1), (final Timer timer) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(final BuildContext context) {
    final Iterable<WeekWorkingTime> weeks = isInitialized
        ? WeekWorkingTime.getWeeks(_workingTimes)
        : <WeekWorkingTime>[];

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: Image.asset(
            'assets/icon.png',
            width: 32,
            height: 32,
          ),
          title: const Text('Timely'),
        ),
        actions: <Widget>[
          PopupMenuButton<int>(
            icon: const Icon(Icons.settings),
            color: Colors.grey[100],
            onSelected: (final int result) async {
              switch (result) {
                case 0:
                  Navigator.of(context).push(
                    MaterialPageRoute<StatsView>(
                      builder: (final BuildContext context) => StatsView(
                        times: _workingTimes,
                      ),
                    ),
                  );
                  break;
                case 1:
                  final WorkingTime? cwt = currentWorkingTime;

                  if (cwt == null) {
                    _workingTimes.add(WorkingTime(startTime: DateTime.now()));

                    await flnp.zonedSchedule(
                      0,
                      "It's time",
                      'Faites une pause, cela fait 3h30min que vous travaillez sans relache',
                      tz.TZDateTime.now(tz.local)
                          .add(const Duration(minutes: 210)),
                      const NotificationDetails(
                        android: AndroidNotificationDetails(
                          'time_to_out',
                          "It's time",
                        ),
                      ),
                      uiLocalNotificationDateInterpretation:
                          UILocalNotificationDateInterpretation.absoluteTime,
                      androidAllowWhileIdle: true,
                    );
                  } else {
                    cwt.end();

                    await flnp.cancel(0);
                  }

                  await setWorkingTimes();

                  if (!mounted) {
                    return;
                  }

                  setState(() {});
                  break;
                case 2:
                  import();
                  break;
                case 3:
                  export();
                  break;
              }
            },
            itemBuilder: (final BuildContext context) {
              return const <PopupMenuEntry<int>>[
                PopupMenuItem<int>(
                  value: 0,
                  child: ListTile(
                    leading: Icon(Icons.query_stats),
                    title: Text('Statistiques'),
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Ajouter une entrée'),
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<int>(
                  value: 2,
                  child: ListTile(
                    leading: Icon(Icons.file_upload),
                    title: Text('Importer'),
                  ),
                ),
                PopupMenuItem<int>(
                  value: 3,
                  child: ListTile(
                    leading: Icon(Icons.file_download),
                    title: Text('Exporter'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (isInitialized) ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Total week working time: ${WorkingTime.sumWorkingTime(weeks.firstOrNull?.times ?? <WorkingTime>[]).toTimeFromSeconds()}',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: WeekPanelList(
                    weeks: weeks.toList(),
                  ),
                ),
              ),
            ] else
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
