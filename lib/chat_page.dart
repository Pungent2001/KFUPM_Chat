import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;

  ChatPage({Key? key, required this.title, required this.channel})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      // You might want to replace 'username' with the actual user's name and manage room ID dynamically if necessary.
      final String username = 'username'; // Placeholder for actual username
      final int roomId = 1; // Placeholder for actual room ID

      widget.channel.sink.add(json.encode({
        'message': _textController.text,
        'username': username,
        'room': roomId,
      }));

      _textController.clear();
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final Map<String, dynamic> data =
                      json.decode(snapshot.data.toString());
                  _messages.insert(0, data);
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(_messages[index]['message']),
                    subtitle: Text(_messages[index]['username']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(hintText: 'Send a message'),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
