// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kfupm_chat/group_page.dart';
import 'color_schemes.g.dart';

setSession(userToken, userID) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (userToken != null) {
    prefs.setString('usercrsfToken', userToken);
  }
  if (userID != null) {
    prefs.setString('userSessionId', userID);
  }
}

getSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? usercrsfToken = prefs.getString('usercrsfToken');
  String? userSessionId = prefs.getString('userSessionId');
  return [usercrsfToken, userSessionId];
}

setApiUrl() {
  SharedPreferences.getInstance().then((prefs) {
    //Global Initiator for the API URL, has to be run on launch, and updated if the backend devs change the URL
    prefs.setString('apiURL',
        'https://fdac-2001-16a2-c0ba-36fa-f007-95c0-c17d-8a81.ngrok-free.app');
  });
}

getApiUrl() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? apiURL = prefs.getString('apiURL');
  // print("#######API URL: $apiURL");
  return apiURL;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              height: 300,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 20),

            /// vvvvvvvvvvv REGISTRATION BUTTON vvvvvvvvvvv

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegistrationPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _registerButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Registration Page',
              style: TextStyle(
                  color: theme.colorScheme.onSurface), // Text color from theme
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                      color: theme.colorScheme
                          .onSurface), // Text field label color from theme
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
                  labelStyle: TextStyle(
                      color: theme.colorScheme
                          .onSurface), // Text field label color from theme
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
                  labelStyle: TextStyle(
                      color: theme.colorScheme
                          .onSurface), // Text field label color from theme
                ),
                obscureText: true,
                onChanged: (_) => _updateRegisterButton(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerButtonEnabled ? _register : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
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
    // Registration logic would be implemented here
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Success',
          style: TextStyle(
              color:
                  theme.colorScheme.onSurface), // Dialog text color from theme
        ),
        content: Text(
          'Registration successful!',
          style: TextStyle(
              color:
                  theme.colorScheme.onSurface), // Dialog text color from theme
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Return to the previous screen
            },
            child: Text(
              'OK',
              style: TextStyle(
                  color: theme
                      .colorScheme.primary), // Button text color from theme
            ),
          ),
        ],
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign In Page',
              style: TextStyle(
                  color: theme.colorScheme.onSurface), // Text color from theme
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                      color: theme
                          .colorScheme.onSurface), // Label color from theme
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                      color: theme
                          .colorScheme.onSurface), // Label color from theme
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

// Since ConversationsPage, DMPage, and any other pages or widgets were not provided in the request,
// make sure to apply similar changes: using theme.colorScheme for colors and not using any hardcoded values.
