import 'dart:convert';

import 'package:easy_extension/easy_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:phishingblock/gemini/gemini_helper.dart';
import 'package:phishingblock/helper/storage_helper.dart';
import 'package:phishingblock/helper/utils.dart';
import 'package:phishingblock/models/danger_enum.dart';
import 'package:phishingblock/models/gemini_response_data.dart';
import 'package:phishingblock/models/message_data.dart';
import 'package:phishingblock/models/sms_data.dart';
import 'package:phishingblock/models/url_response_data.dart';
import 'package:phishingblock/provider/channel_provider.dart';
import 'package:phishingblock/provider/contacts_provider.dart';
import 'package:phishingblock/provider/message_provider.dart';
import 'package:phishingblock/router/router.dart';
import 'package:phishingblock/screens/detail_screen.dart';

class NotificationHelper {
  NotificationHelper._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //알림 초기화
  static Future init() async {
    ChannelProvider.platform.setMethodCallHandler(_handleMethodCall);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_noti');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) async {
        Log.cyan("CLICKED");
        if (payload != null) {
          Log.cyan("TRYING TO MOVE");
          router.goNamed(Screen.main);
          router.pushNamed(Screen.detail, extra: payload);
        }
      },
    );
  }

  //로컬 알림 전송 함수
  static Future<void> _showNotification(
      {required String title, required String message, String? payload}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('sms_channel', 'SMS Channel',
            channelDescription: 'Channel for SMS notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    String data = jsonEncode({"name": title, "sender": payload});

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      platformChannelSpecifics,
      payload: data,
    );
  }

  //코틀린에서 호출한 메소드 작동 함수
  static Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'smsReceived') {
      onSmsReceived(call.arguments);
    }
    if (call.method == 'refresh') {
      //여기서 페이지 새로고침 해야 하는데 왜 안되는 건데
    }
  }

  // 메세지가 수신 되면 실행
  static void onSmsReceived(dynamic callArgs) async {
    await StorageHelper.init();
    final contactProvider = Get.find<ContactsProvider>();

    final message = callArgs['smsMessage'];
    final receivedTime = callArgs['receivedTime'];

    // 여기서 SMS 수신 시 실행할 함수를 정의합니다.
    Log.green("Received SMS: $message");
    // 예를 들어, 알림을 띄울 수 있습니다.

    final elements = Utils.linkTrimHelper(message);
    Log.cyan(elements.toString());

    // 정규 표현식 패턴: "SMS from" 뒤에 오는 공백이 아닌 문자와 스페이스 찾기
    final RegExp phoneRegExp = RegExp(r'SMS from (\S+)\s?:\s?(.*)');
    final match = phoneRegExp.firstMatch(message);
    String sender = "";
    String msgcontent = "";

    if (match != null) {
      sender = match.group(1)!; // 매칭된 그룹(공백이 아닌 문자) 반환
      msgcontent = match.group(2)!;
    }
    await contactProvider.fetchContacts();

    // 00000000000 형식으로 연락처에서 찾아보고 없으면
    // 000-0000-0000 형식으로 변환 후 찾아보고도 없으면 그냥 번호로 출력
    String name = contactProvider.rxContacts[sender] ??
        (contactProvider.rxContacts[Utils.formatPhoneNumber(sender)] ?? sender);

    _showNotification(title: name, message: msgcontent, payload: sender);

    String dangerWarn = "innocent";
    var dangerLevel = 10.0;

    GeminiResponseData? res;
    //메세지안에 링크가 있으면
    if (elements.isNotEmpty) {
      //링크가 하나면
      if (elements.count() == 1) {
        //서버에 물어봐서 true(위험하다) false(안위험하다) 반환
        UrlResponseData? verificationResult =
            await Utils.urlVerificationHelper(elements[0]);
        var finalUrl = verificationResult?.data?.finalUrl;
        res = await Gemini.geminiSmsVerification(
            msgcontent, sender, finalUrl); //url 위험 문자

        Log.cyan(verificationResult.toString());
        //링크가 위험하면
        if (verificationResult?.data?.isDanger == true) {
          dangerLevel = 100.0;
          //문자를 제미나이에게 전송 후 결과 반환
          //메세지를 서버 데이터베이스에 저장
        } // URL이 위험하지 않을 경우 - 전화번호가 위험일 가능성이 있음
      }
      //링크가 여러개면
      else {
        List verificationResultList = [];
        List finalUrlList = [];
        //하나씩 서버에 물어봐서 위험 여부 리스트로 반환
        for (var element in elements) {
          UrlResponseData? verificationResult =
              await Utils.urlVerificationHelper(element);
          verificationResultList.add(verificationResult?.data?.isDanger);
          finalUrlList.add(verificationResult?.data?.finalUrl);
        } // true false 리스트

        res = await Gemini.geminiSmsVerification(
            msgcontent, sender, finalUrlList); //url 위험 문자

        Log.cyan(verificationResultList.toString());
        //위험한 링크가 있으면
        if (verificationResultList.contains(true)) {
          dangerLevel = 100.0;
          //제미나이에게 전송 후 결과 반환
        }
      }
    } else {
      var finalUrl = "";
      res = await Gemini.geminiSmsVerification(msgcontent, sender, finalUrl);
    }

    if (res?.link.urlSimilarity != null) {
      dangerLevel -= ((res!.link.urlSimilarity ?? 0.0) * 2);
    }
    if (res != null) {
      Log.yellow(res.link);
      Log.yellow(res.number.callNumberMatch.toString());
      Log.yellow(res.number.falseNumberMatch.toString());
      Log.yellow(res.categories);
    }
/* 10 기준
0~10 ->innocent
20-> caution
30 -> danger

*/
    //전화번호의 판단값에 따른 danger level 증감
    if (res?.number.callNumber != null) {
      dangerLevel += 5.0;
      if (res?.number.callNumberMatch == true) {
        dangerLevel -= 5.0;
      } else {
        dangerLevel += 5.0;
      }
    } else {
      dangerLevel -= 5.0;
    }

    if (res?.number.falseNumber != null) {
      dangerLevel += 5.0;
      if (res?.number.falseNumberMatch == true) {
        dangerLevel -= 5.0;
      } else {
        dangerLevel += 5.0;
      }
    } else {
      dangerLevel -= 5.0;
    }

    if (dangerLevel <= 10.0) {
      dangerWarn = "innocent";
    } else if (dangerLevel > 10.0 && dangerLevel <= 25.0) {
      dangerWarn = "caution";
    } else if (dangerLevel > 25.0) {
      dangerWarn = "danger";
      Log.magenta(msgcontent +
          elements.isNotEmpty.toString() +
          res!.number.falseNumber.toString() +
          sender +
          res.categories.toString());
      Log.magenta(await Utils.msgToDatabaseHelper(
          msgcontent,
          (elements.isNotEmpty) ? true : false,
          (res.number.falseNumber != null) ? true : false,
          sender,
          res.categories.toString()));
      Log.magenta(dangerWarn.toString() + dangerLevel.toString());
    }

    MessageData testedData = MessageData(
        id: sender + receivedTime.toString(),
        sender: sender,
        message: msgcontent,
        date: receivedTime.toInt(),
        isMine: false,
        danger: dangerWarn.toString());
    Log.blue(sender.toString());
    Log.blue(receivedTime);
    Log.yellow("TESTEDATA: $testedData");
    Log.yellow(testedData.toString());
    StorageHelper.saveMessageBySender(sender, testedData);
    Log.red("COMPLETE");
  }
}
