import 'package:flutter/material.dart';

class AboutDevelopersScreen extends StatelessWidget {
  const AboutDevelopersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Developers'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/famavoice_logo.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            Text(
              'Team DCT Frontier',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Team DCT Frontier is a passionate trio of young innovators from Cameroon, united by purpose and friendship. We specialize in building tech solutions that empower rural communities through voice-first, AI-powered applications.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildDeveloperInfo(
              context,
              name: 'Mr.DCT (Verla Berinyuy)',
              role: 'Lead Developer & Project Architect',
            ),
            const SizedBox(height: 15),
            _buildDeveloperInfo(
              context,
              name: 'Marcelo (Mbunda Marcel)',
              role: 'Pitch Specialist & Public Relations Lead',
            ),
            const SizedBox(height: 15),
            _buildDeveloperInfo(
              context,
              name: 'Mr.Wise (Tsafack Bidja)',
              role: 'Researcher, Strategist & Creative Thinker',
            ),
            const SizedBox(height: 30),
            Text(
              'Together, we are committed to using open-source tools and grassroots innovation to drive meaningful impact across Africa.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperInfo(BuildContext context, {required String name, required String role}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              role,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
