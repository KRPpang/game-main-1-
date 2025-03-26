import 'player.dart';
import 'brain.dart';

class Population {
  int popSize;
  List<Player> players = [];
  int gen = 1;
  double bestHeight = double.infinity;

  Population(this.popSize) {
    for (int i = 0; i < popSize; i++) {
      Player p = Player();
      // Now this works because Player has a public field 'brain'
      p.brain = Brain(10);
      players.add(p);
    }
  }

  void update(double dt) {
    for (var p in players) {
      p.update(dt);
    }
    for (var p in players) {
      if (p.position.y < bestHeight) {
        bestHeight = p.position.y;
      }
    }
  }
}
