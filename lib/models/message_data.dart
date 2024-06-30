import 'dart:convert';

class MessageData {
  final String id;
  final String sender;
  final String message;
  final int date;
  final bool isMine;
  final String danger;

  MessageData({
    required this.id,
    required this.sender,
    required this.message,
    required this.date,
    required this.isMine,
    required this.danger,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'message': message,
      'date': date,
      'isMine': isMine,
      'danger': danger,
    };
  }

  factory MessageData.fromMap(Map<String, dynamic> map) {
    return MessageData(
      id: map['id'] ?? '',
      sender: map['sender'] ?? '',
      message: map['message'] ?? '',
      date: map['date'] ?? 0,
      isMine: map['isMine'] ?? false,
      danger: map['danger'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return "ID: $id, Sender: $sender, Message: $message, Date: $date, IsMine: $isMine, Danger: $danger";
  }

  factory MessageData.fromJson(String source) =>
      MessageData.fromMap(json.decode(source));
}
