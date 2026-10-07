import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/services/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';

/// Sign in / create account, styled after a fight-poster landing screen.
class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _signup = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = ref.read(authControllerProvider.notifier);
    if (_signup) {
      await auth.signup(_email.text.trim(), _username.text.trim(), _password.text);
    } else {
      await auth.login(_email.text.trim(), _password.text);
    }
    final state = ref.read(authControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(state.error!))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider).isLoading;

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.8),
              radius: 1.2,
              colors: [Color(0xB37A1019), AppColors.background],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: BrandMark(size: 32)),
                  const SizedBox(height: 56),
                  const Text(
                    'Every Fight.',
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, height: 1.05, letterSpacing: -0.8),
                  ),
                  const Text(
                    'Every Pick.',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: -0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pick winners on every card, track your accuracy and climb the leaderboard.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 32),
                  _ModeToggle(
                    signup: _signup,
                    onChanged: (v) => setState(() => _signup = v),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.textMuted),
                    ),
                    validator: (v) =>
                        v != null && RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim()) ? null : 'Enter a valid email',
                  ),
                  if (_signup) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _username,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newUsername],
                      decoration: const InputDecoration(
                        hintText: 'Username',
                        prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
                      ),
                      validator: (v) {
                        final len = v?.trim().length ?? 0;
                        return len >= 3 && len <= 32 ? null : '3 to 32 characters';
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    autofillHints: [_signup ? AutofillHints.newPassword : AutofillHints.password],
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your password';
                      if (_signup && v.length < 8) return 'At least 8 characters';
                      return null;
                    },
                  ),
                  if (!_signup)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/reset-password'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                        child: const Text('Forgot password?'),
                      ),
                    )
                  else
                    const SizedBox(height: 24),
                  PillButton(
                    label: _signup ? 'Create Account' : 'Sign In',
                    filled: true,
                    loading: loading,
                    onPressed: _submit,
                    height: 56,
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'By continuing, you agree to our Terms & Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.signup, required this.onChanged});

  final bool signup;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          _segment('Sign In', !signup, () => onChanged(false)),
          _segment('Create Account', signup, () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _segment(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.surfaceHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(21),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: active ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
