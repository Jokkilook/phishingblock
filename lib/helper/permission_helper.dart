import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // 연락처, SMS, 전화 권한 요청하기
  static Future<void> requestPermissions() async {
    // 연락처 권한 요청
    PermissionStatus contactsStatus = await Permission.contacts.status;
    if (!contactsStatus.isGranted) {
      contactsStatus = await Permission.contacts.request();
    }

    // SMS 권한 요청
    PermissionStatus smsStatus = await Permission.sms.status;
    if (!smsStatus.isGranted) {
      smsStatus = await Permission.sms.request();
    }

    // 알림 권한 요청
    PermissionStatus notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      final int sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      if (sdkInt >= 33) {
        notificationStatus = await Permission.notification.request();
      }
    }

    // 전화 권한 요청
    PermissionStatus callStatus = await Permission.phone.status;
    if (!callStatus.isGranted) {
      callStatus = await Permission.phone.request();
    }
  }
}
