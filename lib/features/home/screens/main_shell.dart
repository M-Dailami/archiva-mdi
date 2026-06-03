import 'package:flutter/material.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/features/home/screens/home_screen.dart';
import 'package:archivafinal/features/explore/screens/explore_screen.dart';
import 'package:archivafinal/features/quiz/screens/quiz_list_screen.dart';
import 'package:archivafinal/features/profile/screens/profile_screen.dart';
import 'package:archivafinal/features/chatbot/screens/chatbot_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  List<Widget> get _screens => [
    HomeScreen(onNavigateToKategori: () => setState(() => _index = 1)),
    const KategoriTempatScreen(),
    const QuizListScreen(),
    const ProfileScreen(),
  ];

  static const _navItems = <_NavItemData>[
    _NavItemData(Icons.home_rounded, 'Beranda'),
    _NavItemData(Icons.category_rounded, 'Kategori'),
    _NavItemData(Icons.quiz_rounded, 'Kuis'),
    _NavItemData(Icons.account_circle_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      // Tombol mengambang untuk membuka Chatbot
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
        backgroundColor: AppColors.accent,
        elevation: 6,
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 26),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryDarker,
          border: Border(top: BorderSide(color: AppColors.surfaceDark, width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navItems.length,
                (i) => _navItem(_navItems[i], i),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(_NavItemData data, int index) {
    final active = _index == index;
    return GestureDetector(
      onTap: () => setState(() => _index = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.icon, size: 24,
                color: active ? AppColors.navActive : AppColors.navInactive),
            const SizedBox(height: 3),
            Text(data.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: active ? AppColors.navActive : AppColors.navInactive,
                )),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData(this.icon, this.label);
}
