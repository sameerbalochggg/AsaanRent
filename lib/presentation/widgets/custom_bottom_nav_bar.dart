import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF004D40), 
      unselectedItemColor: Colors.grey,

      items: [
        BottomNavigationBarItem(
          icon: currentIndex == 0
              ? const Icon(Icons.home)           // FILLED
              : const Icon(Icons.home_outlined), // OUTLINE
          label: "Home",
        ),

        BottomNavigationBarItem(
          icon: currentIndex == 1
              ? const Icon(Icons.search)         // FILLED
              : const Icon(Icons.search_outlined), // OUTLINE
          label: "Search",
        ),

        BottomNavigationBarItem(
          icon: currentIndex == 2
              ? const Icon(Icons.favorite)       // FILLED
              : const Icon(Icons.favorite_border), // OUTLINE
          label: "Favorite",
        ),

        BottomNavigationBarItem(
          icon: currentIndex == 3
              ? const Icon(Icons.person)         // FILLED
              : const Icon(Icons.person_outline), // OUTLINE
          label: "Profile",
        ),
      ],
    );
  }
}
