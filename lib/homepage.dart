import 'package:flutter/material.dart';
import 'dart:async';
import 'score_manager.dart';
import 'package:vibration/vibration.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int timeLeft = 5 * 60;
  Timer? _timer;
  final TextEditingController _controller = TextEditingController();
  final ScoreManager _scoreManager = ScoreManager();

  @override
  void initState() {
    super.initState();
    _scoreManager.loadScore();
  }

  void _endMeditation(bool success) async {
    setState(() {
      _timer?.cancel();
      _timer = null;
      timeLeft =
          _controller.text != "" ? int.parse(_controller.text) * 60 : 600;

      if (success) {
        _scoreManager.incrementScore(10);
        Vibration.vibrate(
            pattern: [1500, 700, 1500, 700, 1500, 700, 1500, 700]);
      }
    });
  }

  void _startMeditation() {
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _endMeditation(true);
        }
      });
    });
  }

  void forceEndMeditation() {
    _endMeditation(false);
    _scoreManager.decrementScore(5);
  }

  void _confirmEndMeditation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Do you want to skip this meditation?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                forceEndMeditation();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateTimeLimit(String value) {
    final int? minutes = int.tryParse(value);
    if (minutes != null) {
      setState(() {
        timeLeft = minutes * 60;
      });
    }
  }

  void _showEditTimeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Time"),
          content: TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter time in minutes',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Set"),
              onPressed: () {
                _updateTimeLimit(_controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int minutes = timeLeft ~/ 60;
    int seconds = timeLeft % 60;

    String formattedTime =
        "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Score: ${_scoreManager.getScore()}"),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 100),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _showEditTimeDialog,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 25.0),
                    child: Text(
                      "Edit",
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _timer == null ? _startMeditation : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 25.0, horizontal: 30),
                    child: Text(
                      "Start",
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                    onPressed: _timer != null ? _confirmEndMeditation : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      foregroundColor: Colors.white,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        "Stop",
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
