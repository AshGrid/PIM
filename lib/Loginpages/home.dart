import 'package:flutter/material.dart';
import 'package:eduprime/pages/featuerd_screen.dart';
import 'package:eduprime/pages/QuizPage.dart';
import 'package:eduprime/pages/profile_page.dart';
import 'package:eduprime/pages/market_page.dart';
import 'package:eduprime/pages/Porfilio_page.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    FeaturedScreen(),  // Écran vedette
    QuizHomeScreen(),  // Écran du quiz
    Market(),          // Écran du marché
    Porfilio(),         // Écran du profil
      Profile  (),  // Portfolio Screen - Assuming you have this widget

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        // Update the items list to include the Portfolio icon and label
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: "Courses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Market",
          ),
            // Add a new item for Portfolio
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: "Portfolio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          // Add a new item for Portfolio
          
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}