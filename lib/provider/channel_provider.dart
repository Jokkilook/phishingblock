import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ChannelProvider extends GetxController {
  static MethodChannel get platform =>
      const MethodChannel('com.jjj.phishingblock/sms');
}
