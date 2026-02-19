class PolicyModel {
  final String type;
  final String title;
  final String content;
  final String version;
  final String lastUpdated;

  PolicyModel({
    required this.type,
    required this.title,
    required this.content,
    required this.version,
    required this.lastUpdated,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      version: json['version'] ?? '1.0',
      lastUpdated: json['lastUpdated'] ?? json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'version': version,
      'lastUpdated': lastUpdated,
    };
  }
}
