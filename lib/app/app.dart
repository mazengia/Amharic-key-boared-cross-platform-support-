import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/keyboard_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';
import '../widgets/sidebar.dart';
import 'theme.dart';

class AmharicKeyboardApp extends StatelessWidget {
  const AmharicKeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amharic Keyboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final pages = const [
    HomeScreen(),
    KeyboardScreen(),
    SettingsScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          const VerticalDivider(width: 1),

          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }
}