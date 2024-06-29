import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  int _score = 0;

  int get score => _score;

  Future<void> loadScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _score = prefs.getInt('score') ?? 0;
  }

  Future<void> saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('score', _score);
  }

  void incrementScore(int value) {
    _score += value;
    saveScore();
  }

  void decrementScore(int value) {
    if (_score - value < 0) {
      _score = value;
    } else {
      _score -= value;
    }
    saveScore();
  }

  int getScore() {
    return _score;
  }
}
