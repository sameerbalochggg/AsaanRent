// Create this file: lib/presentation/navigation/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:rent_application/presentation/home/screens/home_screen.dart';
import 'package:rent_application/presentation/home/screens/search_screen.dart';
import 'package:rent_application/presentation/home/screens/favourite_tab_screen.dart';
import 'package:rent_application/presentation/profile/screens/profile_screen.dart';
import 'package:rent_application/presentation/widgets/custom_bottom_nav_bar.dart';

/// MainNavigation is the main container for the app's bottom navigation
/// It uses PageView to smoothly switch between screens without recreating them
/// This prevents white flashing and preserves state when switching tabs
class MainNavigation extends StatefulWidget {
  /// Initial tab index (0=Home, 1=Search, 2=Favourites, 3=Profile)
  final int initialIndex;

  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handles bottom navigation tap
  /// Animates to the selected page smoothly
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Already on this tab
    
    setState(() {
      _selectedIndex = index;
    });
    
    // Smooth animation to the selected page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // Disable swipe gesture (only bottom nav can switch tabs)
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          HomePage(),           // Index 0
          SearchPage(),         // Index 1
          FavoritesTabScreen(), // Index 2
          ProfileScreen(),      // Index 3
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}