// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kfupm_chat/image_upload_page.dart';
import 'package:kfupm_chat/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;
  final int channelId;

  const ChatPage({
    super.key,
    required this.title,
    required this.channel,
    required this.channelId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  String _username = '';
  late String _apiUrl; // Will hold the fetched API URL

  @override
  void initState() {
    super.initState();
    _fetchInitialMessages().then((_) {
      _setupWebSocket();
    });
    _loadUsername();
    _fetchApiUrl().then((url) {
      if (mounted) {
        setState(() {
          _apiUrl = "https://$url";
          print("initiated url:");
          print(url);
        });
      }
    });
  }

  Future<void> _fetchInitialMessages() async {
    var apiUrl = await _getApiUrl(); // Ensure you handle the API URL correctly
    var session = await getSession();
    String sessionToken = session[0];
    String sessionID = session[1];
    var response =
        await http.get(Uri.parse('https://$apiUrl/api/getmessages'), headers: {
      "Cookie": 'csrftoken=$sessionToken; sessionid=$sessionID',
      "channel-id": widget.channelId.toString()
    });
    if (response.statusCode == 200) {
      List<dynamic> messages = jsonDecode(response.body);
      setState(() {
        _messages.addAll(messages.reversed
            .map((messageJson) => {
                  'username': messageJson['sender'],
                  'message': messageJson['image'] ?? messageJson['content'],
                  'time': messageJson['date'],
                  'isImage': messageJson['image'] != null,
                })
            .toList());
      });
    } else {
      // Handle error, perhaps by showing a message
      print("Failed to fetch messages: ${response.statusCode}");
    }
  }

  void _setupWebSocket() {
    widget.channel.stream.listen((data) {
      var jsonData = jsonDecode(data);
      _addMessageFromJson(jsonData);
    });
  }

  void _addMessageFromJson(Map<String, dynamic> messageJson) {
    print("adding message from json");
    print(messageJson);
    _messages.add({
      'username': messageJson['sender'],
      'message': messageJson['image'] ?? messageJson['content'],
      'time': messageJson['date'],
    });
    print("added message from json");
  }

  Future<String> _fetchApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    print("fetched api url:");
    final apiUrl = await getApiUrl();
    return apiUrl ?? 'default-api-url';
  }

  bool _isImageUrl(String? message) {
    return message != null &&
        (message.startsWith(_apiUrl) &&
            (message.endsWith('.png') || message.endsWith('.jpg')));
  }

  Future<String> _getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiURL') ?? 'default-api-url';
  }

  void _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Unknown';
    });
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      String username = "YourUsername"; // Retrieve the actual username
      String time = DateTime.now().toIso8601String(); // Get current time

      widget.channel.sink.add(json.encode({
        'message': message,
        'username': _username,
        'room': widget.channelId.toString(),
        'time': time,
        'isImage': false,
      }));
      _textController.clear();
    }
  }

  void _uploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageUploadPage(
            imageFile: image,
            channelId: widget.channelId,
            sendImageCallback: _sendMessage,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  String _formatTime(String isoTime) {
    DateTime time = DateTime.parse(isoTime);
    return DateFormat('yyyy-MM-dd – kk:mm').format(time);
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
                  // Check if the message is an image
                  bool isImage = _isImageUrl(data['message']);
                  if (data['time'] != null) {
                    data['time'] = _formatTime(data['time']);
                  }
                  _messages.insert(0, {
                    'username': data['username'] ?? 'Unknown',
                    'message': data['message'],
                    'time': data['time'] ?? 'no time',
                    'isImage': isImage,
                  });
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    bool isImageMessage = _isImageUrl(message['message']);
                    bool isSentByMe = _messages[index]['username'] == _username;
                    return Align(
                      alignment: isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: isSentByMe
                              ? theme.colorScheme.secondaryContainer
                              : theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: isImageMessage
                            ? Image.network(message['message'])
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['username'],
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    message['message'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    message['time'],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
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
                    onSubmitted: (_) => _sendMessage(_textController.text),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_textController.text),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _uploadImage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
