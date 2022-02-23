import 'dart:async';
import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String latitude = 'waiting...';
  String longitude = 'waiting...';
  String altitude = 'waiting...';
  String accuracy = 'waiting...';
  String bearing = 'waiting...';
  String speed = 'waiting...';
  String time = 'waiting...';
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  List<String> accelerometer = ['0', '0', '0'];
  List<String> gyroscope = ['0', '0', '0'];
  bool flag = false;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  static final channelName = 'com.example.widget/accdata';
  final methodChannel = MethodChannel(channelName);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }

  @override
  void initState() {
    var androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSSettings = IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    var initSetttings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: (payload) {});
    BackgroundLocation.startLocationService();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
            flag = true;
          });
        },
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
            flag = true;
          });
        },
      ),
    );
    super.initState();
  }

  void requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> showOngoingNotification(String lat, String long, String accx,
      String accy, String accz, String gyrx, String gyry, String gyrz) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'Channel Name',
            channelDescription: '$lat,$long',
            importance: Importance.max,
            priority: Priority.max,
            onlyAlertOnce: true);
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, 'Flutter Local Notification',
        '$lat,$long,$accx,$accy,$accz,$gyrx,$gyry,$gyrz', notificationDetails);
  }

  @override
  Widget build(BuildContext context) {
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
            flag = true;
          });
        },
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
            flag = true;
          });
        },
      ),
    );
    accelerometer =
        _accelerometerValues!.map((double v) => v.toStringAsFixed(1)).toList();
    print(accelerometer);
    gyroscope =
        _gyroscopeValues!.map((double v) => v.toStringAsFixed(1)).toList();
    BackgroundLocation.getLocationUpdates((location) {
      flag = true;
      setState(() {
        latitude = location.latitude.toString();
        longitude = location.longitude.toString();
        accuracy = location.accuracy.toString();
        altitude = location.altitude.toString();
        bearing = location.bearing.toString();
        speed = location.speed.toString();
        time = DateTime.fromMillisecondsSinceEpoch(location.time!.toInt())
            .toString();
      });
    });
    if (flag) {
      showOngoingNotification(
        latitude,
        longitude,
        accelerometer![0],
        accelerometer![1],
        accelerometer![2],
        gyroscope![0],
        gyroscope![1],
        gyroscope![2],
      );
      print(accelerometer![0]);
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Location Service'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              locationData('Latitude: ' + latitude),
              locationData('Longitude: ' + longitude),
              locationData('Altitude: ' + altitude),
              locationData('Accuracy: ' + accuracy),
              locationData('Bearing: ' + bearing),
              locationData('Speed: ' + speed),
              locationData('Time: ' + time),
              locationData('accelerometer x: ' + accelerometer![0]),
              locationData('accelerometer y: ' + accelerometer[1]),
              locationData('accelerometer z: ' + accelerometer[2]),
              locationData('gyroscope x: ' + gyroscope![0]),
              locationData('gyroscope y: ' + gyroscope![1]),
              locationData('gyroscope z: ' + gyroscope![2]),
              MaterialButton(
                onPressed: () async {
                  await methodChannel.invokeMethod("start");
                },
                child: Text('Start Recording'),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }
}
