import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(AppDimens.s16),
      topRight: const Radius.circular(AppDimens.s16),
      bottomLeft: isUser
          ? const Radius.circular(AppDimens.s16)
          : const Radius.circular(AppDimens.s4),
      bottomRight: isUser
          ? const Radius.circular(AppDimens.s4)
          : const Radius.circular(AppDimens.s16),
    );

    final backgroundColor = isUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;

    final textColor = isUser
        ? theme.colorScheme.onPrimary
        : (theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimens.s4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.78 : 0.88),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s16,
          vertical: AppDimens.s12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: isUser ? null : Border.all(color: harvest.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isUser
            ? Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  height: 1.4,
                ),
              )
            : MarkdownBody(
                data: text,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    height: 1.45,
                    fontSize: 14.5,
                  ),
                  strong: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                  em: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontStyle: FontStyle.italic,
                    fontSize: 14.5,
                  ),
                  listBullet: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                  h1: theme.textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: theme.textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  h3: theme.textTheme.titleSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  blockSpacing: 8.0,
                  listIndent: 16.0,
                ),
              ),
      ),
    );
  }
}
