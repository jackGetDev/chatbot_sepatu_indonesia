import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _inputController = TextEditingController();
  List<Map<String, dynamic>> _pairs = [];
  List<Map<String, dynamic>> _initialInteraction = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadChatbotData().then((data) {
      setState(() {
        _pairs = data;
        _initialInteraction = getInitialInteraction(data);
        _messages.addAll(_initialInteraction);
      });
    });
  }

  Future<List<Map<String, dynamic>>> loadChatbotData() async {
    String data = await rootBundle.loadString('assets/json/chatbot_data.json');
    Map<String, dynamic> jsonData = json.decode(data);
    return List<Map<String, dynamic>>.from(jsonData['pairs']);
  }

  List<Map<String, dynamic>> getInitialInteraction(
      List<Map<String, dynamic>> pairs) {
    return pairs.where((pair) => pair['initial'] == true).toList();
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        _inputController.clear();
        _messages.add({"sender": "User", "message": message});
        _messages.add({"sender": "Bot", "message": getResponse(message)});
      });
    }
  }

  String getResponse(String message) {
    for (var pair in _pairs) {
      RegExp pattern = RegExp(pair['pattern']);
      if (pattern.hasMatch(message)) {
        List<dynamic> responses = pair['responses'];
        return responses[0];
      }
    }
    return "Maaf, saya tidak sepenuhnya memahami. Bisakah Anda mengulanginya atau memberi tahu saya dengan kata lain?";
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: message['sender'] == 'User'
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (message['sender'] == 'Bot')
            CircleAvatar(
              child: Icon(Icons.headset_mic),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: message['sender'] == 'User' ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.all(12.0),
              child: Text(
                message['message'],
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (message['sender'] == 'User')
            CircleAvatar(
              child: Icon(Icons.person),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Customer Service',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.blue,
          actions: [
            Row(
              children: [
                Icon(
                  Icons.wb_sunny,
                  color: _isDarkMode ? Colors.grey : Colors.yellow,
                ),
                Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                  },
                  activeTrackColor: Colors.grey.shade300,
                  activeColor: Colors.white,
                ),
                Icon(
                  Icons.nights_stay,
                  color: _isDarkMode ? Colors.indigo : Colors.grey,
                ),
              ],
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(
                      _messages[_messages.length - index - 1]);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _inputController,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: "Ask...",
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black
                                  : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 16.0),
                          prefixIcon: const Icon(Icons.message),
                          hintStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54,
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _sendMessage(_inputController.text);
                    },
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(ChatPage());
}
