import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archivafinal/core/theme/app_theme.dart';
import 'package:archivafinal/services/app_state.dart';
import 'package:archivafinal/features/onboarding/screens/onboarding_screen.dart';
import 'package:archivafinal/features/home/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://rxqebuyajyzpmucalezr.supabase.co',
    anonKey: 'sb_publishable_FfgM25ysmbMPSEAz-6ym7A_c5glS2p1',
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ArchivaApp());
}

class ArchivaApp extends StatelessWidget {
  const ArchivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: 'Archiva',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: _AuthGate(),
      ),
    );
  }
}

/// Memantau status autentikasi Supabase dan mengarahkan ke halaman yang sesuai:
/// - Jika sudah login → MainShell (beranda)
/// - Jika belum login → OnboardingScreen
class _AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Periksa apakah user saat ini sudah login
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          // User sudah login, inisialisasi ulang AppState dengan user yang terautentikasi
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AppState>().init();
          });
          return const MainShell();
        }
        // Belum login, tampilkan onboarding
        return const OnboardingScreen();
      },
    );
  }
}
