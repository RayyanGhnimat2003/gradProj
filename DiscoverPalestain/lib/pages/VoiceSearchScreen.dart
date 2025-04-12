import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchScreen extends StatefulWidget {
  @override
  _VoiceSearchScreenState createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen> {
  TextEditingController searchController = TextEditingController();
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;

  void startListening() async {
    bool available = await speech.initialize(
      onStatus: (status) => print('Speech Status: $status'),
      onError: (error) => print('Speech Error: $error'),
    );

    if (available) {
      setState(() {
        isListening = true;
      });

      speech.listen(
        onResult: (result) {
          setState(() {
            searchController.text = result.recognizedWords;
          });
        },
        onSoundLevelChange: (level) {
          print("Sound level: $level");
        },
      );
    }
  }

  void stopListening() {
    setState(() {
      isListening = false;
    });
    speech.stop();
  }

  void confirmSearch() {
    Navigator.pop(context, searchController.text); // يرجع النص المدخل للشاشة السابقة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Voice Search"), backgroundColor: Colors.teal),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Search",
                  prefixIcon: Icon(Icons.search, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            IconButton(
              icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: Colors.teal, size: 40),
              onPressed: isListening ? stopListening : startListening,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: confirmSearch,
              child: Text("Search"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
