// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String usercrsfToken = '';
String userSessionId = '';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'kfupm chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: const Color.fromRGBO(85, 138, 94, 1)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color.fromRGBO(
            85, 138, 94, 1), // RGB(85,138,94) for background
        textTheme: const TextTheme(
          // ignore: deprecated_member_use
          bodyText1: TextStyle(color: Colors.white), // White text color
          // ignore: deprecated_member_use
          bodyText2: TextStyle(color: Colors.white), // White text color
          // ignore: deprecated_member_use
          button: TextStyle(
              color: Color.fromRGBO(
                  85, 138, 94, 1)), // RGB(85,138,94) for button text
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  Future<void> getData(sessionToken, sessionID) async {
    print("csrftoken=$sessionToken; sessionid=$sessionID");
    const url =
        'https://cbb5-2001-16a2-c0ba-36fa-b5c9-38a8-9199-3734.ngrok-free.app/api/getid/';
    final response = await http.get(Uri.parse(url),
        headers: {"Cookie": "csrftoken=$sessionToken; sessionid=$sessionID"});

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final jsonData = jsonDecode(response.body);
      print('JSON Data: $jsonData');
      // Handle the JSON data as needed
    } else {
      // If the server returns an error response, throw an exception
      throw Exception('Failed to load data');
    }
  }

  Future<List<String?>> postData() async {
    const url =
        'https://cbb5-2001-16a2-c0ba-36fa-b5c9-38a8-9199-3734.ngrok-free.app/api/login/';
    final response = await http.post(Uri.parse(url), headers: {}, body: {
      'username': 'username',
      'password': 'kfupmchat',
    });
    final csrfToken =
        response.headers['set-cookie']?.split(';')[0].split('=')[1];
    final sessionId = response.headers['set-cookie']
        ?.split(';')[4]
        .split(',')[1]
        .split('=')[1];
    usercrsfToken = csrfToken!;
    userSessionId = sessionId!;
    print(response.headers);
    print('CSRF Token: $csrfToken');
    print('Session-id= $sessionId');
    return [csrfToken, sessionId];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/ar/archive/3/37/20180719130502%21King_Fahd_University_of_Petroleum_%26_Minerals_Logo.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                postData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White button color
                foregroundColor: const Color.fromRGBO(
                    85, 138, 94, 1), // RGB(85,138,94) for button text
              ),
              child: const Text('POST Data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('User CSRF Token: $usercrsfToken');
                print('User Session ID: $userSessionId');
                getData(usercrsfToken, userSessionId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White button color
                foregroundColor: const Color.fromRGBO(
                    85, 138, 94, 1), // RGB(85,138,94) for button text
              ),
              child: const Text('GET Data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White button color
                foregroundColor: const Color.fromRGBO(
                    85, 138, 94, 1), // RGB(85,138,94) for button text
              ),
              child: const Text('Register'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White button color
                foregroundColor: const Color.fromRGBO(
                    85, 138, 94, 1), // RGB(85,138,94) for button text
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _registerButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Registration Page',
                style: TextStyle(color: Colors.white)), // White text color
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                onChanged: (_) => _updateRegisterButton(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                obscureText: true,
                onChanged: (_) => _updateRegisterButton(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                obscureText: true,
                onChanged: (_) => _updateRegisterButton(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerButtonEnabled ? _register : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _registerButtonEnabled
                    ? Colors.white
                    : Colors.grey, // White button color
                foregroundColor: const Color.fromRGBO(
                    85, 138, 94, 1), // RGB(85,138,94) for button text
              ),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateRegisterButton() {
    setState(() {
      _registerButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _register() {
    // Perform registration logic here
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Registration successful!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sign In Page',
                style: TextStyle(color: Colors.white)), // White text color
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConversationsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White button color
                foregroundColor: const Color.fromRGBO(
                    85, 138, 94, 1), // RGB(85,138,94) for button text
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/user1.jpg'),
            ),
            title: const Text('User 1'),
            subtitle: const Text(''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DMPage()),
              );
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/user2.jpg'),
            ),
            title: const Text('User 2'),
            subtitle: const Text(''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DMPage()),
              );
            },
          ),
          // Add more ListTile widgets for other conversations
        ],
      ),
    );
  }
}

class DMPage extends StatefulWidget {
  @override
  _DMPageState createState() => _DMPageState();
}

class _DMPageState extends State<DMPage> {
  final TextEditingController _textEditingController = TextEditingController();
  final List<String> _messages = [];

  void _sendMessage() {
    setState(() {
      _messages.add(_textEditingController.text);
      _textEditingController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Message'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: _messages[index].startsWith('You: ')
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: _messages[index].startsWith('You: ')
                          ? Colors.blue
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      _messages[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
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
