import 'dart:convert';

class SaveMSGData {
  final int response;
  final String message;
  final String? errorCode;
  final String? data;
  SaveMSGData({
    required this.response,
    required this.message,
    required this.errorCode,
    required this.data,
  });

  SaveMSGData copyWith({
    int? response,
    String? message,
    String? errorCode,
    String? data,
  }) {
    return SaveMSGData(
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
      'data': data
    };
  }

  factory SaveMSGData.fromMap(Map<String, dynamic> map) {
    return SaveMSGData(
      response: map['response'].toInt() as int,
      message: map['message'] as String,
      errorCode: map['errorCode'] as String?,
      data: map['data'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory SaveMSGData.fromJson(String source) =>
      SaveMSGData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SaveMSGData(response: $response, message: $message, errorCode: $errorCode, data: $data)';
  }

  @override
  bool operator ==(covariant SaveMSGData other) {
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

class Data {}
