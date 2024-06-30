import 'package:contacts_service/contacts_service.dart';
import 'package:get/get.dart';
import 'package:phishingblock/helper/permission_helper.dart';
import 'package:phishingblock/provider/channel_provider.dart';

class ContactsProvider extends GetxController {
  final channelController = Get.find<ChannelProvider>();

  //메인화면에서 사용할 연락처 저장소 키가 번호이다.
  RxMap<String, String> rxContacts = <String, String>{}.obs;
  //연락처 조회 화면에서 사용할 키가 이름인 저장소.
  RxMap<String, String> rxNameKeyContacts = <String, String>{}.obs;

  RxList<String> keyList = <String>[].obs;

  Map<String, String> get contacts => rxContacts;

  // 생성자 - 초기 연락처 로딩
  Future init() async {
    await PermissionHelper.requestPermissions();
    await fetchContacts();
  }

  // 연락처 갱신
  Future fetchContacts() async {
    rxContacts.clear();
    keyList.clear();

    Iterable<Contact> contacts = await ContactsService.getContacts();
    for (var contact in contacts) {
      for (var phone in contact.phones!) {
        rxContacts[phone.value!] = contact.displayName ?? phone.value!;
        rxNameKeyContacts[contact.displayName ?? phone.value!] = phone.value!;
      }
    }

    keyList.assignAll(rxNameKeyContacts.keys.toList());
    keyList.toSet().toList();
    keyList.sort((a, b) => a.compareTo(b));
  }
}
