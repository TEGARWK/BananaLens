import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/services/camera_access.dart';

final cameraAccessProvider = Provider<CameraAccess>(
  (ref) => PermissionHandlerCameraAccess(),
);

final photoSourceProvider = Provider<PhotoSource>(
  (ref) => ImagePickerPhotoSource(),
);

/// Current camera permission; call [CameraPermissionNotifier.request] or
/// [CameraPermissionNotifier.refresh] to update it.
final cameraPermissionProvider =
    AsyncNotifierProvider<CameraPermissionNotifier, CameraAccessStatus>(
      CameraPermissionNotifier.new,
    );

class CameraPermissionNotifier extends AsyncNotifier<CameraAccessStatus> {
  @override
  Future<CameraAccessStatus> build() => ref.read(cameraAccessProvider).status();

  Future<void> request() async {
    state = await AsyncValue.guard(
      () => ref.read(cameraAccessProvider).request(),
    );
  }

  /// Re-reads the status, e.g. after returning from app settings.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(cameraAccessProvider).status(),
    );
  }

  Future<void> openSettings() => ref.read(cameraAccessProvider).openSettings();
}
