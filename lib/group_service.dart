import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kfupm_chat/channel_model.dart';
import 'package:kfupm_chat/main.dart';
import 'group_model.dart';
// import 'package:kfupm_chat/main.dart';

class GroupService {
  static Future<List<Group>> fetchGroups() async {
    String apiLink = await getApiUrl() ?? '';
    final url = '$apiLink/api/getgroups/';
    var session = await getSession();
    String sessionToken = session[0];
    String sessionID = session[1];
    // print("#######getting groups...");
    // print("#######csrftoken=$sessionToken; sessionid=$sessionID");
    final response = await http.get(Uri.parse(url),
        headers: {"Cookie": 'csrftoken=$sessionToken; sessionid=$sessionID'});

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

  static Future<List<Channel>> fetchTextChannels(int groupId) async {
    String apiLink = await getApiUrl() ?? '';
    final url = '$apiLink/api/gettextchannels?group_id=$groupId';
    var session = await getSession();
    String sessionToken = session[0];
    String sessionID = session[1];

    // final response = await http.get(Uri.parse(url),
    //     headers: {"Cookie": 'csrftoken=$sessionToken; sessionid=$sessionID'}
    //     ,body: {"selected_group_id": 1});
    final response = await http.get(Uri.parse(url), headers: {
      "Cookie": 'csrftoken=$sessionToken; sessionid=$sessionID',
      "selected-group-id": "1"
    });
    print("#######getting channels...");
    if (response.statusCode == 200) {
      final List<dynamic> dataList = json.decode(response.body);

      return dataList.map((json) => Channel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load text channels');
    }
  }
}
