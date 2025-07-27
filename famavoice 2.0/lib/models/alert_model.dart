
class Alert {
  final String id;
  final Map<String, String> cropName;
  final Map<String, String> alertType;
  final Map<String, String> description;
  final DateTime timestamp;
  final String severity;

  Alert({
    required this.id,
    required this.cropName,
    required this.alertType,
    required this.description,
    required this.timestamp,
    required this.severity,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      cropName: Map<String, String>.from(json['cropName']),
      alertType: Map<String, String>.from(json['alertType']),
      description: Map<String, String>.from(json['description']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: json['severity'] as String,
    );
  }
}
