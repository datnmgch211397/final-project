import 'package:final_app2/screens/add_screen.dart';
import 'package:final_app2/screens/explore_screen.dart';
import 'package:final_app2/screens/home.dart';
import 'package:final_app2/screens/profile_screen.dart';
import 'package:final_app2/screens/reels_screen.dart';
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
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.camera), label: ''),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/reels-icon.png',
                height: 20.h,
              ),
              label: '',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: const [
          HomeScreen(),
          ExploreScreen(),
          AddScreen(),
          ReelsScreen(),
          ProfileScreen(),
        ],
      ),
    );
  }
}
