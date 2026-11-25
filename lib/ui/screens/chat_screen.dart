import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/chat_turn.dart';
import '../../providers/chat_notifier.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_context_banner.dart';
import '../widgets/chat_history_sheet.dart';
import '../widgets/chat_starter_grid.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _textController.text;
    if (text.trim().isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }
    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _startNewChat(BuildContext context) {
    final notifier = ref.read(chatNotifierProvider.notifier);
    final hadUserMessages = ref
        .read(chatNotifierProvider)
        .messages
        .any((m) => m.isUser);
    notifier.startNewChat();
    if (!hadUserMessages) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Percakapan disimpan. Memulai chat baru...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    final hasContext =
        chatState.scanContext != null && chatState.scanContext!.isNotEmpty;
    final hasUserMessages = chatState.messages.any((m) => m.isUser);
    final leafDot = isDark ? AppColors.dLeafGreen : AppColors.lLeafStrong;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: AppDimens.screenPadding,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: harvest.border),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(AppDimens.rButton),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: theme.colorScheme.onPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.chatTitle,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: leafDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'ONLINE · ASISTEN AI',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: harvest.muted,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _HeaderIconButton(
            tooltip: 'Riwayat Chat',
            icon: Icons.history_rounded,
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: ink,
            borderColor: harvest.border,
            onTap: () => ChatHistorySheet.show(context),
          ),
          const SizedBox(width: AppDimens.s8),
          _HeaderIconButton(
            tooltip: 'Chat Baru',
            icon: Icons.add_comment_outlined,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            onTap: () => _startNewChat(context),
          ),
          const SizedBox(width: AppDimens.screenPadding),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Column(
            children: [
              if (hasContext)
                ChatContextBanner(
                  scanContext: chatState.scanContext!,
                  onDismiss: () => ref
                      .read(chatNotifierProvider.notifier)
                      .setScanContext(null),
                ),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.screenPadding,
                    AppDimens.s16,
                    AppDimens.screenPadding,
                    AppDimens.s12,
                  ),
                  children: [
                    ...chatState.messages.map((turn) {
                      return ChatBubble(
                        text: turn.content,
                        isUser: turn.role == ChatRole.user,
                      );
                    }),
                    if (!hasUserMessages && !chatState.isLoading)
                      ChatStarterGrid(
                        hasContext: hasContext,
                        onSelectPrompt: _sendMessage,
                      ),
                    if (chatState.isLoading) ...[
                      const SizedBox(height: AppDimens.s8),
                      const ChatTypingIndicator(),
                    ],
                    if (chatState.error != null) ...[
                      const SizedBox(height: AppDimens.s8),
                      _ChatErrorNotice(
                        message: chatState.error!,
                        onRetry: () {
                          ref
                              .read(chatNotifierProvider.notifier)
                              .retryLastMessage();
                          _scrollToBottom();
                        },
                      ),
                    ],
                  ],
                ),
              ),
              ChatInputComposer(
                controller: _textController,
                onSend: _sendMessage,
                isLoading: chatState.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
    this.borderColor,
  });

  final String tooltip;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        button: true,
        label: tooltip,
        child: Tooltip(
          message: tooltip,
          child: Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimens.rButton),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppDimens.rButton),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                  border: borderColor != null
                      ? Border.all(color: borderColor!, width: 1)
                      : null,
                ),
                child: Icon(icon, color: foregroundColor, size: 19),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatErrorNotice extends StatelessWidget {
  const _ChatErrorNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.s12),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppDimens.rCard),
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: AppDimens.s8),
            Flexible(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppDimens.s8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s8,
                  vertical: 4,
                ),
                minimumSize: const Size(44, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Coba lagi',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
