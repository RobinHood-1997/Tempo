// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class NotificationService {
//     //Singleton pattern - only one instance of this service ever to exist
//     static final NotificationService _instance = NotificationService._internal();
//     factory NotificationService() => _instance;
//     NotificationService._internal();

//     final FlutterLocalNotificationsPlugin _plugin = 
//     FlutterLocalNotificationsPlugin();

//     Future<void> init() async {
//         const AndroidInitializationSettings androidSettings = 
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//         const InitializationSettings settings = InitializationSettings(
//             android: androidSettings,
//         );

//         await _plugin.initialize(settings);
//     }

//     //Call this when a focus session ends - nudge user to take a break!
//     Future<void> showBreakReminder() async {
//         const AndroidNotificationDetails androidDetails = 
//         AndroidNotificationDetails('focus_timer_channel', 
//         'Focus Timer',
//         channelDescription: 'Focus session and break reminders',
//         importance: Importance.high,
//         priority: Priority.high,
//         );

//         const NotificationDetails details = NotificationDetails(
//             android: androidDetails,
//         );

//         await _plugin.show(
//            0,
//            '🎉 Session Complete!', 
//            'Great work. Time to take a break!', 
//            details,
//            );
//     }

//     // Call this when break ends - nudge user to get back to work
//     Future<void> showFocusReminder (String taskType) async {
//         const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails('focus_timer_channel', 
//         'Focus Timer',
//         channelDescription: 'Focus session and break reminders',
//         importance: Importance.high,
//         priority: Priority.high,
//         );

//         const NotificationDetails details = NotificationDetails(
//             android: androidDetails,
//         );

//         await _plugin.show(
//             1, 
//             '⏱ Break Over', 
//             'Ready to focus on $taskType?', 
//             details,
//             );
//     }
// }

// final notificationServiceProvider = Provider<NotificationService>((ref) {
//     return NotificationService();
// });