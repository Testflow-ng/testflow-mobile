import 'package:flutter_test/flutter_test.dart';
import 'package:testflow/features/exam/utils/calculator_engine.dart';

void main() {
  group('CalculatorEngine', () {
    test('basic arithmetic', () {
      expect(CalculatorEngine.evaluate('2+3'), 5);
      expect(CalculatorEngine.evaluate('10-4'), 6);
      expect(CalculatorEngine.evaluate('6*7'), 42);
      expect(CalculatorEngine.evaluate('15/4'), 3.75);
    });

    test('operator precedence and parentheses', () {
      expect(CalculatorEngine.evaluate('2+3*4'), 14);
      expect(CalculatorEngine.evaluate('(2+3)*4'), 20);
      expect(CalculatorEngine.evaluate('2*(3+4)-5'), 9);
    });

    test('unary minus', () {
      expect(CalculatorEngine.evaluate('-5+8'), 3);
      expect(CalculatorEngine.evaluate('3*-2'), -6);
      expect(CalculatorEngine.evaluate('-(2+3)'), -5);
    });

    test('percent, square root, and square', () {
      expect(CalculatorEngine.evaluate('50%'), 0.5);
      expect(CalculatorEngine.evaluate('200*10%'), closeTo(20, 1e-9));
      expect(CalculatorEngine.evaluate('√9'), closeTo(3, 1e-9));
      expect(CalculatorEngine.evaluate('√(16+9)'), closeTo(5, 1e-9));
      expect(CalculatorEngine.evaluate('3²'), 9);
      expect(CalculatorEngine.evaluate('(1+2)²'), 9);
    });

    test('decimals', () {
      expect(CalculatorEngine.evaluate('0.1+0.2'), closeTo(0.3, 1e-9));
      expect(CalculatorEngine.evaluate('1.5*2'), 3);
    });

    test('invalid input returns null', () {
      expect(CalculatorEngine.evaluate(''), isNull);
      expect(CalculatorEngine.evaluate('2+'), isNull);
      expect(CalculatorEngine.evaluate('(2+3'), isNull);
      expect(CalculatorEngine.evaluate('5/0'), isNull);
      expect(CalculatorEngine.evaluate('√-4'), isNull);
      expect(CalculatorEngine.evaluate('abc'), isNull);
    });

    test('format trims trailing zeros', () {
      expect(CalculatorEngine.format(5), '5');
      expect(CalculatorEngine.format(3.75), '3.75');
      expect(CalculatorEngine.format(1 / 3), '0.3333333333');
    });
  });
}
