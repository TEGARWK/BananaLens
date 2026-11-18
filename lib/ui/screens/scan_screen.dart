import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../providers/camera_providers.dart';
import '../../providers/scan_notifier.dart';
import '../../services/camera_access.dart';
import '../widgets/primary_button.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _availableCameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitializing = false;
  String? _cameraError;
  bool _isFlashOn = false;

  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Only repeat scan line animation when not in test environment
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains(
      'TestWidgetsFlutterBinding',
    );
    if (!isTest) {
      _scanLineController.repeat(reverse: true);
    }

    _scanLineAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _initCameraIfPermitted();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanLineController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(cameraPermissionProvider.notifier).refresh();
      _initCameraIfPermitted();
    }
  }

  Future<void> _initCameraIfPermitted() async {
    final status = await ref.read(cameraAccessProvider).status();
    if (status == CameraAccessStatus.granted && mounted) {
      await _setupCamera();
    }
  }

  Future<void> _setupCamera() async {
    if (_isCameraInitializing || _controller != null) return;
    setState(() {
      _isCameraInitializing = true;
      _cameraError = null;
    });

    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        if (mounted) {
          setState(() {
            _cameraError = AppStrings.cameraUnavailableBody;
            _isCameraInitializing = false;
          });
        }
        return;
      }

      final camera = _availableCameras[_selectedCameraIndex];
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      if (mounted) {
        setState(() {
          _controller = controller;
          _isCameraInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraError = e.toString();
          _isCameraInitializing = false;
        });
      }
    }
  }

  Future<void> _flipCamera() async {
    if (_availableCameras.length < 2) return;
    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _availableCameras.length;
    await _controller?.dispose();
    _controller = null;
    await _setupCamera();
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final nextMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await controller.setFlashMode(nextMode);
      if (mounted) {
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
      }
    } catch (_) {}
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final file = await controller.takePicture();
      if (mounted) {
        _onPhotoAcquired(file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final photoSource = ref.read(photoSourceProvider);
    final path = await photoSource.pickFromGallery();
    if (path != null && mounted) {
      _onPhotoAcquired(path);
    }
  }

  void _onPhotoAcquired(String path) {
    HapticFeedback.lightImpact();
    ref.read(scanProvider.notifier).scan(path);
    context.push('/result');
  }

  @override
  Widget build(BuildContext context) {
    final permAsync = ref.watch(cameraPermissionProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: permAsync.when(
        loading: () => _buildCameraSkeleton(),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 52,
                  color: Colors.white70,
                ),
                const SizedBox(height: AppDimens.s12),
                const Text(
                  'Kamera belum siap digunakan. Coba lagi atau pilih foto dari galeri.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: AppDimens.s16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(cameraPermissionProvider),
                  child: const Text(AppStrings.cameraRetry),
                ),
              ],
            ),
          ),
        ),
        data: (status) {
          return switch (status) {
            CameraAccessStatus.granted => _buildCameraView(),
            CameraAccessStatus.denied => _buildPermissionDeniedView(
              isPermanent: false,
            ),
            CameraAccessStatus.permanentlyDenied => _buildPermissionDeniedView(
              isPermanent: true,
            ),
          };
        },
      ),
    );
  }

  Widget _buildCameraSkeleton() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimens.rHero),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.center_focus_weak_rounded,
                size: 48,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: AppDimens.s16),
            const Text(
              'Menyiapkan kamera…',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    if (_isCameraInitializing) {
      return _buildCameraSkeleton();
    }

    if (_cameraError != null || _controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.videocam_off_rounded,
                size: 56,
                color: Colors.white70,
              ),
              const SizedBox(height: AppDimens.s16),
              Text(
                AppStrings.cameraUnavailableTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                AppStrings.cameraUnavailableBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppDimens.s20),
              PrimaryButton(
                text: AppStrings.pickFromGallery,
                icon: Icons.photo_library_rounded,
                fullWidth: false,
                onPressed: _pickFromGallery,
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // 1. Camera Preview
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.previewSize?.height ?? 100,
              height: _controller!.value.previewSize?.width ?? 100,
              child: CameraPreview(_controller!),
            ),
          ),
        ),

        // 2. Bar Atas: Tutup, Pil tengah "Arahkan ke buah", Flash
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.s16,
              vertical: AppDimens.s8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s16,
                    vertical: AppDimens.s8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppDimens.rPill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Arahkan ke buah',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _toggleFlash,
                  icon: Icon(
                    _isFlashOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    color: _isFlashOn ? harvest.accent : Colors.white,
                    size: 22,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Bingkai Fokus 220dp dengan 4 sudut siku tebal 4px accent & garis pindai
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  children: [
                    // 4 Sudut Siku
                    CustomPaint(
                      size: const Size(220, 220),
                      painter: _ScannerCornerPainter(
                        cornerColor: harvest.accent,
                        strokeWidth: 4,
                        cornerLength: 26,
                      ),
                    ),
                    // Garis horizontal beranimasi naik-turun (2.2s easeInOut)
                    AnimatedBuilder(
                      animation: _scanLineAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: _scanLineAnimation.value * 216,
                          left: 12,
                          right: 12,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: harvest.accent,
                              borderRadius: BorderRadius.circular(
                                AppDimens.rPill,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: harvest.accent.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.s16),
              // Pil info di bawah bingkai
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s16,
                  vertical: AppDimens.s4 + 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppDimens.rPill),
                ),
                child: Text(
                  'Pastikan pencahayaan cukup',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. Bar Kontrol Bawah
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.s32,
                AppDimens.s16,
                AppDimens.s32,
                AppDimens.s24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Galeri (Touch target >= 48dp)
                  Semantics(
                    button: true,
                    label: AppStrings.pickFromGallery,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _pickFromGallery,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_library_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Tombol Shutter (Luar 66dp putih, Dalam 50dp accent/primary)
                  Semantics(
                    button: true,
                    label: AppStrings.shutterLabel,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _takePicture,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3.5),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: harvest.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: harvest.onAccent,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Tombol Balik Kamera (Touch target >= 48dp)
                  Semantics(
                    button: true,
                    label: 'Balik kamera',
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _flipCamera,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.flip_camera_ios_outlined,
                            color: Colors.white,
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
        ),
      ],
    );
  }

  Widget _buildPermissionDeniedView({required bool isPermanent}) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_photography_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppDimens.s16),
            Text(
              isPermanent
                  ? 'Izin kamera dimatikan'
                  : AppStrings.cameraPermissionTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimens.s8),
            Text(
              isPermanent
                  ? AppStrings.cameraPermanentlyDeniedBody
                  : AppStrings.cameraPermissionBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: harvest.muted),
            ),
            const SizedBox(height: AppDimens.s20),
            PrimaryButton(
              text: isPermanent
                  ? AppStrings.cameraOpenSettings
                  : AppStrings.cameraAllow,
              fullWidth: false,
              onPressed: () {
                if (isPermanent) {
                  ref.read(cameraAccessProvider).openSettings();
                } else {
                  ref.read(cameraPermissionProvider.notifier).request();
                }
              },
            ),
            const SizedBox(height: AppDimens.s12),
            TextButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(
                Icons.photo_library_rounded,
                color: Colors.white,
              ),
              label: const Text(
                AppStrings.pickFromGallery,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerCornerPainter extends CustomPainter {
  const _ScannerCornerPainter({
    required this.cornerColor,
    required this.strokeWidth,
    required this.cornerLength,
  });

  final Color cornerColor;
  final double strokeWidth;
  final double cornerLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cornerColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final l = cornerLength;

    // Top Left
    canvas.drawLine(const Offset(0, 0), Offset(l, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, l), paint);

    // Top Right
    canvas.drawLine(Offset(w, 0), Offset(w - l, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, l), paint);

    // Bottom Left
    canvas.drawLine(Offset(0, h), Offset(l, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - l), paint);

    // Bottom Right
    canvas.drawLine(Offset(w, h), Offset(w - l, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - l), paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerCornerPainter oldDelegate) =>
      oldDelegate.cornerColor != cornerColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.cornerLength != cornerLength;
}
