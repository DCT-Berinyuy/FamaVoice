import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:famavoice/models/alert_model.dart';

class AlertService {
  Future<List<Alert>> loadAlerts() async {
    final String response = await rootBundle.loadString('assets/data/alerts.json');
    final data = await json.decode(response);
    return (data['alerts'] as List)
        .map((alertJson) => Alert.fromJson(alertJson))
        .toList();
  }

  // This method will be expanded to filter by user-selected crops
  Future<List<Alert>> getAlertsForUser(List<String> userCrops) async {
    final allAlerts = await loadAlerts();
    if (userCrops.isEmpty) {
      return allAlerts; // Return all if no specific crops are selected
    }
    return allAlerts.where((alert) {
      // Check if the alert's crop name (in any language) is in the user's selected crops
      return userCrops.any((userCrop) =>
          alert.cropName['en']?.toLowerCase() == userCrop.toLowerCase() ||
          alert.cropName['fr']?.toLowerCase() == userCrop.toLowerCase() ||
          alert.cropName['pidgin']?.toLowerCase() == userCrop.toLowerCase());
    }).toList();
  }
}