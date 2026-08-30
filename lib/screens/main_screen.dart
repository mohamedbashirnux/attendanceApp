import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../pages/home_page.dart';
import '../pages/graduation_page.dart';
import '../pages/ai_chatbot_page.dart';
import '../pages/about_page.dart';
import '../widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const GraduationPage(),
    const AIChatbotPage(),
    const AboutPage(),
  ];

  final List<String> _pageTitles = [
    'Capital University',
    'Graduation',
    'AI Chatbot',
    'About Us',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        centerTitle: true,
        elevation: 2,
      ),
      drawer: AppDrawer(
        onHomePressed: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF5F61E6),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.teacher),
              label: 'Graduation',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.message),
              label: 'AI Chatbot',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.info_circle),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}
