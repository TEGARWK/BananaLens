import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/services/auth_service.dart';
import 'package:fruitlens/ui/widgets/app_text_field.dart';
import 'package:fruitlens/ui/widgets/auth_widgets.dart';
import 'package:fruitlens/ui/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

/// Dedicated screen allowing registered local users to reset their password.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .resetPassword(_emailController.text, _newPasswordController.text);
      if (mounted) {
        context.pop(true);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Gagal mengatur ulang kata sandi. Coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Kata Sandi')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.s20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    'assets/images/auth/auth_forgot.png',
                    height: 164,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: AppDimens.s12),
                Text(
                  'Lupa Kata Sandi?',
                  textAlign: TextAlign.center,
                  style: AppTheme.pixelDisplayStyle(
                    context,
                    fontSize: 19,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimens.s4),
                Text(
                  'Masukkan email terdaftar dan buat kata sandi baru untuk akunmu.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: harvest.muted,
                  ),
                ),
                if (_errorMessage != null) ...<Widget>[
                  const SizedBox(height: AppDimens.s16),
                  AuthErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: AppDimens.s24),
                AppTextField(
                  controller: _emailController,
                  label: 'Email Terdaftar',
                  hintText: LocalAuthService.demoEmail,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) {
                    final text = v?.trim() ?? '';
                    if (text.isEmpty || !text.contains('@')) {
                      return 'Masukkan format email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimens.s16),
                AppTextField(
                  controller: _newPasswordController,
                  label: 'Kata Sandi Baru',
                  hintText: 'Minimal 6 karakter',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (String? v) => (v == null || v.length < 6)
                      ? 'Kata sandi minimal 6 karakter'
                      : null,
                ),
                const SizedBox(height: AppDimens.s16),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Kata Sandi Baru',
                  hintText: 'Ulangi kata sandi baru',
                  prefixIcon: Icons.verified_user_outlined,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (String? v) {
                    if (v == null || v.isEmpty) {
                      return 'Konfirmasi kata sandi wajib diisi';
                    }
                    if (v != _newPasswordController.text) {
                      return 'Kata sandi baru tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimens.s24),
                PrimaryButton(
                  text: 'Simpan Kata Sandi Baru',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
