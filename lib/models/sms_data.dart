// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SMSData {
  final String sender;
  final String message;
  final int date;
  final bool isMine;
  final bool? isDanger;

  SMSData({
    required this.sender,
    required this.message,
    required this.date,
    required this.isMine,
    this.isDanger = false,
  });

  SMSData copyWith({
    String? sender,
    String? message,
    int? date,
    bool? isMine,
    bool? isDanger,
  }) {
    return SMSData(
      sender: sender ?? this.sender,
      message: message ?? this.message,
      date: date ?? this.date,
      isMine: isMine ?? this.isMine,
      isDanger: isDanger ?? this.isDanger,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sender': sender,
      'message': message,
      'date': date,
      'isMine': isMine,
      'isDanger': isDanger,
    };
  }

  factory SMSData.fromMap(Map<String, dynamic> map) {
    return SMSData(
      sender: map['sender'] as String,
      message: map['message'] as String,
      date: map['date'] as int,
      isMine: map['isMine'] as bool,
      isDanger: map['isDanger'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory SMSData.fromJson(String source) =>
      SMSData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SMSData( sender: $sender, message: $message, date: $date, isMine: $isMine, isDanger: $isDanger )';

  @override
  bool operator ==(covariant SMSData other) {
    if (identical(this, other)) return true;

    return other.sender == sender &&
        other.message == message &&
        other.date == date &&
        other.isMine == isMine &&
        other.isDanger == isDanger;
  }

  @override
  int get hashCode =>
      sender.hashCode ^
      message.hashCode ^
      date.hashCode ^
      isMine.hashCode ^
      isDanger.hashCode;
}
