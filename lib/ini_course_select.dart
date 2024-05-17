import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kfupm_chat/group_page.dart';
import 'package:kfupm_chat/main.dart';

class InitialCourseSelectionPage extends StatefulWidget {
  @override
  _CourseSelectionPageState createState() => _CourseSelectionPageState();
}

class _CourseSelectionPageState extends State<InitialCourseSelectionPage> {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroupPage()),
                ); // Dismiss alert dialog
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
