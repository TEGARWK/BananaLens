import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Pigment coverage ratios inside the center-cropped fruit region.
class PigmentRatios {
  const PigmentRatios({
    required this.greenRatio,
    required this.yellowRatio,
    required this.brownDarkRatio,
    required this.activePixelCount,
    this.nonBananaVividRatio = 0.0,
  });

  const PigmentRatios.empty()
    : greenRatio = 0.0,
      yellowRatio = 0.0,
      brownDarkRatio = 0.0,
      activePixelCount = 0,
      nonBananaVividRatio = 0.0;

  final double greenRatio;
  final double yellowRatio;
  final double brownDarkRatio;
  final int activePixelCount;

  /// Ratio of vivid red/orange/pink/purple pixels unlikely to be any banana stage.
  final double nonBananaVividRatio;
}

/// Preprocessed image payload ready for MobileNetV3 TFLite + Masked HSV extraction.
class PreprocessedImageData {
  const PreprocessedImageData({
    required this.cnnInputTensor,
    required this.hsvFeatures,
    this.pigmentRatios = const PigmentRatios.empty(),
  });

  /// Flattened `[224 * 224 * 3]` float32 RGB values in `[0.0, 255.0]` matching MobileNetV3Small.
  final Float32List cnnInputTensor;

  /// 30-dim weighted HSV histogram + moments vector matching the Python training pipeline.
  final Float32List hsvFeatures;

  /// Explicit chlorophyll/yellow/brown pixel ratios for post-SVM color calibration.
  final PigmentRatios pigmentRatios;
}

/// Pure-Dart image preprocessing matching OpenCV & PIL Colab preprocessing.
abstract final class OnDeviceImagePreprocessor {
  static const int inputSize = 224;
  static const double cropMarginRatio = 0.12;

  /// Decodes raw file bytes, applies EXIF orientation, resizes to 224x224,
  /// and extracts both CNN float32 tensor and masked 30-dim HSV vector.
  static PreprocessedImageData processImageBytes(
    Uint8List imageBytes, {
    double hsvWeight = 2.5,
  }) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw const FormatException(
        'Foto tidak bisa dibuka. Coba pilih atau ambil foto lain.',
      );
    }

    final oriented = img.bakeOrientation(decoded);
    final interpolation =
        (oriented.width > inputSize * 1.5 || oriented.height > inputSize * 1.5)
        ? img.Interpolation.average
        : img.Interpolation.linear;
    final resized = img.copyResize(
      oriented,
      width: inputSize,
      height: inputSize,
      interpolation: interpolation,
    );
    final rgbImage =
        (resized.numChannels == 3 && resized.format == img.Format.uint8)
        ? resized
        : resized.convert(format: img.Format.uint8, numChannels: 3);

    final rgbBytes = Uint8List(inputSize * inputSize * 3);
    final cnnInput = Float32List(inputSize * inputSize * 3);

    int idx = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = rgbImage.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        rgbBytes[idx] = r;
        rgbBytes[idx + 1] = g;
        rgbBytes[idx + 2] = b;
        cnnInput[idx] = r.toDouble();
        cnnInput[idx + 1] = g.toDouble();
        cnnInput[idx + 2] = b.toDouble();
        idx += 3;
      }
    }

    final hsvFeatures = extractMaskedHsvFeatures(
      rgbBytes,
      width: inputSize,
      height: inputSize,
      hsvWeight: hsvWeight,
    );
    final pigmentRatios = analyzePigmentRatios(
      rgbBytes,
      width: inputSize,
      height: inputSize,
    );

    return PreprocessedImageData(
      cnnInputTensor: cnnInput,
      hsvFeatures: hsvFeatures,
      pigmentRatios: pigmentRatios,
    );
  }

  /// Scans the center-cropped 224x224 region and separates fruit pixels from
  /// neutral backgrounds (`S >= 28` and `V >= 20`) to measure chlorophyll green
  /// dominance (`Hue 31..88` OpenCV scale and `G > R + 5`).
  static PigmentRatios analyzePigmentRatios(
    Uint8List rgbBytes, {
    int width = inputSize,
    int height = inputSize,
  }) {
    final mh = (height * cropMarginRatio).toInt();
    final mw = (width * cropMarginRatio).toInt();
    final startY = mh;
    final endY = height - mh;
    final startX = mw;
    final endX = width - mw;

    int activeCount = 0;
    int greenCount = 0;
    int yellowCount = 0;
    int brownDarkCount = 0;
    int nonBananaVividCount = 0;

    for (int y = startY; y < endY; y++) {
      for (int x = startX; x < endX; x++) {
        final p = (y * width + x) * 3;
        final r = rgbBytes[p];
        final g = rgbBytes[p + 1];
        final b = rgbBytes[p + 2];
        final (h, s, v) = rgbToOpenCvHsv(r, g, b);

        // Ignore white paper, grey floors, or dark shadows outside fruit pigment.
        if (s < 28 || v < 20) continue;

        activeCount++;
        final isVividRedOrange = (h <= 15 || h >= 165) && s >= 140 && v >= 145;
        final isPurpleMagenta = h >= 125 && h <= 164 && s >= 45 && v >= 20;
        final isVividBlue = h >= 100 && h < 125 && s >= 100 && v >= 60;
        if (isVividRedOrange || isPurpleMagenta || isVividBlue) {
          nonBananaVividCount++;
        }

        if (h >= 31 && h <= 88 && g > r + 5) {
          greenCount++;
        } else if (h >= 16 && h <= 30 && v >= 90) {
          yellowCount++;
        } else if (h < 16 || v < 90) {
          brownDarkCount++;
        }
      }
    }

    if (activeCount == 0) {
      return const PigmentRatios.empty();
    }

    return PigmentRatios(
      greenRatio: greenCount / activeCount,
      yellowRatio: yellowCount / activeCount,
      brownDarkRatio: brownDarkCount / activeCount,
      activePixelCount: activeCount,
      nonBananaVividRatio: nonBananaVividCount / activeCount,
    );
  }

  /// Extracts 30 HSV features with 12% center-crop and banana-spectrum masking:
  /// Hue [0..85], Saturation [28..255], Value [20..255] (OpenCV HSV scale).
  static Float32List extractMaskedHsvFeatures(
    Uint8List rgbBytes, {
    int width = inputSize,
    int height = inputSize,
    double hsvWeight = 2.5,
  }) {
    final mh = (height * cropMarginRatio).toInt();
    final mw = (width * cropMarginRatio).toInt();
    final startY = mh;
    final endY = height - mh;
    final startX = mw;
    final endX = width - mw;

    final croppedCount = (endY - startY) * (endX - startX);
    final hVals = Uint8List(croppedCount);
    final sVals = Uint8List(croppedCount);
    final vVals = Uint8List(croppedCount);
    final maskFlags = Uint8List(croppedCount);

    int maskCount = 0;
    int cIdx = 0;
    for (int y = startY; y < endY; y++) {
      for (int x = startX; x < endX; x++) {
        final p = (y * width + x) * 3;
        final (h, s, v) = rgbToOpenCvHsv(
          rgbBytes[p],
          rgbBytes[p + 1],
          rgbBytes[p + 2],
        );
        hVals[cIdx] = h;
        sVals[cIdx] = s;
        vVals[cIdx] = v;
        if (h <= 85 && s >= 28 && v >= 20) {
          maskFlags[cIdx] = 1;
          maskCount++;
        }
        cIdx++;
      }
    }

    final useMask = maskCount >= 50;
    final hHist = Float64List(12);
    final sHist = Float64List(6);
    final vHist = Float64List(6);

    double sumH = 0, sumS = 0, sumV = 0;
    double sqH = 0, sqS = 0, sqV = 0;
    int activeCount = 0;

    for (int i = 0; i < croppedCount; i++) {
      if (useMask && maskFlags[i] == 0) continue;

      final h = hVals[i];
      final s = sVals[i];
      final v = vVals[i];

      if (h < 90) {
        final hBin = (h * 12) ~/ 90;
        if (hBin >= 0 && hBin < 12) {
          hHist[hBin] += 1.0;
        }
      }
      sHist[(s * 6) ~/ 256] += 1.0;
      vHist[(v * 6) ~/ 256] += 1.0;

      sumH += h;
      sumS += s;
      sumV += v;
      sqH += h * h;
      sqS += s * s;
      sqV += v * v;
      activeCount++;
    }

    _normalizeInPlace(hHist);
    _normalizeInPlace(sHist);
    _normalizeInPlace(vHist);

    final denom = activeCount > 0 ? activeCount.toDouble() : 1.0;
    final meanH = sumH / denom;
    final meanS = sumS / denom;
    final meanV = sumV / denom;

    final stdH = math.sqrt(math.max(0.0, (sqH / denom) - meanH * meanH));
    final stdS = math.sqrt(math.max(0.0, (sqS / denom) - meanS * meanS));
    final stdV = math.sqrt(math.max(0.0, (sqV / denom) - meanV * meanV));

    final result = Float32List(30);
    int out = 0;
    for (int i = 0; i < 12; i++) {
      result[out++] = (hHist[i] * hsvWeight).toDouble();
    }
    for (int i = 0; i < 6; i++) {
      result[out++] = (sHist[i] * hsvWeight).toDouble();
    }
    for (int i = 0; i < 6; i++) {
      result[out++] = (vHist[i] * hsvWeight).toDouble();
    }
    result[out++] = (meanH / 255.0) * hsvWeight;
    result[out++] = (meanS / 255.0) * hsvWeight;
    result[out++] = (meanV / 255.0) * hsvWeight;
    result[out++] = (stdH / 255.0) * hsvWeight;
    result[out++] = (stdS / 255.0) * hsvWeight;
    result[out++] = (stdV / 255.0) * hsvWeight;

    return result;
  }

  /// Converts 8-bit RGB to OpenCV-compatible uint8 HSV (`H: 0..179`, `S: 0..255`, `V: 0..255`).
  static (int, int, int) rgbToOpenCvHsv(int r, int g, int b) {
    final vmax = math.max(r, math.max(g, b));
    final vmin = math.min(r, math.min(g, b));
    final diff = vmax - vmin;

    final v = vmax;
    final s = vmax == 0 ? 0 : ((255.0 * diff) / vmax).round().clamp(0, 255);

    double hDeg;
    if (diff == 0) {
      hDeg = 0.0;
    } else if (vmax == r) {
      hDeg = 60.0 * (g - b) / diff;
    } else if (vmax == g) {
      hDeg = 120.0 + 60.0 * (b - r) / diff;
    } else {
      hDeg = 240.0 + 60.0 * (r - g) / diff;
    }
    if (hDeg < 0) hDeg += 360.0;
    int h = (hDeg / 2.0).round();
    if (h >= 180) h = 0;

    return (h, s, v);
  }

  static void _normalizeInPlace(Float64List hist) {
    double sum = 0.0;
    for (int i = 0; i < hist.length; i++) {
      sum += hist[i];
    }
    final denom = sum + 1e-7;
    for (int i = 0; i < hist.length; i++) {
      hist[i] /= denom;
    }
  }
}
