import 'package:flutter/material.dart';
import 'package:famavoice/utils/constants.dart';
import 'package:famavoice/screens/home_screen.dart';
import 'package:famavoice/screens/splash_screen.dart';
import 'package:famavoice/screens/chat_screen.dart';
import 'package:famavoice/screens/alerts_screen.dart';
import 'package:famavoice/screens/memos_screen.dart';
import 'package:famavoice/screens/market_prices_screen.dart';
import 'package:famavoice/screens/about_developers_screen.dart';

import 'package:famavoice/widgets/custom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:famavoice/services/connectivity_service.dart';
import 'package:famavoice/services/theme_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ConnectivityService()),
        ChangeNotifierProvider(create: (context) => ThemeService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'FamaVoice',
            theme: kThemeData,
            darkTheme: kDarkThemeData, // Assuming you have a kDarkThemeData defined in constants.dart
            themeMode: themeService.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onCardTap: (index) { _onTabTapped(index); }),
      const ChatScreen(),
      const AlertsScreen(),
      const MemosScreen(),
      const MarketPricesScreen(), // Index 4
      const AboutDevelopersScreen(), // Index 5
      
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}