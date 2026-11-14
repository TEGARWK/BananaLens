import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/constants/app_strings.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/providers/camera_providers.dart';
import 'package:fruitlens/services/camera_access.dart';
import 'package:fruitlens/ui/screens/scan_screen.dart';

class _FakeCameraAccess implements CameraAccess {
  _FakeCameraAccess({this.initial = CameraAccessStatus.denied});

  CameraAccessStatus initial;
  bool requested = false;
  bool openedSettings = false;

  @override
  Future<CameraAccessStatus> status() async => initial;

  @override
  Future<CameraAccessStatus> request() async {
    requested = true;
    initial = CameraAccessStatus.granted;
    return initial;
  }

  @override
  Future<void> openSettings() async {
    openedSettings = true;
  }
}

class _FakePhotoSource implements PhotoSource {
  @override
  Future<String?> pickFromGallery() async => 'gallery_photo.jpg';
}

void main() {
  testWidgets('shows permission denied UI and request button', (tester) async {
    final fakeAccess = _FakeCameraAccess(initial: CameraAccessStatus.denied);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraAccessProvider.overrideWithValue(fakeAccess),
          photoSourceProvider.overrideWithValue(_FakePhotoSource()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ScanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.cameraPermissionTitle), findsOneWidget);
    expect(find.text(AppStrings.cameraAllow), findsOneWidget);
    expect(find.text(AppStrings.pickFromGallery), findsOneWidget);

    // Tap izinkan kamera
    await tester.tap(find.text(AppStrings.cameraAllow));
    await tester.pump();
    expect(fakeAccess.requested, isTrue);
  });
}
