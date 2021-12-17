// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:todoapp/pages/notification_screen.dart';
//
// class NotifyHepler{
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   requestIosPermision(){
//     flutterLocalNotificationsPlugin.
//     resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
//       alert: true,
//       badge: true,
//       sound: true
//     );
//   }
//
//   initializedNotification()async{
//     tz.initializeTimeZones();
//     // tz.setLocalLocation(tz.getLocation(timeZoneName));
//
//
// // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
//
//     final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('appicon');
//     final IOSInitializationSettings initializationSettingsIOS =
//     IOSInitializationSettings(
//       requestSoundPermission: false,
//       requestBadgePermission: false,
//       requestAlertPermission: false,
//       onDidReceiveLocalNotification: onDidReceiveLocalNotification,
//     );
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: (String ? payload )async{
//           selectNotification(payload!);
//         });
//   }
//
//   void selectNotification(String payload) async {
//     if (payload != null) {
//       debugPrint('notification payload: $payload');
//     }
//     await Get.to(NotificationScreen(payload));
//   }
//
//   displayNotification({required String title ,required String body })async{
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//   const  AndroidNotificationDetails(
//       'your channel id', 'your channel name',
//         channelDescription: 'your channel description',
//         importance: Importance.max,
//         priority: Priority.high,
//         ticker: 'ticker');
//    IOSNotificationDetails iosPlatformChannelSpecifics =
//     const  IOSNotificationDetails();
//     NotificationDetails platformChannelSpecifics =
//     NotificationDetails(android: androidPlatformChannelSpecifics,iOS: iosPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(
//         0, title,body, platformChannelSpecifics,
//         payload: 'item x');
//
//   }
//
//   scheduelNofication()async{
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//         0,
//         'scheduled title',
//         'scheduled body',
//         tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
//         const NotificationDetails(
//             android: AndroidNotificationDetails(
//                 'your channel id', 'your channel name',
//                 channelDescription: 'your channel description')),
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime);
//   }
//
// // Olrder IOS
//   void onDidReceiveLocalNotification(int id, String?title, String? body, String? payload) async {
//     // display a dialog with the notification details, tap ok to go to another page
//     Get.dialog(Text(body!));
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todoapp/moduls/task.dart';
import 'package:todoapp/pages/notification_screen.dart';

class NotifyHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String selectedNotificationPayload = '';

  final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>();

  initializeNotification() async {
    tz.initializeTimeZones();
    _configureSelectNotificationSubject();
    await _configureLocalTimeZone();
    // await requestIOSPermissions(flutterLocalNotificationsPlugin);
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('appicon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        selectNotificationSubject.add(payload!);
      },
    );
  }

  displayNotification({required String title, required String body}) async {
    var androidPlatformChannelSpecifics =
        const AndroidNotificationDetails('your channel id', 'your channel name',
            // 'your channel description',
            importance: Importance.max,
            priority: Priority.high);
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  cancelNotification(Task task) async {
    flutterLocalNotificationsPlugin.cancel(task.id!);
  }
  cancelAllNotification() async {
    flutterLocalNotificationsPlugin.cancelAll();
  }
  scheduledNotification(int hour, int minutes, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      task.title,
      task.note,
      //tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      _nextInstanceOfTenAM(
          hour, minutes, task.remind!, task.repeat!, task.date!),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id', 'your channel name',
          // 'your channel description'
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${task.title}|${task.note}|${task.startTime}|',
    );
  }

  tz.TZDateTime _nextInstanceOfTenAM(int hour, int minutes, int remind, String repeat, String date) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final formattedDate = DateFormat.yMd().parse(date);
    final tz.TZDateTime formattedLocalDate = tz.TZDateTime.from(formattedDate, tz.local);

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, formattedLocalDate.year, formattedLocalDate.month,
            formattedLocalDate.day, hour, minutes);
    scheduledDate = afterRemind(remind, scheduledDate, now);
    
    if (scheduledDate.isBefore(now)) {
      if (repeat == 'Daily') {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            (formattedDate.day) + 1, hour, minutes);
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      if (repeat == 'Weekly') {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            (formattedDate.day) + 7, hour, minutes);
      }
      if (repeat == 'Monthly') {
        scheduledDate = tz.TZDateTime(
            tz.local, now.year, now.month + 1, formattedDate.day, hour, minutes);
      }
      scheduledDate = afterRemind(remind, scheduledDate, now);
    }


    return scheduledDate;

  }

  tz.TZDateTime afterRemind(
      int remind, tz.TZDateTime scheduledDate, tz.TZDateTime now) {
    if (remind == 5) {
      scheduledDate = scheduledDate.add(const Duration(minutes: 5));
    }
    if (remind == 10) {
      scheduledDate = scheduledDate.add(const Duration(minutes: 10));
    }
    if (remind == 15) {
      scheduledDate = scheduledDate.add(const Duration(minutes: 15));
    }
    if (remind == 20) {
      scheduledDate = scheduledDate.add(const Duration(minutes: 20));
    }

    debugPrint('final scheduledDate=  $scheduledDate');
    return scheduledDate;
  }

  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

/*   Future selectNotification(String? payload) async {
    if (payload != null) {
      //selectedNotificationPayload = "The best";
      selectNotificationSubject.add(payload);
      print('notification payload: $payload');
    } else {
      print("Notification Done");
    }
    Get.to(() => SecondScreen(selectedNotificationPayload));
  } */

//Older IOS
  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    /* showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Title'),
        content: const Text('Body'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Container(color: Colors.white),
                ),
              );
            },
          )
        ],
      ),
    );
 */
    Get.dialog(Text(body!));
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      debugPrint('My payload is ' + payload);
      await Get.to(() => NotificationScreen(payload));
    });
  }
}
