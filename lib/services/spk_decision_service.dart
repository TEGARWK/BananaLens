import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/models/scan_outcome.dart';

/// User's intended storage / consumption timeframe (`target_days` SPK feature).
enum SpkTargetDays {
  today(0, 'Hari ini'),
  twoToThreeDays(1, '2–3 hari'),
  moreThanFourDays(2, '> 4 hari');

  const SpkTargetDays(this.code, this.labelId);
  final int code;
  final String labelId;
}

/// User's intended usage goal (`usage_goal` SPK feature).
enum SpkUsageGoal {
  freshConsumption(0, 'Konsumsi'),
  retailDistribution(1, 'Jual'),
  culinaryProcessing(2, 'Olahan');

  const SpkUsageGoal(this.code, this.labelId);
  final int code;
  final String labelId;
}

/// Metadata for one of the 4 SPK decision classes in `spk_pso_rf_model.json`.
class SpkDecisionClass {
  const SpkDecisionClass({
    required this.id,
    required this.title,
    required this.badge,
    required this.description,
    required this.actionTips,
  });

  factory SpkDecisionClass.fromJson(Map<String, dynamic> json) {
    return SpkDecisionClass(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      badge: json['badge'] as String,
      description: json['description'] as String,
      actionTips: json['action_tips'] as String,
    );
  }

  final int id;
  final String title;
  final String badge;
  final String description;
  final String actionTips;
}

/// Output of evaluating the 26 PSO-optimized Random Forest trees.
class SpkDecisionResult {
  const SpkDecisionResult({
    required this.decisionClass,
    required this.confidence,
    required this.classScores,
    required this.featureVector,
  });

  final SpkDecisionClass decisionClass;
  final double confidence;
  final List<double> classScores;
  final List<double> featureVector;
}

class _SpkTreeNode {
  const _SpkTreeNode({
    required this.feature,
    required this.threshold,
    required this.left,
    required this.right,
    required this.isLeaf,
    required this.probs,
  });

  factory _SpkTreeNode.fromJson(Map<String, dynamic> json) {
    return _SpkTreeNode(
      feature: (json['feature'] as num).toInt(),
      threshold: (json['threshold'] as num).toDouble(),
      left: (json['left'] as num).toInt(),
      right: (json['right'] as num).toInt(),
      isLeaf: json['is_leaf'] as bool,
      probs: (json['probs'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(growable: false),
    );
  }

  final int feature;
  final double threshold;
  final int left;
  final int right;
  final bool isLeaf;
  final List<double> probs;
}

/// Offline Decision Support System (SPK) powered by a PSO-optimized Random Forest
/// exported from scikit-learn (`spk_pso_rf_model.json`, 26 trees, 8 input features).
class SpkDecisionService {
  SpkDecisionService._({
    required this.decisionClasses,
    required List<List<_SpkTreeNode>> trees,
  }) : _trees = trees;

  static const String defaultAssetPath = 'assets/models/spk_pso_rf_model.json';

  final List<SpkDecisionClass> decisionClasses;
  final List<List<_SpkTreeNode>> _trees;

  int get treeCount => _trees.length;

  /// Parses `spk_pso_rf_model.json` contents into memory.
  factory SpkDecisionService.fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final classes = (map['decision_classes'] as List<dynamic>)
        .map((e) => SpkDecisionClass.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    final trees = (map['trees'] as List<dynamic>)
        .map(
          (tree) => (tree as List<dynamic>)
              .map((n) => _SpkTreeNode.fromJson(n as Map<String, dynamic>))
              .toList(growable: false),
        )
        .toList(growable: false);
    if (classes.isEmpty || trees.isEmpty) {
      throw const FormatException('Model SPK kosong atau tidak valid.');
    }
    return SpkDecisionService._(decisionClasses: classes, trees: trees);
  }

  /// Loads `spk_pso_rf_model.json` from Flutter assets.
  static Future<SpkDecisionService> loadFromAssets({
    String assetPath = defaultAssetPath,
    Future<String> Function(String key)? loadString,
  }) async {
    final loader = loadString ?? rootBundle.loadString;
    final raw = await loader(assetPath);
    return SpkDecisionService.fromJsonString(raw);
  }

  /// Evaluates a [ScanSuccess] together with user context (`targetDays`, `usageGoal`).
  /// SVM probabilities (`0.0–1.0`) are scaled to `0.0–100.0` as trained; pigment
  /// ratios remain in `0.0–1.0`.
  SpkDecisionResult evaluateFromScan(
    ScanSuccess outcome, {
    SpkTargetDays targetDays = SpkTargetDays.today,
    SpkUsageGoal usageGoal = SpkUsageGoal.freshConsumption,
  }) {
    final probs = outcome.classProbabilities;
    double probOf(String key) {
      if (probs != null && probs.containsKey(key)) {
        return (probs[key] ?? 0.0).clamp(0.0, 1.0) * 100.0;
      }
      final label = outcome.ripenessLabel.trim().toLowerCase();
      return label == key ? outcome.ripenessConfidence * 100.0 : 0.0;
    }

    final features = <double>[
      probOf('unripe'),
      probOf('ripe'),
      probOf('overripe'),
      probOf('rotten'),
      (outcome.greenRatio ?? 0.0).clamp(0.0, 1.0),
      (outcome.brownDarkRatio ?? 0.0).clamp(0.0, 1.0),
      targetDays.code.toDouble(),
      usageGoal.code.toDouble(),
    ];
    return evaluateRaw(features);
  }

  /// Evaluates the exact 8-feature vector `[prob_unripe, prob_ripe, prob_overripe,
  /// prob_rotten, green_ratio, brown_dark_ratio, target_days, usage_goal]`.
  SpkDecisionResult evaluateRaw(List<double> features) {
    if (features.length != 8) {
      throw ArgumentError.value(
        features.length,
        'features',
        'Model SPK membutuhkan tepat 8 fitur input.',
      );
    }

    final numClasses = decisionClasses.length;
    final scoreSums = List<double>.filled(numClasses, 0.0);

    for (final tree in _trees) {
      int nodeIdx = 0;
      while (true) {
        final node = tree[nodeIdx];
        if (node.isLeaf) {
          for (int c = 0; c < numClasses; c++) {
            scoreSums[c] += node.probs[c];
          }
          break;
        }
        final goLeft = features[node.feature] <= node.threshold;
        nodeIdx = goLeft ? node.left : node.right;
      }
    }

    final averaged = List<double>.generate(
      numClasses,
      (c) => scoreSums[c] / _trees.length,
      growable: false,
    );

    int bestIdx = 0;
    double bestScore = averaged[0];
    for (int c = 1; c < numClasses; c++) {
      if (averaged[c] > bestScore) {
        bestScore = averaged[c];
        bestIdx = c;
      }
    }

    return SpkDecisionResult(
      decisionClass: decisionClasses[bestIdx],
      confidence: bestScore.clamp(0.0, 1.0),
      classScores: averaged,
      featureVector: List<double>.unmodifiable(features),
    );
  }
}
