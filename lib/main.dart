import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:pomodoro_timer/services/notification_service.dart';
import 'models/session_model.dart';
import 'models/session_adapter.dart';
import 'screens/home_screen.dart';

void main() async {
  //async main - needed because Hive init takes a moment
  WidgetsFlutterBinding.ensureInitialized();

  //Start up hive and tell it where to store files on the device
  await Hive.initFlutter();

  //Registers your session adapter so hive knows how to store it.
  Hive.registerAdapter(SessionAdapter());

  //Opens the sessions box - think of it as your database table
  await Hive.openBox<Session>('sessions');
  //await NotificationService().init();
  
  runApp(
    const ProviderScope(
      child: FocusTimerApp(),
      ), 
      );
}

class FocusTimerApp extends StatelessWidget{
  const FocusTimerApp({super.key});


@override
Widget build(BuildContext context){
return MaterialApp(
  title: 'Focus Timer', //Change the app name later
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF5C6BC0),
    brightness: Brightness.dark,
    background: const Color(0xFF1A1A2E),
    surface: const Color(0xFF252540),
    primary: const Color(0xFF5C6BC0),
    secondary: const Color(0xFF26A69A),
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF1A1A2E),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF5C6BC0),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      textStyle: const TextStyle(fontSize: 16),
    ),
  ),
),
  home: const HomeScreen(),
);
}
}