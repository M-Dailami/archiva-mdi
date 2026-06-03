import 'package:flutter/material.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/features/auth/screens/register_screen.dart';
import 'package:archivafinal/services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _resetLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email dan password harus diisi');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      await SupabaseService.signIn(email: email, password: password);
      // Pop the login screen — _AuthGate will detect the session and show MainShell
      if (mounted) {
        Navigator.of(context).pop();
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
    if (error.contains('Invalid login credentials')) return 'Email atau password salah';
    if (error.contains('Email not confirmed')) return 'Email belum dikonfirmasi';
    if (error.contains('network')) return 'Tidak ada koneksi internet';
    return 'Login gagal. Silakan coba lagi.';
  }

  Future<void> _resetPassword() async {
    if (_resetLoading) return;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Masukkan email untuk reset password');
      return;
    }
    setState(() => _resetLoading = true);
    try {
      await SupabaseService.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link reset password telah dikirim ke $email'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Gagal mengirim email reset');
      }
    } finally {
      if (mounted) setState(() => _resetLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [AppColors.primaryDark, AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text('Archiva', style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
                  )),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarker.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text('Login', style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white,
                        )),
                        const SizedBox(height: 8),
                        const Text('Sebelum Memulai Perjalanan Anda\nSilahkan Masukan Akun',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
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
                        _buildField('Email', 'Masukan Email Anda', _emailController),
                        const SizedBox(height: 16),
                        _buildField('Password', 'Masukan Password Anda', _passwordController, obscure: true),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: _loading
                                ? const SizedBox(width: 22, height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Log in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Lupa Password? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      GestureDetector(
                        onTap: _resetLoading ? null : _resetPassword,
                        child: Text('Reset Password', style: TextStyle(
                          color: _resetLoading ? AppColors.textMuted : Colors.white,
                          fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum Punya Akun? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text('Sign Up', style: TextStyle(
                          color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true, fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder)),
          ),
        ),
      ],
    );
  }
}
