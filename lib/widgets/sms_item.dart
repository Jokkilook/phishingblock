import 'package:flutter/material.dart';
import 'package:phishingblock/helper/utils.dart';
import 'package:phishingblock/models/sms_data.dart';

//ignore: must_be_immutable
class SMSItem extends StatelessWidget {
  const SMSItem({
    super.key,
    required this.displayName,
    this.displayedTime = "00:00",
    required this.data,
  });
  final SMSData data;
  final String displayName;
  final String displayedTime;

  @override
  Widget build(BuildContext context) {
    String sender = data.sender;
    if (sender == "#CMAS#Severe") {
      sender = "안전 안내 문자";
    }
    String checker = "";
    try {
      checker = displayName[0];
    } catch (e) {
      debugPrint(e.toString());
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          //첫글자가 한글로 저장된 연락처면 그 글자 표시, 아니면 기본 이미지 표시
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            clipBehavior: Clip.hardEdge,
            child: Container(
              decoration: BoxDecoration(
                color: displayName == "안전 안내 문자"
                    ? Colors.red[400]
                    : const Color(0x4F9999FF),
              ),
              width: 40,
              height: 40,
              child: Center(
                child: Utils.isHangul(checker)
                    ? (displayName == "안전 안내 문자"
                        ? const Icon(Icons.error, color: Colors.white)
                        : Text(
                            checker,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ))
                    : const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //수신자(연락처에 저장되어있으면 이름, 아니면 전화번호) 출력
                    Text(
                      Utils.formatPhoneNumber(displayName),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //시간 출력
                    Text(
                      displayedTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
                // const SizedBox(height: 8),
                //최근 메세지 출력
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 32,
                  child: Text(
                    data.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
