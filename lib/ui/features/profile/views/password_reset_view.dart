import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/services/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';

/// Step 1: request a reset email. Step 2: enter the token from the email
/// (or arrive here with it from a `/reset-password?token=` link).
class PasswordResetView extends ConsumerStatefulWidget {
  const PasswordResetView({super.key, this.token});

  final String? token;

  @override
  ConsumerState<PasswordResetView> createState() => _PasswordResetViewState();
}

class _PasswordResetViewState extends ConsumerState<PasswordResetView> {
  final _email = TextEditingController();
  late final _token = TextEditingController(text: widget.token ?? '');
  final _password = TextEditingController();
  late bool _haveToken = widget.token != null;
  bool _sent = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _request() async {
    final email = _email.text.trim();
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid email.')));
      return;
    }
    await _run(() async {
      await ref.read(authRepositoryProvider).requestPasswordReset(email);
      setState(() => _sent = true);
    });
  }

  Future<void> _confirm() => _run(() async {
        if (_password.text.length < 8) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password needs at least 8 characters.')));
          return;
        }
        await ref.read(authRepositoryProvider).confirmPasswordReset(
              token: _token.text.trim(),
              newPassword: _password.text,
            );
        // The reset signs out every device.
        await ref.read(authControllerProvider.notifier).logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated. Sign in with your new password.')));
        context.go('/home');
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          if (!_haveToken) ...[
            Text(
              _sent ? 'Check your inbox' : 'Forgot your password?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _sent
                  ? 'If that email has an account, we sent a reset link. It works once and expires in 30 minutes.'
                  : "Enter your account email and we'll send you a reset link.",
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            if (!_sent) ...[
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              PillButton(label: 'Send Reset Link', filled: true, loading: _busy, onPressed: _request),
            ],
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _haveToken = true),
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryBright),
                child: const Text('I have a reset code'),
              ),
            ),
          ] else ...[
            Text('Choose a new password', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'Paste the code from the reset link (the part after "token=").',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _token,
              decoration: const InputDecoration(
                hintText: 'Reset code',
                prefixIcon: Icon(Icons.key_rounded, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'New password (8+ characters)',
                prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            PillButton(label: 'Update Password', filled: true, loading: _busy, onPressed: _confirm),
          ],
        ],
      ),
    );
  }
}
