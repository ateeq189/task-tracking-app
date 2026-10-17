import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth_errors.dart';
import '../../utils/helpers.dart';
import '../../widgets/common.dart';

/// Login + Sign up in one screen (gradient background, white card).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Taken before the await: after login this screen is replaced.
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);

    try {
      final auth = AuthService();
      if (_isLogin) {
        await auth.login(_email.text.trim(), _password.text.trim());
      } else {
        await auth.signUp(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      }
      // AuthWrapper switches to the right home screen by itself.
    } catch (e) {
      showToastOn(messenger, authErrorMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final messenger = ScaffoldMessenger.of(context);
    final email = _email.text.trim();
    if (!email.contains('@')) {
      showToastOn(
        messenger,
        'Please enter your email above first',
        error: true,
      );
      return;
    }
    try {
      await AuthService().resetPassword(email);
      showToastOn(messenger, 'Password reset link sent to your email');
    } catch (e) {
      showToastOn(messenger, authErrorMessage(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.blue700],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - t)),
                    child: child,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 384),
                  child: _buildCard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Intern Task Management System',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            PillToggle<bool>(
              selected: _isLogin,
              onChanged: (v) => setState(() => _isLogin = v),
              options: const [
                PillOption(true, 'Login', Icons.login),
                PillOption(false, 'Sign Up', Icons.person_add_alt_1_outlined),
              ],
            ),
            const SizedBox(height: 24),
            if (!_isLogin) ...[
              LabeledField(
                label: 'Full Name',
                child: TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your name'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
            ],
            LabeledField(
              label: 'Email',
              child: TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'you@example.com'),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Enter a valid email'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Password',
              child: TextFormField(
                controller: _password,
                obscureText: _hidePassword,
                onFieldSubmitted: (_) => _loading ? null : _submit(),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textSoft,
                    ),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
              ),
            ),
            if (_isLogin)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text('Forgot password?'),
                ),
              )
            else
              const SizedBox(height: 8),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_isLogin ? 'Login' : 'Create Account'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 24),
              const Text(
                'New accounts are created as interns.\nAdmin access is given by the system administrator.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
