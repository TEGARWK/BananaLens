import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/providers/chat_notifier.dart';
import 'package:fruitlens/providers/service_providers.dart';
import 'package:fruitlens/services/fake_chat_service.dart';
import 'package:fruitlens/ui/screens/chat_screen.dart';

class _ContextChatNotifier extends ChatNotifier {
  _ContextChatNotifier(this._scanContext);

  final String _scanContext;

  @override
  ChatState build() => ChatState(scanContext: _scanContext);
}

void main() {
  testWidgets('renders chat screen with greeting and suggested prompt chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatServiceProvider.overrideWithValue(
            FakeChatService(delay: Duration.zero),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ChatScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.chatTitle), findsOneWidget);
    expect(find.textContaining('Halo! Saya asisten'), findsOneWidget);
    expect(find.text('Buah apa yang paling tinggi serat?'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('wraps long scanContext chip cleanly without horizontal overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    const longContext =
        'Pisang Cavendish (Matang · 98% keyakinan) dengan kandungan kalium tinggi, '
        'serat larut, vitamin B6, dan cocok dijadikan smoothie sehat setelah olahraga.';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatServiceProvider.overrideWithValue(
            FakeChatService(delay: Duration.zero),
          ),
          chatNotifierProvider.overrideWith(
            () => _ContextChatNotifier(longContext),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ChatScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Konteks: Pisang Cavendish'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
