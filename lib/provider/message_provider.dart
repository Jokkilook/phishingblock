import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phishingblock/helper/permission_helper.dart';
import 'package:phishingblock/models/sms_data.dart';
import 'package:phishingblock/provider/channel_provider.dart';

class MessageProvider extends GetxController {
  final channelController = Get.find<ChannelProvider>();

  // RxList를 사용하여 rxMessageList를 선언
  RxList<SMSData> rxMessageList = <SMSData>[].obs;
  RxList<SMSData> rxMessageListCache = <SMSData>[].obs;
  List<SMSData> get messageList => rxMessageList;

  // 생성자 - 초기 메세지 내역 로딩
  Future init() async {
    await PermissionHelper.requestPermissions();
    await fetchMessage();
  }

  // 문자 내역 갱신
  Future fetchMessage() async {
    List<dynamic> smsList = [];
    List<SMSData> sms = [];
    List<String> filteredList = [];
    rxMessageList.clear(); // 초기화

    try {
      // 받은 메시지와 보낸 메시지 불러오기
      final String result =
          await ChannelProvider.platform.invokeMethod('getSms');
      final String myResult =
          await ChannelProvider.platform.invokeMethod('getSentSms');
      smsList = jsonDecode(result) + jsonDecode(myResult);

      // SMSData 객체로 저장
      for (var element in smsList) {
        sms.add(SMSData.fromMap(element));
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get messages: '${e.message}'.");
    } on FormatException catch (e) {
      debugPrint("Failed to decode messages: '${e.message}'.");
    }

    // 최신순으로 정렬
    sms.sort((a, b) => b.date.compareTo(a.date));

    // 최신 메시지만 하나만 넣고 나머지는 버린다.
    // 특정 연락처의 메시지가 추가되면 filteredList에 그 연락처를 넣고
    // 다음에 그 연락처의 메시지는 버린다.
    for (var element in sms) {
      if (!filteredList.contains(element.sender)) {
        rxMessageList.add(element);
        filteredList.add(element.sender);
      }
    }
    rxMessageListCache = rxMessageList;
  }
}
