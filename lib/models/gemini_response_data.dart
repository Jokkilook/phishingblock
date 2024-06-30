import 'dart:convert';

class GeminiResponseData {
  final String sender;
  final LinkData link;
  final NumberData number;
  final String? categories;

  GeminiResponseData({
    required this.sender,
    required this.link,
    required this.number,
    required this.categories,
  });

  factory GeminiResponseData.fromMap(Map<String, dynamic> map) {
    return GeminiResponseData(
      sender: map['sender'] as String,
      link: LinkData.fromMap(map['link'] as Map<String, dynamic>),
      number: NumberData.fromMap(map['number'] as Map<String, dynamic>),
      categories: map['categories'].toString() as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'link': link.toMap(),
      'number': number.toMap(),
      'categories': categories,
    };
  }

  String toJson() => json.encode(toMap());

  factory GeminiResponseData.fromJson(String source) =>
      GeminiResponseData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class LinkData {
  final double urlSimilarity;

  LinkData({
    required this.urlSimilarity,
  });

  factory LinkData.fromMap(Map<String, dynamic> map) {
    return LinkData(
      urlSimilarity: map['urlsimilarity']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'urlsimilarity': urlSimilarity,
    };
  }

  String toJson() => json.encode(toMap());

  factory LinkData.fromJson(String source) =>
      LinkData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class NumberData {
  final String? callNumber;
  final bool callNumberMatch;
  final String? falseNumber;
  final bool falseNumberMatch;

  NumberData({
    required this.callNumber,
    required this.callNumberMatch,
    required this.falseNumber,
    required this.falseNumberMatch,
  });

  factory NumberData.fromMap(Map<String, dynamic> map) {
    return NumberData(
      callNumber: map['callnumber'] as String?,
      callNumberMatch: map['callnumbermatch'] as bool,
      falseNumber: map['falsenumber'] as String?,
      falseNumberMatch: map['falsenumbermatch'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callnumber': callNumber,
      'callnumbermatch': callNumberMatch,
      'falsenumber': falseNumber,
      'falsenumbermatch': falseNumberMatch,
    };
  }

  String toJson() => json.encode(toMap());

  factory NumberData.fromJson(String source) =>
      NumberData.fromMap(json.decode(source) as Map<String, dynamic>);
}
