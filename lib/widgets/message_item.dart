import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phishingblock/helper/utils.dart';
import 'package:phishingblock/models/danger_enum.dart';
import 'package:phishingblock/models/message_data.dart';
import 'package:phishingblock/models/sms_data.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({
    super.key,
    required this.data,
    this.msgData,
    required this.isLoading,
    this.showDay = true,
    this.showTime = true,
  });

  final SMSData data;
  final MessageData? msgData;
  final bool showDay;
  final bool showTime;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    bool mine = data.isMine ? true : msgData?.isMine ?? false;

    return Column(
      children: [
        //날짜 구분선 표시
        showDay
            ? Stack(alignment: Alignment.center, children: [
                Divider(
                  height: 40,
                  color: Colors.grey[300],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Text(
                    DateFormat("yyyy년 M월 dd일")
                        .format(DateTime.fromMillisecondsSinceEpoch(data.date))
                        .toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                )
              ])
            : Container(),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: data.isMine
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //왼쪽에 시간표시 (내 메세지일 때)
                  data.isMine && showTime
                      ? Text(
                          Utils.millisecondToTime(data.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        )
                      : Container(),

                  //메세지 버블
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      //위험하면 빨간색, 주의면 노란색, 무해하면 기본색
                      color: mine
                          ? const Color(0xFFEEEFFF)
                          : msgData?.danger == "danger"
                              ? Colors.red[400]
                              : (msgData?.danger == "caution"
                                  ? Colors.amber[800]
                                  : const Color(0xFF595FE5)),
                    ),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6),
                    padding: const EdgeInsets.all(10),
                    margin: data.isMine
                        ? const EdgeInsets.only(left: 4)
                        : const EdgeInsets.only(right: 4),
                    child: Text(
                      data.message,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: data.isMine ? Colors.black : Colors.white),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isLoading
                          ? const CircularProgressIndicator()
                          : mine ||
                                  (msgData?.danger == "innocent" ||
                                      msgData?.danger == null)
                              ? Container()
                              : const Icon(
                                  Icons.error,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                      //오른쪽에 시간표시 (상대 메세지일 때)
                      !data.isMine && showTime
                          ? Text(
                              Utils.millisecondToTime(data.date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
              mine || (msgData?.danger == "innocent" || msgData?.danger == null)
                  ? Container()
                  : const Text(" 피싱 위험이 있는 메세지입니다.")
            ],
          ),
        ),
      ],
    );
  }
}
