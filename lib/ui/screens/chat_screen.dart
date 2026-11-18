import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/chat_turn.dart';
import '../../providers/chat_notifier.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_history_sheet.dart';

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

  static const List<String> _contextSuggestedChips = [
    'Apakah buah ini masih aman dikonsumsi?',
    'Ide olahan yang cocok untuk kondisi ini?',
    'Berapa lama & bagaimana cara menyimpannya?',
    'Apa saja kandungan gizinya?',
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: AppDimens.screenPadding,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(AppDimens.rButton - 2),
                border: Border.all(color: ink, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: ink,
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: theme.colorScheme.onPrimary,
                size: 19,
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
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E7D28),
                          shape: BoxShape.circle,
                          border: Border.all(color: ink, width: 1),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'ONLINE // AI',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
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
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.s8),
            child: Center(
              child: InkWell(
                onTap: () => ChatHistorySheet.show(context),
                borderRadius: BorderRadius.circular(AppDimens.rButton - 2),
                child: Tooltip(
                  message: 'Riwayat Chat',
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: harvest.primarySoft,
                      borderRadius: BorderRadius.circular(
                        AppDimens.rButton - 2,
                      ),
                      border: Border.all(color: ink, width: 1.3),
                    ),
                    child: Icon(Icons.history_rounded, color: ink, size: 19),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.s12),
            child: Center(
              child: InkWell(
                onTap: () => _startNewChat(context),
                borderRadius: BorderRadius.circular(AppDimens.rButton - 2),
                child: Tooltip(
                  message: 'Chat Baru',
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(
                        AppDimens.rButton - 2,
                      ),
                      border: Border.all(color: ink, width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: ink,
                          offset: const Offset(1.5, 1.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_comment_outlined,
                      color: theme.colorScheme.onPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Konteks Buah Terpasang
          if (chatState.scanContext != null &&
              chatState.scanContext!.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                AppDimens.s12,
                AppDimens.screenPadding,
                AppDimens.s4,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.s12,
                vertical: AppDimens.s8 + 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppDimens.rButton),
                border: Border.all(color: ink, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary,
                    offset: const Offset(2, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                      border: Border.all(color: ink, width: 1.2),
                    ),
                    child: Icon(
                      Icons.center_focus_strong_rounded,
                      size: 17,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppDimens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'KONTEKS PINDAI AKTIF',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: harvest.muted,
                            fontSize: 9.5,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Konteks: ${chatState.scanContext}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.s8),
                  InkWell(
                    onTap: () => ref
                        .read(chatNotifierProvider.notifier)
                        .setScanContext(null),
                    borderRadius: BorderRadius.circular(AppDimens.rSharp),
                    child: Tooltip(
                      message: 'Lepas konteks',
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: harvest.primarySoft,
                          borderRadius: BorderRadius.circular(AppDimens.rSharp),
                          border: Border.all(color: ink, width: 1.2),
                        ),
                        child: Icon(Icons.close_rounded, size: 16, color: ink),
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
                        color: theme.colorScheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimens.rButton),
                        border: Border.all(
                          color: theme.colorScheme.error,
                          width: 1.5,
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
                                fontWeight: FontWeight.w600,
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

          // Chip Saran Cepat (Touch target >= 44dp)
          Builder(
            builder: (context) {
              final hasContext =
                  chatState.scanContext != null &&
                  chatState.scanContext!.isNotEmpty;
              final chips = hasContext
                  ? _contextSuggestedChips
                  : _suggestedChips;
              return Container(
                height: 48,
                margin: const EdgeInsets.only(bottom: AppDimens.s8),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.screenPadding,
                    0,
                    AppDimens.screenPadding,
                    3,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: chips.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppDimens.s8),
                  itemBuilder: (context, idx) {
                    final prompt = chips[idx];
                    return InkWell(
                      onTap: () => _sendMessage(prompt),
                      borderRadius: BorderRadius.circular(AppDimens.rSharp),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.s12 + 2,
                          vertical: AppDimens.s8,
                        ),
                        decoration: BoxDecoration(
                          color: harvest.primarySoft,
                          borderRadius: BorderRadius.circular(AppDimens.rSharp),
                          border: Border.all(color: ink, width: 1.3),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary,
                              offset: const Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          prompt,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Kolom Input & Tombol Kirim 48dp Taktil
          Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: harvest.border, width: 1.2),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPadding,
                  AppDimens.s8,
                  AppDimens.screenPadding,
                  AppDimens.s8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Tanyakan seputar buah...',
                          isDense: true,
                          filled: true,
                          fillColor: harvest.primarySoft,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.s16,
                            vertical: AppDimens.s12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.rButton,
                            ),
                            borderSide: BorderSide(
                              color: harvest.border,
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.rButton,
                            ),
                            borderSide: BorderSide(color: ink, width: 1.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.s8),
                    Semantics(
                      button: true,
                      label: 'Kirim pesan',
                      child: InkWell(
                        onTap: () => _sendMessage(),
                        borderRadius: BorderRadius.circular(AppDimens.rButton),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              AppDimens.rButton,
                            ),
                            border: Border.all(color: ink, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: ink,
                                offset: const Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
    final ink = theme.colorScheme.onSurface;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s16,
          vertical: AppDimens.s12,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          border: Border.all(color: ink, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary,
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
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
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ink.withValues(
                      alpha: (0.25 + (opacity * 0.75)).clamp(0.0, 1.0),
                    ),
                    borderRadius: BorderRadius.circular(2),
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
