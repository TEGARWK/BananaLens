import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/chat_turn.dart';
import '../../providers/chat_notifier.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  static const List<String> _suggestedChips = [
    'Buah apa yang paling tinggi serat?',
    'Berapa lama apel tahan di kulkas?',
    'Cara mematangkan alpukat?',
    'Ide olahan pisang kematangan?',
  ];

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

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: AppDimens.screenPadding,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppDimens.s4),
                      Text(
                        'Online',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
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
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: harvest.muted),
            tooltip: 'Hapus Riwayat Chat',
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).clearConversation();
            },
          ),
          const SizedBox(width: AppDimens.s8),
        ],
      ),
      body: Column(
        children: [
          // Chip Konteks Buah (bila ada)
          if (chatState.scanContext != null &&
              chatState.scanContext!.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding,
                vertical: AppDimens.s4,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.s12,
                vertical: AppDimens.s4,
              ),
              decoration: BoxDecoration(
                color: harvest.primarySoft,
                borderRadius: BorderRadius.circular(AppDimens.rPill),
                border: Border.all(color: harvest.border, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco_rounded,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppDimens.s4),
                  Flexible(
                    child: Text(
                      'Konteks: ${chatState.scanContext}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Daftar Pesan
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              children: [
                ...chatState.messages.map((turn) {
                  return ChatBubble(
                    text: turn.content,
                    isUser: turn.role == ChatRole.user,
                  );
                }),
                if (chatState.isLoading) ...[
                  const SizedBox(height: AppDimens.s8),
                  const _TypingIndicator(),
                ],
                if (chatState.error != null) ...[
                  const SizedBox(height: AppDimens.s8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(AppDimens.s12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimens.s12),
                        border: Border.all(
                          color: theme.colorScheme.error,
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
                              chatState.error!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Chip Saran Cepat
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: AppDimens.s8),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedChips.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppDimens.s8),
              itemBuilder: (context, idx) {
                final prompt = _suggestedChips[idx];
                return ActionChip(
                  label: Text(prompt),
                  onPressed: () => _sendMessage(prompt),
                  labelStyle: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.rPill),
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                );
              },
            ),
          ),

          // Kolom Input Pil & Tombol Kirim 40dp Bulat
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                AppDimens.s4,
                AppDimens.screenPadding,
                AppDimens.s8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Tanyakan seputar buah...',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppDimens.s16,
                          vertical: AppDimens.s12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.s8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s16,
          vertical: AppDimens.s12,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimens.s16),
          border: Border.all(color: harvest.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final delay = index * 0.25;
                final val = (_animController.value - delay) % 1.0;
                final opacity = (val > 0.5 ? (1.0 - val) : val) * 2;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(
                      alpha: (0.3 + (opacity * 0.7)).clamp(0.0, 1.0),
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
