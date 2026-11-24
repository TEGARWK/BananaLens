import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/services/auth_service.dart';
import 'package:fruitlens/ui/widgets/app_text_field.dart';
import 'package:fruitlens/ui/widgets/auth_widgets.dart';
import 'package:fruitlens/ui/widgets/industrial_art.dart';
import 'package:fruitlens/ui/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

/// Authentication screen supporting Login, Registration (via animated switch),
/// and navigation to Forgot Password page in Editorial Scanner Flat style.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.initialRegister = false});

  final bool initialRegister;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late bool _isRegister;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialRegister;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isRegister = !_isRegister;
      _errorMessage = null;
    });
  }

  void _navigateBackOrHome() {
    if (!mounted) return;
    showAuthSuccessOverlay(context, isRegister: _isRegister);
    context.go('/');
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    try {
      if (_isRegister) {
        await ref
            .read(authNotifierProvider.notifier)
            .register(email, password, name);
      } else {
        await ref.read(authNotifierProvider.notifier).login(email, password);
      }
      _navigateBackOrHome();
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Autentikasi gagal. Silakan coba lagi.');
      }
    }
  }

  Future<void> _openForgotPassword() async {
    final email = _emailController.text.trim();
    final route = Uri(
      path: '/forgot-password',
      queryParameters: email.isEmpty ? null : <String, String>{'email': email},
    ).toString();
    final updated = await context.push<bool>(route);
    if (updated == true && mounted) {
      setState(() => _errorMessage = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi berhasil diperbarui. Silakan masuk.'),
        ),
      );
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
    required TextInputAction action,
    ValueChanged<String>? onSubmit,
    FormFieldValidator<String>? validator,
  }) {
    return AppTextField(
      controller: controller,
      label: label,
      hintText: hint,
      prefixIcon: icon,
      obscureText: obscure,
      textInputAction: action,
      onFieldSubmitted: onSubmit,
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: onToggle,
      ),
      validator: validator,
    );
  }

  Widget _buildFormFields(BuildContext context, bool isLoading) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        IndustrialSpecimenCard(
          padding: const EdgeInsets.all(AppDimens.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_isRegister) ...<Widget>[
                AppTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hintText: 'Contoh: Budi Santoso',
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: AppDimens.s16),
              ],
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hintText: LocalAuthService.demoEmail,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (String? v) => (v == null || !v.contains('@'))
                    ? 'Format email tidak valid'
                    : null,
              ),
              const SizedBox(height: AppDimens.s16),
              _buildPasswordField(
                controller: _passwordController,
                label: 'Kata Sandi',
                hint: 'Minimal 6 karakter',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                action: _isRegister
                    ? TextInputAction.next
                    : TextInputAction.done,
                onSubmit: _isRegister ? null : (_) => _submit(),
                validator: (String? v) => (v == null || v.length < 6)
                    ? 'Kata sandi minimal 6 karakter'
                    : null,
              ),
              if (_isRegister) ...<Widget>[
                const SizedBox(height: AppDimens.s16),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Kata Sandi',
                  hint: 'Ulangi kata sandi',
                  icon: Icons.verified_user_outlined,
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  action: TextInputAction.done,
                  onSubmit: (_) => _submit(),
                  validator: (String? v) {
                    if (v == null || v.isEmpty) {
                      return 'Konfirmasi kata sandi wajib diisi';
                    }
                    if (v != _passwordController.text) {
                      return 'Kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),
              ] else
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : _openForgotPassword,
                    child: Text(
                      'Lupa kata sandi?',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: harvest.accent,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: harvest.accent,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppDimens.s16),
              PrimaryButton(
                text: _isRegister ? 'Buat Akun Sekarang' : 'Masuk',
                isLoading: isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.s8),
        AuthSwitchPrompt(isRegister: _isRegister, onToggle: _toggleMode),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: Text(
            _isRegister ? 'Daftar Akun' : 'Masuk ke BananaLens',
            key: ValueKey<bool>(_isRegister),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.s20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AuthHeader(isRegister: _isRegister),
                if (_errorMessage != null) ...<Widget>[
                  const SizedBox(height: AppDimens.s16),
                  AuthErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: AppDimens.s20),
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: ClipRect(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            final isIncoming =
                                child.key == ValueKey<bool>(_isRegister);
                            final direction = _isRegister ? 1.0 : -1.0;
                            final beginOffset = isIncoming
                                ? Offset(direction, 0)
                                : Offset(-direction, 0);
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: beginOffset,
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                      child: KeyedSubtree(
                        key: ValueKey<bool>(_isRegister),
                        child: _buildFormFields(context, isLoading),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
