import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/services/spk_context_interpreter.dart';
import 'package:fruitlens/services/spk_decision_service.dart';

void main() {
  const dummyDecision = SpkDecisionClass(
    id: 1,
    title: 'Dummy',
    badge: 'Dummy',
    description: 'Dummy',
    actionTips: 'Dummy',
  );

  group('SpkContextInterpreter', () {
    test('produces 9 distinct headlines for all ripe combinations', () {
      final headlines = <String>{};
      for (final days in SpkTargetDays.values) {
        for (final goal in SpkUsageGoal.values) {
          final advice = SpkContextInterpreter.interpret(
            ripenessLabel: 'ripe',
            targetDays: days,
            usageGoal: goal,
            baseDecision: dummyDecision,
          );
          headlines.add(advice.headline);
        }
      }
      expect(headlines.length, equals(9));
    });

    test('flags ripe + >4 days + Konsumsi/Jual as notRecommended', () {
      final consume = SpkContextInterpreter.interpret(
        ripenessLabel: 'ripe',
        targetDays: SpkTargetDays.moreThanFourDays,
        usageGoal: SpkUsageGoal.freshConsumption,
        baseDecision: dummyDecision,
      );
      final retail = SpkContextInterpreter.interpret(
        ripenessLabel: 'ripe',
        targetDays: SpkTargetDays.moreThanFourDays,
        usageGoal: SpkUsageGoal.retailDistribution,
        baseDecision: dummyDecision,
      );

      expect(consume.suitability, equals(SpkSuitability.notRecommended));
      expect(retail.suitability, equals(SpkSuitability.notRecommended));
      expect(consume.headline, isNot(equals(retail.headline)));
    });

    test('flags rotten as notRecommended regardless of context', () {
      final advice = SpkContextInterpreter.interpret(
        ripenessLabel: 'rotten',
        targetDays: SpkTargetDays.today,
        usageGoal: SpkUsageGoal.freshConsumption,
        baseDecision: dummyDecision,
      );
      expect(advice.suitability, equals(SpkSuitability.notRecommended));
      expect(advice.headline, contains('Kompos'));
    });
  });
}
