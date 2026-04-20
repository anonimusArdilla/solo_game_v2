sealed class GameCommand {
  const GameCommand();
}

final class PauseCommand extends GameCommand {
  const PauseCommand();
}

final class ResumeCommand extends GameCommand {
  const ResumeCommand();
}

final class JumpCommand extends GameCommand {
  const JumpCommand();
}

final class SetMoveAxisCommand extends GameCommand {
  const SetMoveAxisCommand(this.axis);

  final double axis;
}

final class RestartCommand extends GameCommand {
  const RestartCommand();
}
