import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/services/ml_kit_fruit_detector.dart';
import 'package:fruitlens/services/on_device_banana_gate.dart';
import 'package:fruitlens/services/on_device_image_preprocessor.dart';
import 'package:fruitlens/services/on_device_scan_service.dart';
import 'package:fruitlens/services/on_device_svm_classifier.dart';
import 'package:image/image.dart' as img;

class _FakeValidator implements FruitObjectValidator {
  _FakeValidator(this._result);

  final FruitValidationResult _result;

  @override
  Future<FruitValidationResult> validate(String imagePath) async => _result;

  @override
  Future<void> dispose() async {}
}

class _FakeBananaGate implements BananaGate {
  _FakeBananaGate(this._result);

  final BananaGateResult _result;

  @override
  Future<BananaGateResult> checkBanana(Uint8List rgb224Bytes) async => _result;

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MlKitFruitValidator', () {
    test('accepts banana and fruit labels with high fruitConfidence', () {
      final result = MlKitFruitValidator.evaluateLabels([
        (label: 'Food', confidence: 0.91),
        (label: 'Banana', confidence: 0.87),
        (label: 'Yellow', confidence: 0.72),
      ]);

      expect(result.isLikelyFruitOrFood, isTrue);
      expect(result.detectedFruitType, 'banana');
      expect(result.fruitConfidence, closeTo(0.87, 0.001));
    });

    test(
      'rejects high-confidence non-fruit object when no food/fruit clue',
      () {
        final result = MlKitFruitValidator.evaluateLabels([
          (label: 'Laptop', confidence: 0.88),
          (label: 'Keyboard', confidence: 0.79),
        ]);

        expect(result.isLikelyFruitOrFood, isFalse);
        expect(result.rejectionReason, contains('Laptop'));
      },
    );

    test('passes through gracefully when label list is empty', () {
      final result = MlKitFruitValidator.evaluateLabels(const []);

      expect(result.isLikelyFruitOrFood, isTrue);
      expect(result.detectedFruitType, 'banana');
    });

    test('accepts subtle fruit labels in 0.35..0.59 confidence range', () {
      final result = MlKitFruitValidator.evaluateLabels([
        (label: 'Food', confidence: 0.48),
        (label: 'Tire', confidence: 0.62),
      ]);

      expect(result.isLikelyFruitOrFood, isTrue);
      expect(result.fruitConfidence, closeTo(0.48, 0.001));
    });

    test('rejects non-banana fruits like orange, citrus, and mango', () {
      final orangeResult = MlKitFruitValidator.evaluateLabels([
        (label: 'Fruit', confidence: 0.92),
        (label: 'Citrus', confidence: 0.84),
        (label: 'Orange', confidence: 0.79),
      ]);
      expect(orangeResult.isLikelyFruitOrFood, isFalse);
      expect(orangeResult.rejectionReason, contains('Citrus'));

      final mangoResult = MlKitFruitValidator.evaluateLabels([
        (label: 'Food', confidence: 0.88),
        (label: 'Mango', confidence: 0.72),
      ]);
      expect(mangoResult.isLikelyFruitOrFood, isFalse);
      expect(mangoResult.rejectionReason, contains('Mango'));
    });

    test(
      'rejects person/selfie holding generic object without banana label',
      () {
        final selfieResult = MlKitFruitValidator.evaluateLabels([
          (label: 'Person', confidence: 0.91),
          (label: 'Smile', confidence: 0.82),
          (label: 'Food', confidence: 0.54),
        ]);
        expect(selfieResult.isLikelyFruitOrFood, isFalse);
        expect(selfieResult.rejectionReason, contains('Person'));
      },
    );

    test(
      'accepts banana bunch when ML Kit emits Shoe alongside Fruit/Food',
      () {
        final bunchResult = MlKitFruitValidator.evaluateLabels([
          (label: 'Shoe', confidence: 0.72),
          (label: 'Fruit', confidence: 0.68),
          (label: 'Food', confidence: 0.61),
        ]);
        expect(bunchResult.isLikelyFruitOrFood, isTrue);
        expect(bunchResult.detectedFruitType, 'banana');
      },
    );
  });

  group('TfliteImageNetBananaGate', () {
    test('accepts banana when class #954 has strong probability', () {
      final probs = List<double>.filled(1000, 0.0001);
      probs[954] = 0.72;
      final result = TfliteImageNetBananaGate.evaluateProbabilities(probs);

      expect(result.isBanana, isTrue);
      expect(result.bananaRank, 1);
      expect(result.topClassIndex, 954);
    });

    test('accepts rotten/dark banana when class #954 is within top-5', () {
      final probs = List<double>.filled(1000, 0.0001);
      probs[111] = 0.074;
      probs[112] = 0.060;
      probs[113] = 0.050;
      probs[114] = 0.040;
      probs[954] = 0.0352;
      final result = TfliteImageNetBananaGate.evaluateProbabilities(probs);

      expect(result.isBanana, isTrue);
      expect(result.bananaRank, 5);
    });

    test(
      'rejects avocado when banana is weak top-5 compared to dominant top-1 class',
      () {
        final probs = List<double>.filled(1000, 0.0001);
        probs[941] = 0.379; // acorn squash / avocado look-alike
        probs[940] = 0.120;
        probs[942] = 0.090;
        probs[943] = 0.040;
        probs[954] = 0.0273; // banana rank 5 but only 7.2% of top-1
        final result = TfliteImageNetBananaGate.evaluateProbabilities(probs);

        expect(result.isBanana, isFalse);
        expect(result.bananaRank, 5);
        expect(result.topClassIndex, 941);
      },
    );

    test('rejects mango/avocado when banana probability is negligible', () {
      final probs = List<double>.filled(1000, 0.0001);
      probs[950] = 0.65; // orange / other fruit
      probs[951] = 0.18; // lemon
      probs[956] = 0.08; // custard apple
      probs[954] = 0.0005; // banana
      final result = TfliteImageNetBananaGate.evaluateProbabilities(probs);

      expect(result.isBanana, isFalse);
      expect(result.topClassIndex, 950);
    });
  });

  group('OnDeviceImagePreprocessor', () {
    test(
      'rgbToOpenCvHsv converts primary and banana colors identically to OpenCV',
      () {
        // Pure green (unripe banana spectrum): Hue_deg = 120 -> OpenCV H = 60, S = 255, V = 255
        expect(OnDeviceImagePreprocessor.rgbToOpenCvHsv(0, 255, 0), (
          60,
          255,
          255,
        ));
        // Pure yellow (ripe banana spectrum): Hue_deg = 60 -> OpenCV H = 30, S = 255, V = 255
        expect(OnDeviceImagePreprocessor.rgbToOpenCvHsv(255, 255, 0), (
          30,
          255,
          255,
        ));
        // Pure blue (outside banana mask Hue 0-85): Hue_deg = 240 -> OpenCV H = 120
        expect(OnDeviceImagePreprocessor.rgbToOpenCvHsv(0, 0, 255), (
          120,
          255,
          255,
        ));
        // Black & White
        expect(OnDeviceImagePreprocessor.rgbToOpenCvHsv(0, 0, 0), (0, 0, 0));
        expect(OnDeviceImagePreprocessor.rgbToOpenCvHsv(255, 255, 255), (
          0,
          0,
          255,
        ));
      },
    );

    test(
      'extracts expected 30-dim HSV and 150528-dim CNN tensor on test photo',
      () async {
        final testPng = File(
          'baca/foto_uji/05_hitam_latar_putih_2254_busuk.png',
        );
        final bytes = await testPng.readAsBytes();
        final processed = OnDeviceImagePreprocessor.processImageBytes(
          bytes,
          hsvWeight: 2.5,
        );

        expect(processed.cnnInputTensor.length, 224 * 224 * 3);
        expect(processed.hsvFeatures.length, 30);

        // Compare closely against Python OpenCV calcHist + meanStdDev + 4 pigment ratios:
        // 12 Hue [0..12) + 5 Sat [12..17) + 5 Val [17..22) + 2 Mean + 2 Std + 4 Pigment Ratios [26..30).
        final sumH = processed.hsvFeatures
            .sublist(0, 12)
            .reduce((a, b) => a + b);
        final sumS = processed.hsvFeatures
            .sublist(12, 17)
            .reduce((a, b) => a + b);
        final sumV = processed.hsvFeatures
            .sublist(17, 22)
            .reduce((a, b) => a + b);
        final sumPigments = processed.hsvFeatures
            .sublist(26, 30)
            .reduce((a, b) => a + b);
        expect(sumH, closeTo(2.5, 0.05));
        expect(sumS, closeTo(2.5, 0.01));
        expect(sumV, closeTo(2.5, 0.01));
        // Slight overlap at H in 31..85 and V in 40..59 matches Python Sel 3 (`sum ~ 2.50-2.55`).
        expect(sumPigments, closeTo(2.5, 0.05));
        expect(
          processed.hsvFeatures[1],
          greaterThan(0.5),
        ); // Dominant brown/low hue bin
      },
    );
  });

  group('OnDeviceSvmClassifier & OnDeviceScanService', () {
    late String metaJson;
    late Uint8List weightsBytes;

    setUpAll(() async {
      metaJson = await File(
        'assets/models/svm_pisang_meta.json',
      ).readAsString();
      weightsBytes = await File(
        'assets/models/svm_pisang_weights.bin',
      ).readAsBytes();
    });

    test(
      'loads real binary weights and computes calibrated 4-class probabilities',
      () {
        final classifier = OnDeviceSvmClassifier.fromAssets(
          metaJson: metaJson,
          weightsBytes: weightsBytes,
        );

        expect(classifier.classNames, ['overripe', 'ripe', 'rotten', 'unripe']);
        expect(classifier.hsvWeight, closeTo(2.5, 0.001));

        final zeroCnn = Float32List(576);
        final zeroHsv = Float32List(30);
        final pred = classifier.predict(zeroCnn, zeroHsv);

        expect(pred.probabilities.keys, {
          'overripe',
          'ripe',
          'rotten',
          'unripe',
        });
        final sumProbs = pred.probabilities.values.reduce((a, b) => a + b);
        expect(sumProbs, closeTo(1.0, 0.001));
        expect(pred.confidence, greaterThan(0.0));
        expect(pred.confidence, lessThanOrEqualTo(1.0));
      },
    );

    test(
      'end-to-end OnDeviceScanService returns ScanSuccess for banana photo',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'on_device_test_',
        );
        addTearDown(() async {
          if (await tempDir.exists()) await tempDir.delete(recursive: true);
        });

        final bananaImg = img.Image(width: 240, height: 240);
        img.fill(bananaImg, color: img.ColorRgb8(230, 200, 35));
        final imgFile = File('${tempDir.path}/ripe_banana.jpg');
        await imgFile.writeAsBytes(img.encodeJpg(bananaImg));

        final service = OnDeviceScanService(
          fruitValidator: _FakeValidator(
            const FruitValidationResult(
              isLikelyFruitOrFood: true,
              detectedLabels: ['Banana', 'Fruit'],
              detectedFruitType: 'banana',
              fruitConfidence: 0.92,
            ),
          ),
          extractCnnFeatures: (_) async => Float32List(576),
          loadString: (_) async => metaJson,
          loadBinary: (_) async => ByteData.sublistView(weightsBytes),
        );

        final outcome = await service.scan(imgFile.path);
        expect(outcome, isA<ScanSuccess>());
        final success = outcome as ScanSuccess;
        expect(success.fruitLabel, 'banana');
        expect(success.fruitConfidence, closeTo(0.92, 0.001));
        expect(success.classProbabilities, isNotNull);
        expect(success.classProbabilities!.keys, {
          'overripe',
          'ripe',
          'rotten',
          'unripe',
        });
      },
    );

    test(
      'OnDeviceScanService rejects out-of-distribution non-banana (low maxKernelSimilarity) as ScanUncertain',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('on_device_ood_');
        addTearDown(() async {
          if (await tempDir.exists()) await tempDir.delete(recursive: true);
        });

        final yellowMangoImg = img.Image(width: 240, height: 240);
        img.fill(yellowMangoImg, color: img.ColorRgb8(245, 200, 30));
        final imgFile = File('${tempDir.path}/mango.jpg');
        await imgFile.writeAsBytes(img.encodeJpg(yellowMangoImg));

        final oodCnn = Float32List.fromList(List<double>.filled(576, 5.0));
        final service = OnDeviceScanService(
          fruitValidator: _FakeValidator(
            const FruitValidationResult(
              isLikelyFruitOrFood: true,
              detectedLabels: ['Food', 'Fruit', 'Plant', 'Vegetable'],
              detectedFruitType: 'banana',
              fruitConfidence: 0.63,
            ),
          ),
          // Distant CNN feature vector produces very low maxSim (< 0.35).
          extractCnnFeatures: (_) async => oodCnn,
          loadString: (_) async => metaJson,
          loadBinary: (_) async => ByteData.sublistView(weightsBytes),
          minBananaKernelSimilarity: 0.35,
        );

        final outcome = await service.scan(imgFile.path);
        expect(outcome, isA<ScanUncertain>());
      },
    );

    test(
      'OnDeviceScanService rejects yellow non-banana (mango/avocado) when Stage-1 BananaGate returns false',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'on_device_gate_',
        );
        addTearDown(() async {
          if (await tempDir.exists()) await tempDir.delete(recursive: true);
        });

        final yellowImg = img.Image(width: 240, height: 240);
        img.fill(yellowImg, color: img.ColorRgb8(245, 210, 40));
        final imgFile = File('${tempDir.path}/mango_yellow.jpg');
        await imgFile.writeAsBytes(img.encodeJpg(yellowImg));

        bool stage2CnnCalled = false;
        final service = OnDeviceScanService(
          fruitValidator: _FakeValidator(
            const FruitValidationResult(
              isLikelyFruitOrFood: true,
              detectedLabels: ['Food', 'Fruit', 'Plant'],
              detectedFruitType: 'banana',
              fruitConfidence: 0.93,
            ),
          ),
          bananaGate: _FakeBananaGate(
            const BananaGateResult(
              isBanana: false,
              bananaProbability: 0.001,
              bananaRank: 85,
              topClassIndex: 951,
              topProbability: 0.78,
            ),
          ),
          extractCnnFeatures: (_) async {
            stage2CnnCalled = true;
            return Float32List(576);
          },
          loadString: (_) async => metaJson,
          loadBinary: (_) async => ByteData.sublistView(weightsBytes),
        );

        final outcome = await service.scan(imgFile.path);
        expect(outcome, isA<ScanUncertain>());
        expect(stage2CnnCalled, isFalse);
      },
    );

    test(
      'OnDeviceScanService returns ScanUncertain when ML Kit rejects non-fruit',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'on_device_reject_',
        );
        addTearDown(() async {
          if (await tempDir.exists()) await tempDir.delete(recursive: true);
        });

        final imgFile = File('${tempDir.path}/laptop.jpg');
        await imgFile.writeAsBytes([1, 2, 3, 4]);

        bool tfliteCalled = false;
        final service = OnDeviceScanService(
          fruitValidator: _FakeValidator(
            const FruitValidationResult(
              isLikelyFruitOrFood: false,
              detectedLabels: ['Laptop', 'Keyboard'],
              rejectionReason: 'Terdeteksi objek non-buah (Laptop)',
            ),
          ),
          extractCnnFeatures: (_) async {
            tfliteCalled = true;
            return Float32List(576);
          },
          loadString: (_) async => metaJson,
          loadBinary: (_) async => ByteData.sublistView(weightsBytes),
        );

        final outcome = await service.scan(imgFile.path);
        expect(outcome, isA<ScanUncertain>());
        expect(tfliteCalled, isFalse);
      },
    );

    test(
      'OnDeviceScanService returns ScanFailure when file does not exist',
      () async {
        final service = OnDeviceScanService(
          fruitValidator: _FakeValidator(
            const FruitValidationResult(
              isLikelyFruitOrFood: true,
              detectedLabels: [],
            ),
          ),
        );

        final outcome = await service.scan('/non/existent/file.jpg');
        expect(outcome, isA<ScanFailure>());
      },
    );

    test(
      'OnDeviceScanService rejects vivid orange/red fruit (e.g. orange, red apple) as ScanUncertain',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'on_device_orange_',
        );
        addTearDown(() async {
          if (await tempDir.exists()) await tempDir.delete(recursive: true);
        });

        final orangeImg = img.Image(width: 240, height: 240);
        img.fill(orangeImg, color: img.ColorRgb8(250, 120, 10));
        final imgFile = File('${tempDir.path}/orange.jpg');
        await imgFile.writeAsBytes(img.encodeJpg(orangeImg));

        final service = OnDeviceScanService(
          fruitValidator: _FakeValidator(
            const FruitValidationResult(
              isLikelyFruitOrFood: true,
              detectedLabels: ['Food', 'Fruit', 'Plant'],
              detectedFruitType: 'banana',
              fruitConfidence: 0.95,
            ),
          ),
          extractCnnFeatures: (_) async => Float32List(576),
          loadString: (_) async => metaJson,
          loadBinary: (_) async => ByteData.sublistView(weightsBytes),
        );

        final outcome = await service.scan(imgFile.path);
        expect(outcome, isA<ScanUncertain>());
      },
    );

    test(
      'analyzePigmentRatios isolates green unripe pixels from white background',
      () {
        final greenImg = img.Image(width: 224, height: 224);
        img.fill(greenImg, color: img.ColorRgb8(255, 255, 255));
        img.fillRect(
          greenImg,
          x1: 60,
          y1: 60,
          x2: 164,
          y2: 164,
          color: img.ColorRgb8(95, 165, 55),
        );
        final processed = OnDeviceImagePreprocessor.processImageBytes(
          Uint8List.fromList(img.encodePng(greenImg)),
        );

        expect(processed.pigmentRatios.greenRatio, greaterThan(0.90));
        expect(processed.pigmentRatios.yellowRatio, lessThan(0.05));
      },
    );

    test(
      'chlorophyll calibration boosts unripe when greenRatio >= 0.30 and keeps yellow untouched',
      () {
        final classifier = OnDeviceSvmClassifier.fromAssets(
          metaJson: metaJson,
          weightsBytes: weightsBytes,
        );
        final dummyCnn = Float32List(576);
        final dummyHsv = Float32List(30);

        final rawPred = classifier.predict(dummyCnn, dummyHsv);
        final yellowPred = classifier.predict(
          dummyCnn,
          dummyHsv,
          pigmentRatios: const PigmentRatios(
            greenRatio: 0.02,
            yellowRatio: 0.90,
            brownDarkRatio: 0.08,
            activePixelCount: 5000,
          ),
        );
        expect(
          yellowPred.probabilities['ripe'],
          closeTo(rawPred.probabilities['ripe']!, 1e-6),
        );

        final greenPred = classifier.predict(
          dummyCnn,
          dummyHsv,
          pigmentRatios: const PigmentRatios(
            greenRatio: 0.72,
            yellowRatio: 0.15,
            brownDarkRatio: 0.13,
            activePixelCount: 5000,
          ),
        );
        expect(greenPred.predictedClass, 'unripe');
        expect(
          greenPred.probabilities['unripe']!,
          greaterThan(greenPred.probabilities['ripe']!),
        );
        final totalProb = greenPred.probabilities.values.fold<double>(
          0.0,
          (a, b) => a + b,
        );
        expect(totalProb, closeTo(1.0, 1e-5));

        // High green chlorophyll with minor shadow/brown ratio should also
        // dampen false-positive `rotten` probabilities into `unripe`.
        final bunchPred = classifier.predict(
          dummyCnn,
          dummyHsv,
          pigmentRatios: const PigmentRatios(
            greenRatio: 0.62,
            yellowRatio: 0.10,
            brownDarkRatio: 0.18,
            activePixelCount: 5000,
          ),
        );
        expect(bunchPred.predictedClass, 'unripe');
        expect(
          bunchPred.probabilities['unripe']!,
          greaterThan(bunchPred.probabilities['rotten']!),
        );
        final bunchTotal = bunchPred.probabilities.values.fold<double>(
          0.0,
          (a, b) => a + b,
        );
        expect(bunchTotal, closeTo(1.0, 1e-5));

        // Yellow peel with sugar spots (`yellowRatio >= 0.50` & >= 1.6x brown)
        // shifts false `rotten` back to `ripe` (very_ripe), while truly dark
        // rotten peels (`brownDarkRatio >= yellowRatio`) stay `rotten`.
        final sugarSpotPred = classifier.predict(
          dummyCnn,
          dummyHsv,
          pigmentRatios: const PigmentRatios(
            greenRatio: 0.02,
            yellowRatio: 0.68,
            brownDarkRatio: 0.28,
            activePixelCount: 5000,
          ),
        );
        expect(sugarSpotPred.predictedClass, 'ripe');
        expect(
          sugarSpotPred.probabilities['ripe']!,
          greaterThan(sugarSpotPred.probabilities['rotten']!),
        );
        final sugarTotal = sugarSpotPred.probabilities.values.fold<double>(
          0.0,
          (a, b) => a + b,
        );
        expect(sugarTotal, closeTo(1.0, 1e-5));

        final trulyRottenPred = classifier.predict(
          dummyCnn,
          dummyHsv,
          pigmentRatios: const PigmentRatios(
            greenRatio: 0.0,
            yellowRatio: 0.25,
            brownDarkRatio: 0.70,
            activePixelCount: 5000,
          ),
        );
        expect(
          trulyRottenPred.probabilities['rotten'],
          closeTo(rawPred.probabilities['rotten']!, 1e-6),
        );
      },
    );
  });
}
