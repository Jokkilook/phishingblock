import 'dart:convert';

import 'package:phishingblock/models/message_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static late SharedPreferences prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  ///전화번호 별로 저장된 위험도가 평가된 메세지 데이터를 기기의 저장소에 저장한다.
  ///[ sender ] : 메세지를 보낸 상대의 전화번호.
  static List<MessageData> getMessageBySender(String sender) {
    //기존에 저장된 데이터를 불러온다.(String 리스트) 없으면 빈 배열 반환
    List<String> list = prefs.getStringList(sender) ?? [];
    //반환할 MeesageData 리스트
    List<MessageData> messageList = [];

    //반환된 String 리스트를 MessageData로 변환해 messageList에 넣는다.
    for (var stringMessage in list) {
      messageList.add(MessageData.fromJson(stringMessage));

      // MessageData jsonMessage = MessageData.fromMap(jsonDecode(stringMessage));

      // messageList.add(jsonMessage);
    }

    return messageList;
  }

  ///전화번호 별로 위험도가 평가된 메세지 데이터를 저장한다.
  ///[ sender ] : 메세지를 불러올 상대의 전화번호.
  ///[ messageData ] : 저장할 메세지 데이터 MessageData 타입.
  static Future saveMessageBySender(
    String sender,
    MessageData messageData,
  ) async {
    //기존에 저장된 데이터를 불러온다.(String 리스트) 없으면 빈 배열 반환
    List<String> originData = prefs.getStringList(sender) ?? [];
    //추가할 messageData를 json화 시켜 String 으로 변환한다.
    String extraData = messageData.toJson();
    //변환한 String을 기존 String 리스트에 추가한다.
    originData.add(extraData);
    //데이터가 추가된 리스트를 다시 저장한다.
    await prefs.setStringList(sender, originData);
  }
}
