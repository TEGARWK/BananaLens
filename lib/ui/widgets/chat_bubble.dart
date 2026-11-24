import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

/// Clean 60-30-10 editorial chat bubble for BananaLens AI and user turns.
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
      topLeft: const Radius.circular(AppDimens.rCard),
      topRight: const Radius.circular(AppDimens.rCard),
      bottomLeft: isUser
          ? const Radius.circular(AppDimens.rCard)
          : const Radius.circular(AppDimens.rSharp),
      bottomRight: isUser
          ? const Radius.circular(AppDimens.rSharp)
          : const Radius.circular(AppDimens.rCard),
    );

    final backgroundColor = isUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;

    final textColor = isUser ? theme.colorScheme.onPrimary : ink;

    final leafAccent = isDark ? AppColors.dLeafGreen : AppColors.lLeafStrong;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimens.s4 + 1),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.80 : 0.88),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s16,
          vertical: AppDimens.s12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: isUser ? null : Border.all(color: harvest.border, width: 1),
        ),
        child: isUser
            ? Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  fontSize: 14.5,
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
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: leafAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'BANANALENS AI',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: harvest.muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  MarkdownBody(
                    data: text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        height: 1.5,
                        fontSize: 14.5,
                      ),
                      strong: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                      em: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontStyle: FontStyle.italic,
                        fontSize: 14.5,
                      ),
                      listBullet: theme.textTheme.bodyMedium?.copyWith(
                        color: leafAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                      h1: theme.textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                      h2: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                      h3: theme.textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: harvest.primarySoft,
                        border: Border(
                          left: BorderSide(color: leafAccent, width: 3),
                        ),
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
