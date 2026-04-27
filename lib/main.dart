import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/study_groups_screen.dart';
import 'screens/study_planner_screen.dart';
import 'screens/study_room_finder_screen.dart';
import 'screens/timer_screen.dart';
import 'services/notification_service.dart';
import 'theme/study_n_sync_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyNSync',
      theme: StudyNSyncTheme.darkAcademy,
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        DashboardScreen.routeName: (context) => const DashboardScreen(),
        StudyPlannerScreen.routeName: (context) => const StudyPlannerScreen(),
        StudyRoomFinderScreen.routeName: (context) =>
            const StudyRoomFinderScreen(),
        StudyGroupsScreen.routeName: (context) => const StudyGroupsScreen(),
        ChatScreen.routeName: (context) => const ChatScreen(),
        TimerScreen.routeName: (context) => const TimerScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
      },
    );
  }
}