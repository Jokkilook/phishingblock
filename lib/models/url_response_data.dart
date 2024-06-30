import 'dart:convert';

class UrlResponseData {
  final int response;
  final String message;
  final String errorCode;
  final Data? data;

  UrlResponseData({
    required this.response,
    required this.message,
    required this.errorCode,
    required this.data,
  });

  UrlResponseData copyWith({
    int? response,
    String? message,
    String? errorCode,
    Data? data,
  }) {
    return UrlResponseData(
      response: response ?? this.response,
      message: message ?? this.message,
      errorCode: errorCode ?? this.errorCode,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'response': response,
      'message': message,
      'errorCode': errorCode,
      'data': data?.toMap(),
    };
  }

  factory UrlResponseData.fromMap(Map<String, dynamic> map) {
    return UrlResponseData(
      response: map['response'] != null ? map['response'].toInt() as int : 0,
      message: map['message'] != null ? map['message'] as String : '',
      errorCode: map['errorCode'] != null ? map['errorCode'] as String : '',
      data: map['data'] != null
          ? Data.fromMap(map['data'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UrlResponseData.fromJson(String source) =>
      UrlResponseData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Urlresponsedata(response: $response, message: $message, errorCode: $errorCode, data: $data)';
  }

  @override
  bool operator ==(covariant UrlResponseData other) {
    if (identical(this, other)) return true;

    return other.response == response &&
        other.message == message &&
        other.errorCode == errorCode &&
        other.data == data;
  }

  @override
  int get hashCode {
    return response.hashCode ^
        message.hashCode ^
        errorCode.hashCode ^
        data.hashCode;
  }
}

class ErrorCode {}

class Data {
  final String finalUrl;
  final bool isDanger;

  Data({
    required this.finalUrl,
    required this.isDanger,
  });

  Data copyWith({
    String? finalUrl,
    bool? isDanger,
  }) {
    return Data(
      finalUrl: finalUrl ?? this.finalUrl,
      isDanger: isDanger ?? this.isDanger,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'finalUrl': finalUrl,
      'isDanger': isDanger,
    };
  }

  factory Data.fromMap(Map<String, dynamic> map) {
    return Data(
      finalUrl: map['finalUrl'] as String,
      isDanger: map['isDanger'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Data.fromJson(String source) =>
      Data.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Data(finalUrl: $finalUrl, isDanger: $isDanger)';

  @override
  bool operator ==(covariant Data other) {
    if (identical(this, other)) return true;

    return other.finalUrl == finalUrl && other.isDanger == isDanger;
  }

  @override
  int get hashCode => finalUrl.hashCode ^ isDanger.hashCode;
}
