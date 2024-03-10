class Group {
  final int id;
  final String name;
  final String description;

  Group({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['group_id'],
      name: json['group_name'],
      description: json['group_description'],
    );
  }
}
