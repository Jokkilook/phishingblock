import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phishingblock/helper/notification_helper.dart';
import 'package:phishingblock/helper/storage_helper.dart';
import 'package:phishingblock/provider/channel_provider.dart';
import 'package:phishingblock/provider/contacts_provider.dart';
import 'package:phishingblock/provider/message_provider.dart';
import 'package:phishingblock/router/router.dart';

void main() async {
  //플러터 코어 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  NotificationHelper.init();

  //GetX 설정
  final channel = ChannelProvider();
  Get.put(channel);
  final contact = ContactsProvider();
  Get.put(contact);
  final message = MessageProvider();
  Get.put(message);
  await contact.init();
  await message.init();
  await StorageHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            color: Color(0xFF595fe5), foregroundColor: Colors.white),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF595fe5)),
        useMaterial3: true,
      ),
    );
  }
}
