import 'package:easy_extension/easy_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

import 'package:phishingblock/models/gemini_response_data.dart';

class Gemini {
//Future<Map<String, dynamic>>
  static Future<GeminiResponseData?> geminiSmsVerification(
      text, sender, finalUrl) async {
    await dotenv.load(fileName: ".env");
    String geminikey = dotenv.get("GEMINI_API_KEY");

    // if (geminikey == null) {
    //     Log.green('No \$API_KEY environment variable');
    //     exit(1);
    // }
    // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
    // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts// Generation Configuration
    // final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminikey);
    final config = GenerationConfig(
        temperature: 0,
        maxOutputTokens: 100,
        topP: 1.0,
        topK: 40,
        stopSequences: [],
        responseMimeType: "application/json");
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ];
    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminikey,
        generationConfig: config,
        safetySettings: safetySettings);
    final content = [
      Content.text('''
너는 스미싱 문자를 걸러내는 스미싱 분야의 최고 전문가야.
다음은 무고한 시민이 수신한 메세지야. 발신번호와 함께 주어질거야. 이 메세지에 링크가 포함되어 있으면 redirect가 끝난 최종 링크가 주어질거야. 

그리고 문자 메시지에는 발신자로 예상되는 어떤 기관이나 단체의 명칭이 포함되어 있을거야. 그 기관이나 단체의 대표 홈페이지 url 을 알아봐주고 기억하고 있어줘. 
그리고 그 기관이나 단체의 자회사이거나 계열사처럼 관계가 있을 가능성도 있어. 
그래서 기관이나 단체의 이름의 대표 영문명과 주어진 redirect가 끝난 최종 링크의 유사도를 0.0부터 10.0까지의 수치로 검사해서  아래 'VerificationResult'의 'link'의' 'urlsimilarity' 키의 값으로 입력해줘.
주어진 메시지의 발신자로 보이는 기관이나 단체의 대표 홈페이지 url을 모르거나 없으면 0.0을 입력해. 

이 메세지에 전화번호가 포함되어 있으면 그 기관이나 단체의 대표 전화번호를아래 'VerificationResult'의 'number'의 'callnumber' 키의 값으로 입력해줘 . 
일치하지 않거나 대표 전화번호를 모르면 null을 입력하고, 'VerificationResult'의 'number'의 'falsenumber' 키의 값에 메세지 본문에 적힌 전화번호를 입력해줘. 
발신자의 전화번호가 주어질텐데 그 번호도  'VerificationResult'의 'sender' 키의 값으로 입력해줘. 
이 sender가 falsenumber, callnumber와 일치하는지도 검사해서  그 bool 값을 'VerificationResult'의 'number'의 'callnumbermatch'와 'falsenumbermatch' 키의 자리에 각각 입력해줘.

이 문자의 내용이 "택배/배송","금전/계좌/송금","이벤트/상품","관공서/기관","인증/인증번호","긴급 알림","청첩장/초대장","명절"중 관련 있는 것이 있다면 이것을 {"categories":""}에 입력해줘. 
이 중에 포함되거나 비슷한 게 없다면 그 때에만 null을 입력해도 좋아.

Using this JSON schema:    VerificationResult =  {"sender":string, "link": {"urlsimilarity":float},"number":{{"callnumber":string,"callnumbermatch":bool,"falsenumber":string,"falsenumbermatch":bool}},"categories":string} Return a `VerificationResult`
없거나 모르는 값은 반드시 null을 입력해야해
모든 값을 출력한 이후에는 반드시 데이터를 삭제해. 다음은 메세지 본문과 발신자 번호(sender)야. 내가 말한 작업을 수행해줘.
content:$text sender:$sender finalUrl:$finalUrl''')
    ];
    final response = await model.generateContent(content);
    Log.blue(response.text);

    if (response.text != null) {
      String output = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .replaceAll("\n", "")
          .replaceAll(" ", "");
      // JSON 문자열을 파싱하여 Dart 객체로 변환
      Map<String, dynamic> responseData = jsonDecode(output);

      // 필요한 데이터 클래스 인스턴스로 변환
      GeminiResponseData result = GeminiResponseData.fromMap(responseData);

      // JSON 형식으로 반환
      return result;
    } else {
      return null;
    }
  }
}
