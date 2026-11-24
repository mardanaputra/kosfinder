import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const AuthScreen({super.key, this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  // Register controllers
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _loginEmailController.text.trim(),
      _loginPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil masuk!'),
          backgroundColor: Colors.green,
        ),
      );
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Email atau password salah'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _registerEmailController.text.trim(),
      _registerPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Akun pemilik aktif.'),
          backgroundColor: Colors.green,
        ),
      );
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Pendaftaran gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Pemilik Kos'),
        bottom: auth.isAuthenticated
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Masuk'),
                  Tab(text: 'Daftar'),
                ],
              ),
      ),
      body: auth.isAuthenticated
          ? _buildLoggedInView(auth)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLoginForm(auth),
                _buildRegisterForm(auth),
              ],
            ),
    );
  }

  Widget _buildLoggedInView(AuthProvider auth) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 72, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Anda Sedang Masuk',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              auth.currentUser?.email ?? '',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
              ),
              onPressed: () async {
                await auth.logout();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berhasil keluar.')),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Keluar dari Akun'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('login_email_field'),
              controller: _loginEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                if (!v.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('login_password_field'),
              controller: _loginPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('login_button'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: auth.isLoading ? null : _handleLogin,
              child: auth.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Masuk',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('register_email_field'),
              controller: _registerEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Pemilik',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                if (!v.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('register_password_field'),
              controller: _registerPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password (min. 6 karakter)',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('register_button'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: auth.isLoading ? null : _handleRegister,
              child: auth.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Daftar Akun Pemilik',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
