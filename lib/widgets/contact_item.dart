import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phishingblock/helper/utils.dart';

class ContactItem extends StatelessWidget {
  const ContactItem({super.key, required this.data});
  final (String, String) data;

  @override
  Widget build(BuildContext context) {
    final String name = data.$1;
    final String number = data.$2;

    String checker = "";
    try {
      checker = name[0];
    } catch (e) {
      debugPrint(e.toString());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          //첫글자가 한글로 저장된 연락처면 그 글자 표시, 아니면 기본 이미지 표시
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            clipBehavior: Clip.hardEdge,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0x4F9999FF),
              ),
              width: 40,
              height: 40,
              child: Center(
                child: Utils.isHangul(checker)
                    ? Text(
                        checker,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      )
                    : const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //저장된 이름 출력
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                //전화번호 출력
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    Utils.formatPhoneNumber(number),
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
