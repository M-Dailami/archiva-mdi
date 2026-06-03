import 'package:flutter/material.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/features/auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Menelusuri Jejak\nMenemukan Cerita',
      description: 'Setiap sudut kota bukan sekadar titik di peta, melainkan saksi bisu peristiwa besar. Temukan destinasi bersejarah terdekat yang menunggu untuk Anda singkap.',
      icon: Icons.explore,
      imagePath: 'assets/images/onboarding_1.jpg',
    ),
    _OnboardingData(
      title: 'Selami Literasi\ndi Balik Destinasi.',
      description: 'Perkaya perjalanan Anda. Akses arsip literatur, artikel mendalam, dan fakta menarik untuk memahami jiwa serta nilai sejarah dari setiap tempat yang Anda pijak.',
      icon: Icons.auto_stories,
      imagePath: 'assets/images/onboarding_2.jpg',
    ),
    _OnboardingData(
      title: 'Pustaka\ndi Setiap Langkahmu.',
      description: 'Bergabunglah sekarang. Rencanakan rute penjelajahanmu, simpan tempat favoritmu, dan jadilah bagian dari mereka yang merawat ingatan masa lalu.',
      icon: Icons.bookmark_border,
      imagePath: 'assets/images/onboarding_3.jpg',
    ),
  ];

  void _next() {
    if (_currentPage < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Halaman gambar layar penuh — tanpa bar atas terpisah
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              itemCount: 3,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => Image.asset(
                _pages[i].imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceDark,
                  child: Center(child: Icon(_pages[i].icon, size: 120,
                    color: AppColors.textSecondary.withValues(alpha: 0.5))),
                ),
              ),
            ),
          ),
          // Teks "Archiva" melayang di atas gambar, bagian atas layar
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Archiva', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black45)])),
                    SizedBox(height: 4),
                    Text('Panduan literasi untuk\nsetiap sudut bersejarah',
                      style: TextStyle(fontSize: 14, color: Colors.white70,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black54)])),
                  ],
                ),
              ),
            ),
          ),
          // Konten bawah — titik halaman + kartu melengkung
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titik indikator halaman
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == i ? 28 : 10, height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(5)),
                  )),
                ),
                const SizedBox(height: 16),
                // Kartu persegi panjang melengkung
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarker.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_pages[_currentPage].title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                    const SizedBox(height: 12),
                    Text(_pages[_currentPage].description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.justify),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: Text(_currentPage == 2 ? 'Mulai Sekarang' : 'Selanjutnya',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: _currentPage == 0 ? _goToLogin : () => _controller.previousPage(
                          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                        child: Text(_currentPage == 0 ? 'Lewati' : 'Sebelumnya',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title, description, imagePath;
  final IconData icon;
  const _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.imagePath,
  });
}
