sealed class GameEvent {
  const GameEvent();
}

final class GameReadyEvent extends GameEvent {
  const GameReadyEvent();
}

final class ScoreChangedEvent extends GameEvent {
  const ScoreChangedEvent({
    required this.score,
    required this.combo,
    required this.maxCombo,
    required this.lives,
  });

  final int score;
  final int combo;
  final int maxCombo;
  final int lives;
}

final class GameOverEvent extends GameEvent {
  const GameOverEvent({required this.score, required this.maxCombo});

  final int score;
  final int maxCombo;
}

final class GameErrorEvent extends GameEvent {
  const GameErrorEvent(this.message);

  final String message;
}
