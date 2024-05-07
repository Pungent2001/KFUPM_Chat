// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kfupm_chat/group_page.dart';
import 'color_schemes.g.dart';

void setSession(userToken, userID) async {
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

Future<bool?> setApiUrl() async {
  SharedPreferences.getInstance().then((prefs) {
    // Global Initiator for the API URL, has to be run on launch, and updated if the backend devs change the URL
    prefs.setString('apiURL', 'endless-pet-kangaroo.ngrok-free.app');
    print("###########api url set..");
    return true;
  });
}

getApiUrl() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? apiURL = prefs.getString('apiURL');
  // print("#######API URL: $apiURL");
  return apiURL;
}

Future<void> main() async {
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
            // vvvvvvvvvvvv LOGIN BUTTON vvvvvvvvvvvvvv
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
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface),
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
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface),
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
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface),
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

  void _register() async {
    final apiUrl = await getApiUrl();
    final url = 'https://$apiUrl/api/signup/';

    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": _emailController.text,
        "password1": _passwordController.text,
        "password2": _confirmPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Assuming the server returns a successful response
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor:
              lightColorScheme.background, // Use your theme's background color
          title: Text(
            'Registration Successful',
            style: TextStyle(color: lightColorScheme.onBackground),
          ),
          content: Text(
            'You have registered successfully!',
            style: TextStyle(color: lightColorScheme.onBackground),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                SignInPage()
                    .logIn(_emailController.text, _passwordController.text);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CourseSelectionPage()),
                );
              },
              child: Text(
                'OK',
                style: TextStyle(color: lightColorScheme.primary),
              ),
            ),
          ],
        ),
      );
    } else {
      // Handle error or failed registration
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: lightColorScheme
              .errorContainer, // Use errorContainer for background
          title: Text(
            'Registration Failed',
            style: TextStyle(
                color: lightColorScheme.error), // Use onError for text
          ),
          content: Text(
            'Failed to register. Please try again.',
            style: TextStyle(
                color: lightColorScheme.error), // Use onError for text
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                    color: lightColorScheme
                        .onErrorContainer), // Use onErrorContainer for button text
              ),
            ),
          ],
        ),
      );
    }
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);
  Future<List<String?>> logIn(username, password) async {
    print("username: $username");
    print("password: $password");
    setApiUrl();
    print(getApiUrl() ?? "url not found");
    final String apiLink = await getApiUrl() ?? '';
    final url = 'https://$apiLink/api/login/';
    final response = await http.post(Uri.parse(url), headers: {}, body: {
      'username': username,
      'password': password,
    });
    // print(response.body);
    final csrfToken =
        response.headers['set-cookie']?.split(';')[0].split('=')[1];
    final sessionId = response.headers['set-cookie']
        ?.split(';')[4]
        .split(',')[1]
        .split('=')[1];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username); // Save the username
    setSession(csrfToken, sessionId);

    print(response.headers);
    print('#######CSRF Token: $csrfToken');
    print('#######Session-id= $sessionId');
    return [csrfToken, sessionId];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

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
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String username = _usernameController.text;
                final String password = _passwordController.text;
                print('Username: $username');
                print('Password: $password');
                // Call the logIn function with the username and password
                setSession("", "");
                await logIn(username, password);
                // Navigate to the next screen after login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroupPage()),
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

class CourseSelectionPage extends StatefulWidget {
  @override
  _CourseSelectionPageState createState() => _CourseSelectionPageState();
}

class _CourseSelectionPageState extends State<CourseSelectionPage> {
  late Future<List<dynamic>> _coursesFuture;
  Map<int, bool> _enrollments = {};

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses(); // Assign the Future here
  }

  Future<List<dynamic>> _fetchCourses() async {
    final apiUrl = await getApiUrl();
    final url = 'https://$apiUrl/api/getcourses';
    var session = await getSession();
    String sessionToken = session[0];
    String sessionID = session[1];
    http.Response response = await http.get(
      Uri.parse(url),
      headers: {"Cookie": 'csrftoken=$sessionToken; sessionid=$sessionID'},
    );

    if (response.statusCode == 200) {
      List<dynamic> courses = jsonDecode(response.body);
      for (var course in courses) {
        _enrollments[course['group_id']] =
            false; // Preset all to unenrolled initially
      }
      return courses; // Return the fetched courses.
    } else {
      // Handle error or no courses found scenario
      print('Failed to fetch courses');
      throw Exception('Failed to fetch courses');
    }
  }

  Future<void> _enroll() async {
    final apiUrl = await getApiUrl();
    final url = 'https://$apiUrl/api/enroll/';

    // Convert selected group IDs to a list of strings
    List<String> enrolledGroups = _enrollments.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key.toString())
        .toList();
    print("#####Enrolled Groups: $enrolledGroups");
    var session = await getSession();
    String sessionToken = session[0];
    String sessionID = session[1];
    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        "Cookie": 'csrftoken=$sessionToken; sessionid=$sessionID',
        "Content-Type": "application/json",
        "X-CSRFToken": sessionToken
      },
      body: jsonEncode({
        "enrolled_groups": enrolledGroups,
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful enrollment
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Enrollment Successful'),
          content: Text('You have been enrolled successfully.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Dismiss alert dialog
              },
            ),
          ],
        ),
      );
    } else {
      // Handle errors
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Enrollment Failed'),
          content: Text('Failed to enroll in courses. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss alert dialog
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Courses'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final courses = snapshot.data!;
            return ListView(
              children: courses.map((course) {
                return CheckboxListTile(
                  title: Text(course['group_name']),
                  subtitle: Text(course['group_description']),
                  value: _enrollments[course['group_id']],
                  onChanged: (bool? value) {
                    setState(() {
                      _enrollments[course['group_id']] = value!;
                    });
                  },
                );
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _enroll,
        tooltip: 'Enroll',
        child: Icon(Icons.save),
      ),
    );
  }
}
