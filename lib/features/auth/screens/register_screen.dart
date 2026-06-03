import 'package:flutter/material.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/features/auth/screens/login_screen.dart';
import 'package:archivafinal/services/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Semua field harus diisi');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      await SupabaseService.signUp(email: email, password: password, name: name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat! Silakan login.'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = _parseAuthError(e.toString());
        });
      }
    }
  }

  String _parseAuthError(String error) {
    if (error.contains('already registered')) return 'Email sudah terdaftar';
    if (error.contains('valid email')) return 'Format email tidak valid';
    if (error.contains('network')) return 'Tidak ada koneksi internet';
    return 'Registrasi gagal. Silakan coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [AppColors.primaryDark, AppColors.background]),
          )),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                const SizedBox(height: 40),
                const Text('Archiva', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarker.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(children: [
                    const Text('Buat Akun', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('Sebelum Memulai Perjalanan Anda\nSilahkan Membuat Akun',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
                        ),
                        child: Text(_error!, style: const TextStyle(color: AppColors.accentRed, fontSize: 13),
                          textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _field('Username', 'Masukan Username Anda', _nameController),
                    const SizedBox(height: 16),
                    _field('Email', 'Masukan Email Anda', _emailController),
                    const SizedBox(height: 16),
                    _field('Password', 'Masukan Password Anda', _passwordController, obscure: true),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: _loading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Buat Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      )),
                  ]),
                ),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Sudah Punya Akun? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text('Log in', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController controller, {bool obscure = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: obscure, style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          filled: true, fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.inputBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.inputBorder)),
        )),
    ]);
  }
}
