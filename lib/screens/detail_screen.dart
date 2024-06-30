import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phishingblock/helper/notification_helper.dart';
import 'package:phishingblock/helper/storage_helper.dart';
import 'package:phishingblock/helper/utils.dart';
import 'package:phishingblock/models/message_data.dart';
import 'package:phishingblock/models/sms_data.dart';
import 'package:phishingblock/provider/channel_provider.dart';
import 'package:phishingblock/widgets/message_item.dart';

//ignore: must_be_immutable
class DetailScreen extends StatefulWidget {
  DetailScreen({super.key, required this.displayName, required this.sender});
  String? displayName;
  String sender;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<dynamic> messageList = [];
  List<SMSData> sms = [];
  String get sender => widget.sender;
  String? get displayedName => widget.displayName;
  List<SMSData> mySms = [];
  List<SMSData> totalSms = [];
  List<MessageData> testedMessage = [];
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getMessage();
    refresh();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future refresh() async {
    testedMessage = StorageHelper.getMessageBySender(sender);
    print("LIST: $testedMessage");
    setState(() {});
  }

  //해당 연락처와의 메세지 가져오기
  Future getMessage() async {
    try {
      final String result = await ChannelProvider.platform.invokeMethod(
        'getSmsBySender',
        {'sender': sender},
      );

      List<dynamic> messagesList = jsonDecode(result);

      for (var element in messagesList) {
        sms.add(SMSData.fromMap(element));
      }

      messageList =
          messagesList.map<String>((sms) => sms['message'] as String).toList();

      final String myResult = await ChannelProvider.platform.invokeMethod(
        'getSentSmsByRecipient',
        {'recipient': sender},
      );

      List<dynamic> myMessagesList = jsonDecode(myResult);

      for (var element in myMessagesList) {
        mySms.add(SMSData.fromMap(element));
      }

      totalSms = sms + mySms;

      totalSms.sort((a, b) => (DateTime.fromMillisecondsSinceEpoch(b.date)
          .compareTo(DateTime.fromMillisecondsSinceEpoch(a.date))));
    } on PlatformException catch (e) {
      messageList = ["Failed to get messages: '${e.message}'"];
    } on FormatException catch (e) {
      messageList = ["Failed to decode messages: '${e.message}'"];
    }

    setState(() {});
  }

  //메세지 보내기
  Future sendMessage(String phoneNumber, String message) async {
    try {
      await ChannelProvider.platform.invokeMethod(
          'sendSms', {'phoneNumber': phoneNumber, 'message': message});
    } on PlatformException catch (e) {
      debugPrint("Failed to send SMS: ${e.message}");
    }
  }

  //전화 걸기
  Future makePhoneCall(String phoneNumber) async {
    try {
      await ChannelProvider.platform
          .invokeMethod('callPhoneNumber', {'phoneNumber': phoneNumber});
    } on PlatformException catch (e) {
      debugPrint("Failed to make phone call: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    String? displayedSender = displayedName;
    String displayedNumber = sender;
    if (displayedNumber == "#CMAS#Severe") {
      displayedNumber = "";
    } else if (!displayedNumber.contains("-")) {
      displayedNumber = Utils.formatPhoneNumber(displayedNumber);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //연락처에 저장되면 뜨는 이름 or 저장 안 된 번호 뜨는 곳
            displayedSender == null ? Container() : Text(displayedSender),
            //연락처에 저장된 이름의 전화번호
            displayedNumber == ""
                ? Container()
                : Text(
                    displayedNumber,
                    style: TextStyle(
                        fontSize: displayedSender == null ? null : 16),
                  ),
          ],
        ),
        actions: [
          // InkWell(
          //   onTap: () {
          //     setState(() {});
          //   },
          //   enableFeedback: false,
          //   child: Container(
          //     width: 100,
          //     height: 100,
          //     color: Colors.transparent,
          //   ),
          // ),
          IconButton(
            onPressed: () async {
              await makePhoneCall(sender);
            },
            icon: const Icon(Icons.phone_enabled),
          )
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                reverse: true,
                itemCount: totalSms.length,
                itemBuilder: (context, index) {
                  bool showDay = false;
                  bool showTime = false;
                  try {
                    //날짜 구분선 출력 여부 (한칸 위 메세지가 다른 날짜면 날짜 구분선 출력)
                    var currentDay = DateTime.fromMillisecondsSinceEpoch(
                            totalSms[index].date)
                        .day;

                    var oneDayAgo = DateTime.fromMillisecondsSinceEpoch(
                            totalSms[index + 1].date)
                        .day;

                    if (currentDay != oneDayAgo) {
                      showDay = true;
                    }
                  } catch (e) {
                    //한칸 위 메세지가 없으면 날짜 구분선 출력
                    showDay = true;
                  }

                  try {
                    //시간출력 여부 결정 (한칸 아래의 메세지가 다른사람이 보낸것 이거나 보낸 시간이 다르면 showTime=true)
                    if (totalSms[index].isMine != totalSms[index - 1].isMine ||
                        DateTime.fromMillisecondsSinceEpoch(
                                    totalSms[index].date)
                                .minute !=
                            DateTime.fromMillisecondsSinceEpoch(
                                    totalSms[index - 1].date)
                                .minute) {
                      showTime = true;
                    }
                  } catch (e) {
                    //한칸 아래 메세지가 없으면 시간 출력
                    showTime = true;
                  }

                  //위험도 평가된 메세지 중에 해당 메세지가 있으면 위험도 평가된 메세지 데이터 입력
                  MessageData? testedData;

                  for (var message in testedMessage) {
                    print("message.date: ${message.date}");
                    print("totalSms[index].date: ${totalSms[index].date}");
                    if (message.date == totalSms[index].date) {
                      testedData = message;
                    }
                  }

                  print("WHAT?????: $testedData");
                  bool isLoading = false;
                  return InkWell(
                    onTap: () async {
                      if (totalSms[index].isMine || testedData != null) return;
                      setState(() {
                        isLoading = true;
                      });
                      NotificationHelper.onSmsReceived({
                        "smsMessage":
                            "SMS from ${totalSms[index].sender} : ${totalSms[index].message}",
                        'receivedTime': totalSms[index].date,
                      });

                      refresh();
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: MessageItem(
                      isLoading: isLoading,
                      msgData: testedData,
                      data: totalSms[index],
                      showDay: showDay,
                      showTime: showTime,
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              constraints: const BoxConstraints(minHeight: 50, maxHeight: 200),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      maxLength: 70,
                      minLines: 1,
                      maxLines: 4,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        counterText: "",
                        suffixText:
                            '${messageController.text.length.toString()}/70',
                        suffixStyle:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        hintText: "메시지를 입력하세요.",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                        filled: true,
                        fillColor: const Color(0xFFEEEFFF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  //보내기 버튼
                  IconButton.filled(
                    style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Color(0xFF595fe5))),
                    constraints: const BoxConstraints(
                        minHeight: 50,
                        maxHeight: 200,
                        minWidth: 50,
                        maxWidth: 50),
                    onPressed: () async {
                      var message = messageController.text;

                      //텍스트 입력창이 비었으면 바로 종룐
                      if (message == "") return;

                      //메세지 보내기
                      await sendMessage(sender, message);
                      //보낸 후 내가 보낸 메세지가 버블로 나오게 추가
                      totalSms.insert(
                        0,
                        SMSData(
                            sender: sender,
                            message: message,
                            date: DateTime.now().millisecondsSinceEpoch,
                            isMine: true),
                      );
                      messageController.clear();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.send,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
