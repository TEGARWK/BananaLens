import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Camera permission state as seen by the UI.
enum CameraAccessStatus { granted, denied, permanentlyDenied }

/// Camera permission handling, wrapped so UI and tests avoid the plugin.
abstract class CameraAccess {
  /// Current state without prompting.
  Future<CameraAccessStatus> status();

  /// Shows the system prompt when allowed and returns the new state.
  Future<CameraAccessStatus> request();

  /// Opens the app settings page (used when permanently denied).
  Future<void> openSettings();
}

/// Picks an existing photo from the gallery.
abstract class PhotoSource {
  /// Returns the image path, or null if the user cancelled.
  Future<String?> pickFromGallery();
}

class PermissionHandlerCameraAccess implements CameraAccess {
  @override
  Future<CameraAccessStatus> status() async =>
      _map(await Permission.camera.status);

  @override
  Future<CameraAccessStatus> request() async =>
      _map(await Permission.camera.request());

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }

  CameraAccessStatus _map(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return CameraAccessStatus.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return CameraAccessStatus.permanentlyDenied;
    }
    return CameraAccessStatus.denied;
  }
}

class ImagePickerPhotoSource implements PhotoSource {
  ImagePickerPhotoSource({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    return file?.path;
  }
}
