import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

/// Horizontal strip of suggested quick-prompt chips above the chat composer.
class ChatSuggestedChips extends StatelessWidget {
  const ChatSuggestedChips({
    super.key,
    required this.prompts,
    required this.onSelect,
  });

  final List<String> prompts;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: AppDimens.s8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenPadding,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimens.s8),
        itemBuilder: (context, idx) {
          final prompt = prompts[idx];
          return Material(
            color: harvest.primarySoft,
            borderRadius: BorderRadius.circular(AppDimens.rButton),
            child: InkWell(
              onTap: () => onSelect(prompt),
              borderRadius: BorderRadius.circular(AppDimens.rButton),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s12 + 2,
                  vertical: AppDimens.s8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                  border: Border.all(color: harvest.border, width: 1),
                ),
                child: Text(
                  prompt,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Docked bottom message input field and dark-chocolate send action button.
class ChatInputComposer extends StatelessWidget {
  const ChatInputComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    final sendBg = isDark ? theme.colorScheme.primary : AppColors.lSurfaceDark;
    final sendFg = isDark ? theme.colorScheme.onPrimary : AppColors.lPrimary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: harvest.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            AppDimens.s8 + 2,
            AppDimens.screenPadding,
            AppDimens.s8 + 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ink,
                    fontSize: 14.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tanyakan seputar pisang...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: harvest.muted,
                      fontSize: 14,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.s16,
                      vertical: AppDimens.s12 + 1,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                      borderSide: BorderSide(color: harvest.border, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                      borderSide: BorderSide(color: ink, width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.s8),
              Semantics(
                button: true,
                label: 'Kirim pesan',
                child: Material(
                  color: sendBg,
                  borderRadius: BorderRadius.circular(AppDimens.rButton),
                  child: InkWell(
                    onTap: isLoading ? null : onSend,
                    borderRadius: BorderRadius.circular(AppDimens.rButton),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        color: sendFg,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subtle animated typing indicator bubble while AI is composing a response.
class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({super.key});

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
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
    final isDark = theme.brightness == Brightness.dark;
    final dotColor = isDark ? AppColors.dLeafGreen : AppColors.lLeafStrong;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s16,
          vertical: AppDimens.s12,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimens.rCard),
            topRight: Radius.circular(AppDimens.rCard),
            bottomRight: Radius.circular(AppDimens.rCard),
            bottomLeft: Radius.circular(AppDimens.rSharp),
          ),
          border: Border.all(color: harvest.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(3, (index) {
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
                      color: dotColor.withValues(
                        alpha: (0.25 + (opacity * 0.75)).clamp(0.0, 1.0),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
            const SizedBox(width: AppDimens.s8),
            Text(
              'Mengetik...',
              style: theme.textTheme.labelSmall?.copyWith(
                color: harvest.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
