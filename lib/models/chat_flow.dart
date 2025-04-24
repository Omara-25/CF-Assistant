class ChatFlow {
  final String id;
  final String name;
  final String flowId;
  final String apiUrl;
  final String apiKey;

  ChatFlow({
    required this.id,
    required this.name,
    required this.flowId,
    required this.apiUrl,
    required this.apiKey,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'flowId': flowId,
    'apiUrl': apiUrl,
    'apiKey': apiKey,
  };

  factory ChatFlow.fromJson(Map<String, dynamic> json) => ChatFlow(
    id: json['id'],
    name: json['name'],
    flowId: json['flowId'],
    apiUrl: json['apiUrl'],
    apiKey: json['apiKey'],
  );
}

