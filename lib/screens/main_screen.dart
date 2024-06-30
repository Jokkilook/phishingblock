import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phishingblock/helper/permission_helper.dart';
import 'package:phishingblock/helper/utils.dart';
import 'package:phishingblock/models/sms_data.dart';
import 'package:phishingblock/provider/contacts_provider.dart';
import 'package:phishingblock/provider/message_provider.dart';
import 'package:phishingblock/router/router.dart';
import 'package:phishingblock/widgets/sms_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final contactProvider = Get.find<ContactsProvider>();
  final messageProvider = Get.find<MessageProvider>();

  @override
  void initState() {
    super.initState();
    PermissionHelper.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('피싱블록'),
        actions: const [
          // IconButton(
          //     onPressed: () {
          //       router.pushNamed(Screen.setting);
          //     },
          //     icon: const Icon(Icons.more_vert))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          router.pushNamed(Screen.contacts);
        },
        backgroundColor: const Color(0xFF595FE5),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_comment),
      ),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: messageProvider.rxMessageList.length,
          itemBuilder: (context, index) {
            //GetX 컨트롤러에서 SMSData 리스트를 가져온다.
            SMSData data = messageProvider.rxMessageList[index];
            //000-0000-0000 형식으로 저장된 연락처와 00000000000 형식으로 저장된 연락처가 있어서
            //두 방식 다 필터링해서 저장된 연락처의 이름을 보여준다.
            var name = contactProvider.rxContacts[data.sender] ??
                contactProvider
                    .rxContacts[Utils.formatPhoneNumber(data.sender)];
            String time = Utils.formatTime(now, data.date);

            return InkWell(
              onTap: () {
                router.pushNamed(Screen.detail, extra: {
                  "name": data.sender == "#CMAS#Severe" ? "안전 안내 문자" : name,
                  "sender": data.sender,
                }).then(
                  (value) async {
                    messageProvider.fetchMessage();
                  },
                );
              },
              child: SMSItem(
                displayName: data.sender == "#CMAS#Severe"
                    ? "안전 안내 문자"
                    : name ?? data.sender,
                displayedTime: time,
                data: data,
              ),
            );
          },
        ),
      ),
    );
  }
}
