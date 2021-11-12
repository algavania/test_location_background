import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_power_manager/android_power_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    List<String> list = prefs.getStringList('key')!;
    list.add(DateTime.now().toString());
    await prefs.setStringList('key', list);
    List<String> newList = prefs.getStringList('key')!;
    print('Pressed try ${newList.toString()}.');
    // Position position = await Geolocator.getCurrentPosition();
    // print('position ${position.toString()}');
  } catch (e) {
    await prefs.setStringList('key', [DateTime.now().toString()]);
    List<String> list = prefs.getStringList('key')!;
    print('Pressed catch ${list.toString()}.');
    // Position position = await Geolocator.getCurrentPosition();
    // print('position ${position.toString()}');
  }
}

void printHello() async {
  print('executing alarm manager');
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  
  print("[$now] Hello, world! isolate=$isolateId function='$printHello'");
  await saveLocation();
  print('shared pref has been set properly in alarm manager');
}

Future<void> initWorkManager() async {
  await AndroidPowerManager.requestIgnoreBatteryOptimizations();
  await [
    Permission.location,
    Permission.phone,
  ].request();

  // Workmanager().initialize(
  //     callbackDispatcher, // The top level function, aka callbackDispatcher
  //     isInDebugMode:
  //     true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  // );
  // Workmanager().registerPeriodicTask(
  //   "1",
  //   "simplePeriodicTask",
  //   // When no frequency is provided the default 15 minutes is set.
  //   // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
  //   frequency: const Duration(minutes: 15),
  // );
  print('init alarm manager in home navigation');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(MyApp());
  await AndroidAlarmManager.periodic(
      const Duration(minutes: 1), 0, printHello, allowWhileIdle: true, rescheduleOnReboot: true, exact: true, wakeup: true);
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  String sharedPrefText = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi PDAM Salatiga',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Test Alarm Manager')),
        body: FutureBuilder<void>(
          future: initWorkManager(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Text('Loading...');
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              List<String> list = prefs.getStringList('key') ?? [];
                              print('list ${list.toString()}');
                              setState(() {
                                if (list.isEmpty) {
                                  sharedPrefText = 'Shared pref list is empty';
                                } else {
                                  sharedPrefText = list.toString();
                                }
                              });
                            }, child: const Text('Show Shared Pref')),
                            const SizedBox(height: 10),
                            Text(sharedPrefText)
                          ]),
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }
}
