import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../providers/server_config_provider.dart';
import 'industrial_art.dart';
import 'primary_button.dart';
import 'soft_button.dart';

class ServerConfigSheet extends ConsumerStatefulWidget {
  const ServerConfigSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ServerConfigSheet(),
    );
  }

  @override
  ConsumerState<ServerConfigSheet> createState() => _ServerConfigSheetState();
}

class _ServerConfigSheetState extends ConsumerState<ServerConfigSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final currentAddress = ref.read(serverConfigProvider).serverAddress;
    _controller = TextEditingController(text: currentAddress);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = theme.extension<HarvestColors>()!;
    final config = ref.watch(serverConfigProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (config.status) {
      case ServerConnectionStatus.online:
        statusColor = harvest.ripe;
        statusIcon = Icons.check_circle_rounded;
        statusText = config.statusMessage ?? AppStrings.serverConnected;
      case ServerConnectionStatus.offline:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.error_outline_rounded;
        statusText = config.statusMessage ?? AppStrings.serverDisconnected;
      case ServerConnectionStatus.checking:
        statusColor = harvest.accent;
        statusIcon = Icons.sync_rounded;
        statusText = AppStrings.serverTesting;
      case ServerConnectionStatus.initial:
        statusColor = theme.colorScheme.onSurfaceVariant;
        statusIcon = Icons.help_outline_rounded;
        statusText = 'Belum diuji koneksinya';
    }

    final ink = theme.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.only(
        left: AppDimens.s20,
        right: AppDimens.s20,
        top: AppDimens.s12,
        bottom: bottomInset + AppDimens.s24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.rHero),
        ),
        border: Border(top: BorderSide(color: ink, width: 1.6)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: AppDimens.s16),
                decoration: BoxDecoration(
                  color: ink.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const IndustrialTagChip(
                  label: 'KONFIGURASI // SERVER',
                  accent: true,
                ),
                Text(
                  'BANANALENS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: harvest.muted,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.s12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimens.s8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppDimens.rSharp),
                    border: Border.all(color: ink, width: 1.3),
                  ),
                  child: Icon(
                    Icons.dns_rounded,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: AppDimens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.serverConfigTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Hybrid AI MobileNetV3 + SVM (.pkl)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: harvest.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.s16),

            // Input field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: AppStrings.serverAddressLabel,
                hintText: AppStrings.serverAddressHint,
                prefixText: 'http://',
                prefixIcon: const Icon(Icons.wifi_rounded),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.s12),

            // Status & Fallback card
            IndustrialSpecimenCard(
              padding: const EdgeInsets.all(AppDimens.s12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.s12,
                      vertical: AppDimens.s8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18),
                        const SizedBox(width: AppDimens.s8),
                        Expanded(
                          child: Text(
                            statusText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.s4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      AppStrings.serverUseFallback,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: config.useFallback,
                    onChanged: (val) {
                      ref
                          .read(serverConfigProvider.notifier)
                          .setUseFallback(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.s16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SoftButton(
                    text: AppStrings.serverTestConnection,
                    icon: Icons.sensors_rounded,
                    onPressed: config.status == ServerConnectionStatus.checking
                        ? null
                        : () async {
                            final newAddr = _controller.text.trim();
                            await ref
                                .read(serverConfigProvider.notifier)
                                .updateAddress(newAddr);
                            if (context.mounted) {
                              await ref
                                  .read(serverConfigProvider.notifier)
                                  .testConnection();
                            }
                          },
                  ),
                ),
                const SizedBox(width: AppDimens.s12),
                Expanded(
                  child: PrimaryButton(
                    text: AppStrings.serverSave,
                    icon: Icons.check_rounded,
                    onPressed: () async {
                      final newAddr = _controller.text.trim();
                      await ref
                          .read(serverConfigProvider.notifier)
                          .updateAddress(newAddr);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
