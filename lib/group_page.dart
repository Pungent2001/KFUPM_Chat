import 'package:flutter/material.dart';
import 'group_model.dart';
import 'group_service.dart';
import 'channel_page.dart'; // You will create this

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = GroupService.fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
      ),
      body: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final groups = snapshot.data!;
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  title: Text(group.name),
                  subtitle: Text(group.id.toString()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChannelPage(group: group),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
