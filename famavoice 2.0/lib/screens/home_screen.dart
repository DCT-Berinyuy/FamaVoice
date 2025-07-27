
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onCardTap;
  const HomeScreen({super.key, required this.onCardTap});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning, Farmer!';
    }
    if (hour < 17) {
      return 'Good Afternoon, Farmer!';
    }
    return 'Good Evening, Farmer!';
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
            const Text('FamaVoice', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: false, // Align title to the left
        elevation: 0, // Remove shadow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Section for "Ask FamaVoice"
            Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center( // Added Center widget here
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mic, size: 48.0, color: Theme.of(context).primaryColor),
                            SizedBox(height: 8.0),
                            Text(
                              'Ask FamaVoice',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              'Get instant agricultural advice',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Text(
              'Other Features',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true, // Important for GridView inside Column
              physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  icon: Icons.notifications_active,
                  label: 'Crop Alerts',
                  onTap: () {
                    onCardTap(2); // Index for AlertsScreen
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.mic,
                  label: 'Voice Memos',
                  onTap: () {
                    onCardTap(3); // Index for MemosScreen
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.price_change,
                  label: 'Market Prices',
                  onTap: () {
                    onCardTap(4); // Index for MarketPricesScreen
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.info_outline,
                  label: 'About Developers',
                  onTap: () {
                    onCardTap(5); // Index for AboutDevelopersScreen
                  },
                ),
                // Add a placeholder or another feature if needed to fill the grid
                
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
