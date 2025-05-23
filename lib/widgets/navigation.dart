import 'package:final_app2/screens/add_screen.dart';
import 'package:final_app2/screens/search_screen.dart';
import 'package:final_app2/screens/home.dart';
import 'package:final_app2/screens/profile_screen.dart';
import 'package:final_app2/screens/reels_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavigationsScreen extends StatefulWidget {
  const NavigationsScreen({super.key});

  @override
  State<NavigationsScreen> createState() => _NavigationsScreenState();
}

int _currentIndex = 0;

class _NavigationsScreenState extends State<NavigationsScreen> {
  late PageController pageController;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: navigationTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.movie), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          const HomeScreen(),
          const SearchScreen(),
          const AddScreen(),
          const ReelsScreen(),
          ProfileScreen(uid: _auth.currentUser!.uid),
        ],
      ),
    );
  }
}
