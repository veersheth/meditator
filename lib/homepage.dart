import 'package:flutter/material.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int timeLeft = 5 * 60; // 5 minutes in seconds
  Timer? _timer;
  final TextEditingController _controller = TextEditingController();

  void _endMeditation() {
    setState(() {
      _timer?.cancel();
      _timer = null;
    });
  }

  void _startMeditation() {
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _endMeditation();
        }
      });
    });
  }

  void forceEndMeditation() {
    // Logic to forcefully end the meditation
    _endMeditation();
    // Additional logic for force ending can be added here
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
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                forceEndMeditation();
                Navigator.of(context).pop(); // Close the dialog
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
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter time in minutes',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Set"),
              onPressed: () {
                _updateTimeLimit(_controller.text);
                Navigator.of(context).pop(); // Close the dialog and update time
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
            Text(
              timeLeft <= 0 ? 'DONE' : formattedTime,
              style: const TextStyle(fontSize: 100),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: _showEditTimeDialog,
                  elevation: 0,
                  child: const Text("Edit"),
                ),
                MaterialButton(
                  onPressed: _timer == null ? _startMeditation : null,
                  color: Colors.lightGreenAccent,
                  elevation: 0,
                  child: const Text("Start"),
                ),
                MaterialButton(
                  onPressed: _timer != null
                      ? _confirmEndMeditation
                      : null, // Enable button if timer is active
                  color: Colors.redAccent,
                  elevation: 0,
                  child: const Text("Stop"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer
        ?.cancel(); // Ensure the timer is canceled when the widget is disposed
    super.dispose();
  }
}
