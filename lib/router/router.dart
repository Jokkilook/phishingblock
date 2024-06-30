import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:phishingblock/screens/contacts_screen.dart';
import 'package:phishingblock/screens/detail_screen.dart';
import 'package:phishingblock/screens/main_screen.dart';
import 'package:phishingblock/screens/setting_screen.dart';

final router = GoRouter(
  initialLocation: Screen.main,
  routes: [
    GoRoute(
      name: Screen.main,
      path: Screen.main,
      builder: (context, state) {
        return const MainScreen();
      },
    ),
    GoRoute(
      name: Screen.detail,
      path: Screen.detail,
      builder: (context, state) {
        Map<String, String?> data;
        try {
          data = state.extra as Map<String, String?>;
        } catch (e) {
          data = Map<String, String?>.from(jsonDecode(state.extra as String));
        }
        final String? name = data["name"];
        final String sender = data["sender"] ?? "";
        return DetailScreen(displayName: name, sender: sender);
      },
    ),
    GoRoute(
      name: Screen.contacts,
      path: Screen.contacts,
      builder: (context, state) {
        return const ContactsScreen();
      },
    ),
    GoRoute(
      name: Screen.setting,
      path: Screen.setting,
      builder: (context, state) {
        return const SettingScreen();
      },
    ),
  ],
);

class Screen {
  static String main = '/main';
  static String detail = '/detail';
  static String contacts = '/contacts';
  static String setting = '/setting';
}
