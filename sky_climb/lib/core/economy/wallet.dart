final class Wallet {
  const Wallet({required this.soft, required this.hard});

  final int soft;
  final int hard;

  Wallet copyWith({int? soft, int? hard}) {
    return Wallet(soft: soft ?? this.soft, hard: hard ?? this.hard);
  }
}
