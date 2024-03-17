// ignore_for_file: library_private_types_in_public_api

// import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;
  final int channelId; // Add the channelId parameter

  const ChatPage({
    super.key,
    required this.title,
    required this.channel,
    required this.channelId, // Add the channelId parameter
  });
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  String _username = ''; // Add a variable for username

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ??
          'Unknown'; // Retrieve the username or default to 'Unknown'
    });
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      widget.channel.sink.add(json.encode({
        'message': _textController.text,
        'username': _username,
        'room': widget.channelId
            .toString(), // Use the channel ID as the room identifier
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
                    decoration:
                        const InputDecoration(hintText: 'Send a message'),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
