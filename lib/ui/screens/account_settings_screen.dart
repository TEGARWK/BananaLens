import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:fruitlens/data/models/user_profile.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/ui/widgets/account_preference_tiles.dart';
import 'package:fruitlens/ui/widgets/account_settings_sections.dart';
import 'package:fruitlens/ui/widgets/app_card.dart';
import 'package:fruitlens/ui/widgets/app_text_field.dart';
import 'package:fruitlens/ui/widgets/empty_state.dart';
import 'package:fruitlens/ui/widgets/fruitlens_app_bar.dart';
import 'package:fruitlens/ui/widgets/shimmer_box.dart';
import 'package:fruitlens/ui/widgets/soft_button.dart';
import 'package:go_router/go_router.dart';

/// Dedicated account and health preferences editor with clean card hierarchy.
class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _selectedGoal = 'Pola Hidup Sehat';
  final Set<String> _selectedAllergies = <String>{};
  String? _populatedUid;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _syncFromUser(UserProfile user) {
    if (_populatedUid == user.uid) return;
    _populatedUid = user.uid;
    _nameCtrl.text = user.name;
    _ageCtrl.text = user.age > 0 ? user.age.toString() : '';
    _weightCtrl.text = user.weight > 0 ? user.weight.toStringAsFixed(1) : '';
    _selectedGoal = AccountGoalSelector.normalize(user.goal);
    _selectedAllergies
      ..clear()
      ..addAll(user.allergies);
  }

  Future<void> _save(UserProfile user) async {
    setState(() => _saving = true);
    try {
      final updated = user.copyWith(
        name: _nameCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text.trim()) ?? user.age,
        weight:
            double.tryParse(_weightCtrl.text.trim().replaceAll(',', '.')) ??
            user.weight,
        goal: _selectedGoal,
        allergies: _selectedAllergies.toList(),
      );
      await ref.read(authNotifierProvider.notifier).updateProfile(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil & preferensi kesehatan berhasil diperbarui'),
        ),
      );
      context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: const FruitLensAppBar(
        title: 'Pengaturan Akun',
        showBackButton: true,
      ),
      body: authAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          children: const [
            ShimmerBox(height: 56, radius: AppDimens.rCard),
            SizedBox(height: AppDimens.s12),
            ShimmerBox(height: 56, radius: AppDimens.rCard),
            SizedBox(height: AppDimens.s16),
            ShimmerBox(height: 120, radius: AppDimens.rCard),
            SizedBox(height: AppDimens.s16),
            ShimmerBox(height: 48, radius: AppDimens.rButton),
          ],
        ),
        error: (_, _) => Center(
          child: SoftButton(
            text: 'Muat Ulang Profil',
            onPressed: () => ref.invalidate(authNotifierProvider),
          ),
        ),
        data: (user) {
          if (user == null) {
            return EmptyState(
              icon: Icons.lock_person_outlined,
              title: 'Masuk Terlebih Dahulu',
              message:
                  'Pengaturan tujuan kesehatan dan alergi buah tersedia setelah masuk ke akun.',
              actionText: 'Masuk atau Daftar',
              onAction: () => context.push('/auth'),
            );
          }
          _syncFromUser(user);
          return _buildBody(context, user);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserProfile user) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.s16,
              AppDimens.s16,
              AppDimens.s16,
              AppDimens.s24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountIdentityBanner(user: user),
                const SizedBox(height: AppDimens.s16),
                _buildIdentityCard(theme),
                const SizedBox(height: AppDimens.s16),
                _buildPreferenceCard(
                  theme: theme,
                  harvest: harvest,
                  title: 'Tujuan Kesehatan',
                  subtitle: 'Rekomendasi gizi & resep disesuaikan targetmu',
                  child: AccountGoalSelector(
                    selectedGoal: _selectedGoal,
                    onChanged: (goal) => setState(() => _selectedGoal = goal),
                  ),
                ),
                const SizedBox(height: AppDimens.s16),
                _buildPreferenceCard(
                  theme: theme,
                  harvest: harvest,
                  title: 'Peringatan Alergi Buah',
                  subtitle: 'Aplikasi memberi peringatan otomatis saat scan',
                  child: AccountAllergySelector(
                    selectedAllergies: _selectedAllergies,
                    onToggle: (allergen, selected) => setState(() {
                      if (selected) {
                        _selectedAllergies.add(allergen);
                      } else {
                        _selectedAllergies.remove(allergen);
                      }
                    }),
                  ),
                ),
                const SizedBox(height: AppDimens.s16),
                AccountPasswordTile(email: user.email),
              ],
            ),
          ),
        ),
        AccountBottomSaveBar(isSaving: _saving, onSave: () => _save(user)),
      ],
    );
  }

  Widget _buildIdentityCard(ThemeData theme) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Data Diri',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.s12),
          AppTextField(
            controller: _nameCtrl,
            label: 'Nama Lengkap',
            hintText: 'Masukkan nama kamu',
            prefixIcon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppDimens.s12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _ageCtrl,
                  label: 'Usia',
                  hintText: '25',
                  suffixText: 'th',
                  prefixIcon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: AppTextField(
                  controller: _weightCtrl,
                  label: 'Berat Badan',
                  hintText: '60',
                  suffixText: 'kg',
                  prefixIcon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard({
    required ThemeData theme,
    required HarvestColors harvest,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: harvest.muted),
          ),
          const SizedBox(height: AppDimens.s12),
          child,
        ],
      ),
    );
  }
}
