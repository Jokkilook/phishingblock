//위험도 ENUM
//innocent : 무해 (기본색)
//caution : 주의 (노랑)
//danger : 위험 (빨강)

enum Danger {
  innocent,
  caution,
  danger,
}

extension DangerExtension on Danger {
  String get name {
    switch (this) {
      case Danger.innocent:
        return 'innocent';
      case Danger.caution:
        return 'caution';
      case Danger.danger:
        return 'danger';
    }
  }

  static Danger fromString(String name) {
    switch (name) {
      case 'innocent':
        return Danger.innocent;
      case 'caution':
        return Danger.caution;
      case 'danger':
        return Danger.danger;
      default:
        throw Exception('Unknown danger level: $name');
    }
  }
}
