import 'dart:math';

class AIAction {
  bool isJump;
  double holdTime; // A value between 0.1 and 1 representing jump strength.
  int xDirection; // -1 for left, 0 for none, 1 for right.

  AIAction(this.isJump, this.holdTime, this.xDirection);

  AIAction clone() => AIAction(isJump, holdTime, xDirection);

  void mutate() {
    holdTime += Random().nextDouble() * 0.6 - 0.3;
    if (holdTime < 0.1) holdTime = 0.1;
    if (holdTime > 1) holdTime = 1;
  }
}

class Brain {
  List<AIAction> instructions = [];
  int currentInstructionIndex = 0;

  Brain(int size, {bool randomize = true}) {
    if (randomize) {
      for (int i = 0; i < size; i++) {
        instructions.add(getRandomAction());
      }
    }
  }

  AIAction getRandomAction() {
    bool isJump = Random().nextDouble() > 0.5;
    double holdTime = Random().nextDouble();
    List<int> directions = [-1, -1, -1, 0, 1, 1, 1];
    int xDirection = directions[Random().nextInt(directions.length)];
    return AIAction(isJump, holdTime, xDirection);
  }

  AIAction? getNextAction() {
    if (currentInstructionIndex >= instructions.length) return null;
    return instructions[currentInstructionIndex++];
  }

  Brain clone() {
    Brain b = Brain(0, randomize: false);
    for (var action in instructions) {
      b.instructions.add(action.clone());
    }
    return b;
  }

  void mutate() {
    double mutationRate = 0.1;
    for (int i = 0; i < instructions.length; i++) {
      if (Random().nextDouble() < mutationRate) {
        instructions[i].mutate();
      }
    }
  }

  void increaseMoves(int increaseBy) {
    for (int i = 0; i < increaseBy; i++) {
      instructions.add(getRandomAction());
    }
  }
}
