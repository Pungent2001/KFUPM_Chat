import 'dart:convert';
import 'package:http/http.dart' as http;
import 'group_model.dart';
import 'package:kfupm_chat/main.dart ';

class GroupService {
  static Future<List<Group>> fetchGroups() async {
    const url = '$apiURL/api/getgroups';
    String sessionToken = usercrsfToken;
    String sessionID = userSessionId;
    print("csrftoken=$sessionToken; sessionid=$sessionID");
    final response = await http.get(Uri.parse(url),
        // headers: {"Cookie": 'csrftoken=$sessionToken; sessionid=$sessionID'});
        headers: {
          "Cookie":
              'csrftoken=2q5wVdYJADK4e0ty13r1HgOQv6YoyTDh; sessionid=n2ojsyl8f1njfe5jbwgnp9ee7tmanqve'
        });

    if (response.statusCode == 200) {
      final List<dynamic> dataList = json.decode(response.body);
      print(dataList);
      // Convert the JSON string to a list of maps
      final List<Map<String, dynamic>> data =
          dataList.map<Map<String, dynamic>>((json) {
        return Map<String, dynamic>.from(json);
      }).toList();

      // Map each map to a Group object
      return data.map((json) => Group.fromJson(json)).toList();
    } else {
      print(
          'Failed to load groups. Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load groups');
    }
  }
}
