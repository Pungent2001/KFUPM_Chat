// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'group_model.dart';
import 'channel_model.dart';
import 'group_service.dart';
import 'chat_page.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChannelPage extends StatefulWidget {
  final Group group;

  const ChannelPage({super.key, required this.group});

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  late Future<List<Channel>> _channelsFuture;

  @override
  void initState() {
    super.initState();
    _channelsFuture = GroupService.fetchTextChannels(widget.group.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Channels for ${widget.group.name}'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: FutureBuilder<List<Channel>>(
        future: _channelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final channels = snapshot.data!;
            return ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return ListTile(
                  title: Text(channel.channelName),
                  subtitle: Text(channel.channelId.toString()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          title: channel.channelName,
                          channel: WebSocketChannel.connect(
                            Uri.parse(
                                'wss://fdac-2001-16a2-c0ba-36fa-f007-95c0-c17d-8a81.ngrok-free.app/ws/TextChannels/${widget.group.id}/${channel.channelId}/'),
                          ),
                        ),
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
