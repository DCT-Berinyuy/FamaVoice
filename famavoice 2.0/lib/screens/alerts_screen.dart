
import 'package:flutter/material.dart';
import 'package:famavoice/models/alert_model.dart';
import 'package:famavoice/services/alert_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertService _alertService = AlertService();
  List<Alert> _alerts = [];
  List<String> _selectedCrops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
    });
    _alerts = await _alertService.getAlertsForUser(_selectedCrops);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/famavoice_logo.png',
              height: 30, // Adjust size as needed
            ),
            const SizedBox(width: 10),
            const Text('Crop Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showCropSelectionDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.agriculture, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
                      const SizedBox(height: 20),
                      Text(
                        'No alerts for your selected crops.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap the filter icon to select crops and get personalized alerts.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _alerts.length,
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
                    Color severityColor;
                    switch (alert.severity.toLowerCase()) {
                      case 'low':
                        severityColor = Colors.green;
                        break;
                      case 'medium':
                        severityColor = Colors.orange;
                        break;
                      case 'high':
                        severityColor = Colors.red;
                        break;
                      default:
                        severityColor = Colors.grey;
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: severityColor, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    alert.cropName['en'] ?? '',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: severityColor),
                                  ),
                                ),
                                Text(
                                  alert.severity.toUpperCase(),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: severityColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              alert.alertType['en'] ?? '',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(alert.description['en'] ?? ''),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                'Date: ${alert.timestamp.toLocal().toString().split(' ')[0]}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showCropSelectionDialog(BuildContext context) {
    final List<String> allCrops = ['Maize', 'Beans', 'Tomatoes', 'Cassava']; // Example crops
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Crops'),
          content: SingleChildScrollView(
            child: ListBody(
              children: allCrops.map((crop) {
                return CheckboxListTile(
                  title: Text(crop),
                  value: _selectedCrops.contains(crop),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedCrops.add(crop);
                      } else {
                        _selectedCrops.remove(crop);
                      }
                    });
                    _loadAlerts(); // Reload alerts when selection changes
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
