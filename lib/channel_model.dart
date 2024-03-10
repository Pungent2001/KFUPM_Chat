class Channel {
  final int channelId;
  final String channelName;
  final int groupId;

  Channel({
    required this.channelId,
    required this.channelName,
    required this.groupId,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      channelId: json['channel_id'],
      channelName: json['channel_name'],
      groupId: json['group_id'],
    );
  }
}
