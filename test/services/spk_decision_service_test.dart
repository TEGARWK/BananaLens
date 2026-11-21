import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/recipe.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/services/recipe_gating_service.dart';
import 'package:fruitlens/services/spk_decision_service.dart';

void main() {
  late SpkDecisionService spk;

  setUpAll(() {
    final jsonStr = File(
      'assets/models/spk_pso_rf_model.json',
    ).readAsStringSync();
    spk = SpkDecisionService.fromJsonString(jsonStr);
  });

  group('SpkDecisionService (26-tree PSO-RF)', () {
    test('loads all 26 trees and 4 decision classes', () {
      expect(spk.treeCount, 26);
      expect(spk.decisionClasses.length, 4);
      expect(spk.decisionClasses.map((c) => c.id).toList(), [0, 1, 2, 3]);
    });

    test('matches Python Random Forest scores within 1e-5', () {
      final cases =
          <({List<double> features, int expectedId, List<double> scores})>[
            (
              features: [85.0, 12.0, 1.0, 2.0, 0.80, 0.05, 0.0, 0.0],
              expectedId: 0,
              scores: [0.723516, 0.06983, 0.187607, 0.019048],
            ),
            (
              features: [85.0, 12.0, 1.0, 2.0, 0.80, 0.05, 2.0, 1.0],
              expectedId: 0,
              scores: [0.712943, 0.064835, 0.192307, 0.029915],
            ),
            (
              features: [1.0, 93.0, 4.0, 2.0, 0.02, 0.03, 0.0, 0.0],
              expectedId: 1,
              scores: [0.0, 0.961538, 0.024038, 0.014423],
            ),
            (
              features: [1.0, 15.0, 78.0, 6.0, 0.01, 0.25, 0.0, 2.0],
              expectedId: 2,
              scores: [0.0, 0.009615, 0.905792, 0.084593],
            ),
            (
              features: [0.5, 2.5, 5.0, 92.0, 0.01, 0.75, 0.0, 0.0],
              expectedId: 3,
              scores: [0.0, 0.0, 0.061432, 0.938568],
            ),
          ];

      for (final c in cases) {
        final res = spk.evaluateRaw(c.features);
        expect(res.decisionClass.id, c.expectedId);
        for (int i = 0; i < 4; i++) {
          expect(res.classScores[i], closeTo(c.scores[i], 1e-5));
        }
      }
    });

    test(
      'evaluateFromScan scales 0-1 probabilities to 0-100 and keeps pigment ratios',
      () {
        const outcome = ScanSuccess(
          fruitLabel: 'banana',
          ripenessLabel: 'ripe',
          fruitConfidence: 0.95,
          ripenessConfidence: 0.93,
          classProbabilities: {
            'unripe': 0.01,
            'ripe': 0.93,
            'overripe': 0.04,
            'rotten': 0.02,
          },
          greenRatio: 0.02,
          brownDarkRatio: 0.03,
        );

        final res = spk.evaluateFromScan(
          outcome,
          targetDays: SpkTargetDays.today,
          usageGoal: SpkUsageGoal.freshConsumption,
        );

        expect(res.featureVector, [1.0, 93.0, 4.0, 2.0, 0.02, 0.03, 0.0, 0.0]);
        expect(res.decisionClass.id, 1);
        expect(res.confidence, closeTo(0.961538, 1e-5));
      },
    );
  });

  group('RecipeGatingService.resolveSpkActionPlan', () {
    test('enforces food-safety discard on rotten scans', () {
      const rottenOutcome = ScanSuccess(
        fruitLabel: 'banana',
        ripenessLabel: 'rotten',
        fruitConfidence: 0.95,
        ripenessConfidence: 0.92,
        classProbabilities: {
          'unripe': 0.005,
          'ripe': 0.025,
          'overripe': 0.05,
          'rotten': 0.92,
        },
        greenRatio: 0.01,
        brownDarkRatio: 0.75,
      );

      final plan = RecipeGatingService.resolveSpkActionPlan(
        outcome: rottenOutcome,
        spkService: spk,
        targetDays: SpkTargetDays.today,
        usageGoal: SpkUsageGoal.culinaryProcessing,
      );

      expect(plan.isDiscard, isTrue);
      expect(plan.decision.id, 3);
      expect(plan.recipeBucket, isNull);
    });

    test(
      'maps class 1 to ripe bucket and class 2 (overripe) to veryRipe bucket',
      () {
        const ripeOutcome = ScanSuccess(
          fruitLabel: 'banana',
          ripenessLabel: 'ripe',
          fruitConfidence: 0.95,
          ripenessConfidence: 0.93,
          classProbabilities: {
            'unripe': 0.01,
            'ripe': 0.93,
            'overripe': 0.04,
            'rotten': 0.02,
          },
          greenRatio: 0.02,
          brownDarkRatio: 0.03,
        );
        final ripePlan = RecipeGatingService.resolveSpkActionPlan(
          outcome: ripeOutcome,
          spkService: spk,
          targetDays: SpkTargetDays.today,
          usageGoal: SpkUsageGoal.freshConsumption,
        );
        expect(ripePlan.decision.id, 1);
        expect(ripePlan.recipeBucket, RipenessBucket.ripe);

        const overripeOutcome = ScanSuccess(
          fruitLabel: 'banana',
          ripenessLabel: 'overripe',
          fruitConfidence: 0.94,
          ripenessConfidence: 0.78,
          classProbabilities: {
            'unripe': 0.01,
            'ripe': 0.15,
            'overripe': 0.78,
            'rotten': 0.06,
          },
          greenRatio: 0.01,
          brownDarkRatio: 0.25,
        );
        final overripePlan = RecipeGatingService.resolveSpkActionPlan(
          outcome: overripeOutcome,
          spkService: spk,
          targetDays: SpkTargetDays.today,
          usageGoal: SpkUsageGoal.culinaryProcessing,
        );
        expect(overripePlan.decision.id, 2);
        expect(overripePlan.recipeBucket, RipenessBucket.veryRipe);
      },
    );
  });
}
