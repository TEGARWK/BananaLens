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
    final ink = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(AppDimens.rButton),
      topRight: const Radius.circular(AppDimens.rButton),
      bottomLeft: isUser
          ? const Radius.circular(AppDimens.rButton)
          : const Radius.circular(AppDimens.rSharp),
      bottomRight: isUser
          ? const Radius.circular(AppDimens.rSharp)
          : const Radius.circular(AppDimens.rButton),
    );

    final backgroundColor = isUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;

    final textColor = isUser
        ? theme.colorScheme.onPrimary
        : (theme.textTheme.bodyLarge?.color ?? ink);

    final borderColor = isUser
        ? (isDark ? theme.colorScheme.primary : const Color(0xFF181A16))
        : (isDark
              ? theme.colorScheme.primary.withValues(alpha: 0.6)
              : const Color(0xFF4A4E42));

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimens.s4 + 2),
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
          border: Border.all(color: borderColor, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? (isDark ? Colors.black : const Color(0xFF181A16))
                  : theme.colorScheme.primary.withValues(alpha: 0.65),
              offset: const Offset(2, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: isUser
            ? Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          border: Border.all(color: ink, width: 1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'BANANALENS AI',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: harvest.muted,
                          fontSize: 9.5,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  MarkdownBody(
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
                        color: ink,
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
                ],
              ),
      ),
    );
  }
}
