import 'dart:convert';

import 'package:easy_extension/easy_extension.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:phishingblock/models/save_msg_data.dart';
import 'package:http/http.dart' as http;
import 'package:validators/validators.dart' as validators;
import 'package:phishingblock/models/url_response_data.dart';

class Utils {
  ///int형의 milliseconds 값을 HH:mm 형식의 문자열로 변환
  static String millisecondToTime(int milliseconds) {
    // Epoch 시간으로부터 경과된 시간을 DateTime으로 변환
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    // DateTime 객체에서 HH:mm 형식의 시간 문자열로 변환
    String formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    //${dateTime.year} ${dateTime.month}/${dateTime.day}
    return formattedTime;
  }

  ///00000000000 => 000-0000-0000 로 변환하는 함수
  static String formatPhoneNumber(String phoneNumber) {
    // 정규 표현식을 사용하여 숫자 3자리, 4자리, 4자리로 나누어서 변환
    RegExp regExp = RegExp(r'^(\d{3})(\d{4})(\d{4})$');
    return phoneNumber.replaceAllMapped(
        regExp, (match) => '${match[1]}-${match[2]}-${match[3]}');
  }

  ///메세지 보낸 시간 or 날짜 출력하는 함수
  static String formatTime(DateTime now, int milliseconds) {
    String result = "00:00";
    DateTime time = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    if (now.year != time.year) {
      result = DateFormat('yyyy년 M월 d일').format(time);
    } else if (now.day != time.day) {
      result = DateFormat('M월 d일').format(time);
    } else {
      result = DateFormat('HH:mm').format(time);
    }

    return result;
  }

  ///초성따기
  static String getInitials(String input) {
    final List<String> initialChars = [
      'ㄱ',
      'ㄲ',
      'ㄴ',
      'ㄷ',
      'ㄸ',
      'ㄹ',
      'ㅁ',
      'ㅂ',
      'ㅃ',
      'ㅅ',
      'ㅆ',
      'ㅇ',
      'ㅈ',
      'ㅉ',
      'ㅊ',
      'ㅋ',
      'ㅌ',
      'ㅍ',
      'ㅎ'
    ];

    String result = '';
    for (int i = 0; i < input.length; i++) {
      int codeUnit = input.codeUnitAt(i);
      if (codeUnit >= 44032 && codeUnit <= 55203) {
        // 한글 범위 내에서 초성 인덱스 계산
        int initialIndex = ((codeUnit - 44032) / 28 / 21).floor();
        result += initialChars[initialIndex];
      } else {
        // 한글이 아닌 경우 그대로 추가
        result += input[i];
      }
    }

    return result;
  }

  ///초성 검색
  static bool containsSearch(String input, String search) {
    String inputInitials = getInitials(input);
    String searchInitials = getInitials(search);

    return inputInitials.toLowerCase().contains(searchInitials.toLowerCase());
  }

  ///초성인지 확인
  static bool isChosungCharacter(String char) {
    const List<String> chosungs = [
      'ㄱ',
      'ㄲ',
      'ㄴ',
      'ㄷ',
      'ㄸ',
      'ㄹ',
      'ㅁ',
      'ㅂ',
      'ㅃ',
      'ㅅ',
      'ㅆ',
      'ㅇ',
      'ㅈ',
      'ㅉ',
      'ㅊ',
      'ㅋ',
      'ㅌ',
      'ㅍ',
      'ㅎ'
    ];
    return chosungs.contains(char);
  }

  ///초성으로 이루어진 검색어인지 확인
  static bool isEntirelyChosung(String input) {
    for (int i = 0; i < input.length; i++) {
      if (!isChosungCharacter(input[i])) {
        return false;
      }
    }
    return true;
  }

  ///링크 추출 함수
  static List<String> linkTrimHelper(String input) {
    final RegExp urlRegExp = RegExp(
      r'https?://[^\s"<>{}\|\\^`]+',
      caseSensitive: false,
    );

    final Iterable<Match> matches = urlRegExp.allMatches(input);

    return matches
        .map((match) {
          String url = match.group(0)!;
          // 검증하여 유효한 URL만 반환
          if (validators.isURL(url)) {
            return url;
          } else {
            return '';
          }
        })
        .where((url) => url.isNotEmpty)
        .toList();
  }

  ///메세지를 서버 데이터 베이스에 저장
  static Future<Object?> msgToDatabaseHelper(
      content, isContainURL, isContainNumber, sender, category) async {
    //[Web발신]][CJ대한통운] 등기소포 배송불가(주소불명)주소지확인 http://jeon.lloyd.com

    await dotenv.load(fileName: ".env");
    String phishingblockURL = dotenv.get("phishingblockURL");

    var response = await http.post(Uri.parse(phishingblockURL),
        headers: {
          "Content-Type": "application/json",
          "auth":
              "InBoaXNpbmdXaWxsRmlyc3RQcmljZSI=.5688524c01609be986506ad56fc76c28436019a9ea4f418c89b43c9eeadb5bd2"
        },
        body: jsonEncode([
          {
            "operation": "SaveMessage",
            "param": {
              "content": content,
              "isContainURL": isContainURL,
              "isContainNumber": isContainNumber,
              "sender": sender,
              "category": category
            }
          }
        ]));

    var status = response.statusCode;
    var body = response.body;
    Log.red("BBBBB $status, $body");
    var list = jsonDecode(body);
    for (var one in list) {
      SaveMSGData a = SaveMSGData.fromMap(one);
      return a;
    }

    if (status != 200) {
      Log.red('d레ㅓ $status, $body');
      return null;
    }
    return null;
  }

  ///'true', 'false'의 문자열을 bool로 변환
  ///이 외의 문자열은 false 반환
  static bool stringToBool(Object? object) {
    if (object == null) {
      return false;
    }

    String str = object.toString().toLowerCase();
    return str == 'true';
  }

  ///Url 위험도 검사 함수
  ///반환값 : true => 위험 / false => 무해
  static Future<UrlResponseData?> urlVerificationHelper(url) async {
    //[Web발신]][CJ대한통운] 등기소포 배송불가(주소불명)주소지확인 http://jeon.lloyd.com

    await dotenv.load(fileName: ".env");
    String phishingblockURL = dotenv.get("phishingblockURL");

    var response = await http.post(Uri.parse(phishingblockURL),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode([
          {
            "operation": "CheckURLDanger",
            "param": {"url": url}
          }
        ]));

    var status = response.statusCode;
    var body = response.body;
    Log.red("AAAAA $status, $body");
    var list = jsonDecode(body);
    for (var one in list) {
      UrlResponseData a = UrlResponseData.fromMap(one); // 수정된 부분
      Log.red(a.data?.finalUrl);
      Log.red(a.data?.isDanger);
      return a;
    }

    if (status != 200) {
      Log.red('d레ㅓ $status, $body');
      return null;
    }
    return null;
  }

  ///한글자만 넣는다
  ///한글자가 한글인지 아닌지 판독하는 함수
  static bool isHangul(String input) {
    if (input.length != 1) {
      throw ArgumentError('Input must be a single character.');
    }

    int codeUnit = input.codeUnitAt(0);

    // 한글 음절 (가~힣): U+AC00 ~ U+D7AF
    if (codeUnit >= 0xAC00 && codeUnit <= 0xD7AF) {
      return true;
    }

    // 한글 자모 (초성, 중성, 종성): U+1100 ~ U+11FF
    if (codeUnit >= 0x1100 && codeUnit <= 0x11FF) {
      return true;
    }

    // 한글 호환 자모: U+3130 ~ U+318F
    if (codeUnit >= 0x3130 && codeUnit <= 0x318F) {
      return true;
    }

    return false;
  }
}
