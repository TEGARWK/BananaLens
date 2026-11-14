import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../providers/server_config_provider.dart';

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

    return Container(
      padding: EdgeInsets.only(
        left: AppDimens.s20,
        right: AppDimens.s20,
        top: AppDimens.s16,
        bottom: bottomInset + AppDimens.s24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.rSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppDimens.s16),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppDimens.rPill),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.s8),
                decoration: BoxDecoration(
                  color: harvest.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.dns_rounded,
                  color: theme.colorScheme.primary,
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Hybrid AI MobileNetV3 + SVM (.pkl)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s20),

          // Input field
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: AppStrings.serverAddressLabel,
              hintText: AppStrings.serverAddressHint,
              prefixText: 'http://',
              prefixIcon: const Icon(Icons.wifi_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.s16),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.s12),

          // Status card
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.s12,
              vertical: AppDimens.s8,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.s12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: AppDimens.s8),
                Expanded(
                  child: Text(
                    statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s16),

          // Fallback switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              AppStrings.serverUseFallback,
              style: theme.textTheme.bodyMedium,
            ),
            value: config.useFallback,
            onChanged: (val) {
              ref.read(serverConfigProvider.notifier).setUseFallback(val);
            },
          ),
          const SizedBox(height: AppDimens.s16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
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
                  icon: const Icon(Icons.sensors_rounded),
                  label: const Text(AppStrings.serverTestConnection),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.s12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    final newAddr = _controller.text.trim();
                    await ref
                        .read(serverConfigProvider.notifier)
                        .updateAddress(newAddr);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.s12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                    ),
                  ),
                  child: const Text(AppStrings.serverSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
