import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/chat_session.dart';
import '../../providers/chat_notifier.dart';
import 'industrial_art.dart';
import 'primary_button.dart';
import 'soft_button.dart';

/// Tactile industrial bottom sheet displaying saved AI chat sessions and
/// quick New Chat / Delete actions.
class ChatHistorySheet extends ConsumerWidget {
  const ChatHistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatHistorySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final chatState = ref.watch(chatNotifierProvider);
    final sessions = chatState.sessions;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.rHero),
        ),
        border: Border(top: BorderSide(color: ink, width: 1.6)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.s20,
        AppDimens.s12,
        AppDimens.s20,
        AppDimens.s24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  label: 'RIWAYAT // CHAT AI',
                  accent: true,
                ),
                InkWell(
                  onTap: () {
                    ref.read(chatNotifierProvider.notifier).startNewChat();
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.s12,
                      vertical: AppDimens.s4 + 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                      border: Border.all(color: ink, width: 1.3),
                      boxShadow: [
                        BoxShadow(
                          color: ink,
                          offset: const Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 15,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Chat Baru',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.s12),
            Text(
              'Riwayat Percakapan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Pilih percakapan sebelumnya atau mulai obrolan baru.',
              style: theme.textTheme.bodySmall?.copyWith(color: harvest.muted),
            ),
            const SizedBox(height: AppDimens.s16),
            if (sessions.isEmpty)
              IndustrialSpecimenCard(
                padding: const EdgeInsets.all(AppDimens.s16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: harvest.primarySoft,
                        borderRadius: BorderRadius.circular(AppDimens.rSharp),
                        border: Border.all(color: harvest.border),
                      ),
                      child: Icon(Icons.forum_outlined, color: ink, size: 20),
                    ),
                    const SizedBox(width: AppDimens.s12),
                    Expanded(
                      child: Text(
                        'Belum ada riwayat percakapan. Kirim pertanyaan pertamamu ke BananaLens AI.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: harvest.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppDimens.s8),
                  itemBuilder: (BuildContext ctx, int i) {
                    final session = sessions[i];
                    final isActive = session.id == chatState.activeSessionId;
                    return _SessionTile(
                      session: session,
                      isActive: isActive,
                      onTap: () {
                        ref
                            .read(chatNotifierProvider.notifier)
                            .selectSession(session.id);
                        Navigator.of(context).pop();
                      },
                      onDelete: () async {
                        final ok = await _confirmDelete(
                          context,
                          tag: 'HAPUS // CHAT',
                          title: 'Hapus Percakapan?',
                          message:
                              'Percakapan "${session.title}" akan dihapus permanen.',
                          confirmLabel: 'Hapus',
                        );
                        if (ok == true) {
                          ref
                              .read(chatNotifierProvider.notifier)
                              .deleteSession(session.id);
                        }
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: AppDimens.s16),
            if (sessions.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: SoftButton(
                      text: 'Hapus Semua',
                      height: 48,
                      fullWidth: true,
                      onPressed: () async {
                        final ok = await _confirmDelete(
                          context,
                          tag: 'HAPUS // SEMUA CHAT',
                          title: 'Hapus Semua Riwayat?',
                          message:
                              'Seluruh riwayat percakapan dengan BananaLens AI akan dihapus permanen.',
                          confirmLabel: 'Hapus',
                        );
                        if (ok == true && context.mounted) {
                          ref
                              .read(chatNotifierProvider.notifier)
                              .clearAllHistory();
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimens.s12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Tutup',
                      height: 48,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              )
            else
              PrimaryButton(
                text: 'Tutup',
                height: 48,
                onPressed: () => Navigator.of(context).pop(),
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  final ChatSession session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final userCount = session.messages.where((m) => m.isUser).length;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.rButton),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.s12),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.25)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          border: Border.all(
            color: isActive ? ink : harvest.border,
            width: isActive ? 1.6 : 1.1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary,
                    offset: const Offset(0, 2.5),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary
                    : harvest.primarySoft,
                borderRadius: BorderRadius.circular(AppDimens.rSharp),
                border: Border.all(
                  color: isActive ? ink : harvest.border,
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: isActive ? theme.colorScheme.onPrimary : ink,
              ),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              AppDimens.rSharp,
                            ),
                            border: Border.all(color: ink, width: 1),
                          ),
                          child: Text(
                            'AKTIF',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$userCount pertanyaan · ${_formatTime(session.updatedAt)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: harvest.muted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 19,
                color: harvest.muted,
              ),
              tooltip: 'Hapus percakapan ini',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _confirmDelete(
  BuildContext context, {
  required String tag,
  required String title,
  required String message,
  required String confirmLabel,
}) {
  final theme = Theme.of(context);
  final harvest = context.harvest;
  final ink = theme.colorScheme.onSurface;

  return showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppDimens.s24),
      child: IndustrialSpecimenCard(
        padding: const EdgeInsets.all(AppDimens.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IndustrialTagChip(label: tag),
                Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.s16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.s8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: harvest.muted),
            ),
            const SizedBox(height: AppDimens.s20),
            Row(
              children: [
                Expanded(
                  child: SoftButton(
                    text: 'Batal',
                    height: 48,
                    fullWidth: true,
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                ),
                const SizedBox(width: AppDimens.s12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                      boxShadow: [
                        BoxShadow(
                          color: ink,
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.rButton,
                          ),
                          side: BorderSide(color: ink, width: 1.5),
                        ),
                        elevation: 0,
                      ),
                      child: Text(confirmLabel),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
