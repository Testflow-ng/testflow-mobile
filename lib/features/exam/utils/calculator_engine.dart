/// Evaluates the calculator's expression strings.
///
/// Supported: + - * / with ( ), unary minus, percent as "divide by 100",
/// square root as a prefix function, and squaring as a postfix operator.
class CalculatorEngine {
  CalculatorEngine._();

  static double? evaluate(String expression) {
    if (expression.trim().isEmpty) return null;
    try {
      final tokens = _tokenize(expression);
      final rpn = _toRpn(tokens);
      return _evalRpn(rpn);
    } catch (_) {
      return null;
    }
  }

  static List<String> _tokenize(String input) {
    final tokens = <String>[];
    var i = 0;
    while (i < input.length) {
      final ch = input[i];
      if (ch == ' ') {
        i++;
      } else if (RegExp(r'[0-9.]').hasMatch(ch)) {
        var number = '';
        while (i < input.length && RegExp(r'[0-9.]').hasMatch(input[i])) {
          number += input[i];
          i++;
        }
        tokens.add(number);
      } else if ('+-*/()%'.contains(ch) || ch == '√' || ch == '²') {
        tokens.add(ch);
        i++;
      } else {
        throw const FormatException('Unknown character');
      }
    }
    return tokens;
  }

  static bool _isNumber(String token) => double.tryParse(token) != null;

  static int _precedence(String op) => switch (op) {
        '+' || '-' => 1,
        '*' || '/' => 2,
        'neg' => 3,
        '√' => 4,
        '%' || '²' => 5,
        _ => 0,
      };

  static List<String> _toRpn(List<String> tokens) {
    final output = <String>[];
    final stack = <String>[];

    for (var i = 0; i < tokens.length; i++) {
      var token = tokens[i];

      if (_isNumber(token)) {
        output.add(token);
        continue;
      }

      if (token == '-') {
        final prev = i == 0 ? null : tokens[i - 1];
        final isUnary = prev == null ||
            (!_isNumber(prev) && prev != ')' && prev != '%' && prev != '²');
        if (isUnary) token = 'neg';
      }

      if (token == '(') {
        stack.add(token);
      } else if (token == ')') {
        while (stack.isNotEmpty && stack.last != '(') {
          output.add(stack.removeLast());
        }
        if (stack.isEmpty) throw const FormatException('Mismatched parens');
        stack.removeLast();
      } else if (token == '%' || token == '²') {
        // Postfix: applies immediately to what came before.
        output.add(token);
      } else {
        while (stack.isNotEmpty &&
            stack.last != '(' &&
            _precedence(stack.last) >= _precedence(token) &&
            token != 'neg' &&
            token != '√') {
          output.add(stack.removeLast());
        }
        stack.add(token);
      }
    }

    while (stack.isNotEmpty) {
      final op = stack.removeLast();
      if (op == '(') throw const FormatException('Mismatched parens');
      output.add(op);
    }
    return output;
  }

  static double _evalRpn(List<String> rpn) {
    final stack = <double>[];

    double pop() {
      if (stack.isEmpty) throw const FormatException('Bad expression');
      return stack.removeLast();
    }

    for (final token in rpn) {
      if (_isNumber(token)) {
        stack.add(double.parse(token));
      } else if (token == 'neg') {
        stack.add(-pop());
      } else if (token == '√') {
        final value = pop();
        if (value < 0) throw const FormatException('Negative root');
        stack.add(_sqrt(value));
      } else if (token == '%') {
        stack.add(pop() / 100);
      } else if (token == '²') {
        final value = pop();
        stack.add(value * value);
      } else {
        final b = pop();
        final a = pop();
        stack.add(switch (token) {
          '+' => a + b,
          '-' => a - b,
          '*' => a * b,
          '/' => b == 0 ? throw const FormatException('Divide by zero') : a / b,
          _ => throw const FormatException('Unknown operator'),
        });
      }
    }

    if (stack.length != 1) throw const FormatException('Bad expression');
    final result = stack.single;
    if (result.isNaN || result.isInfinite) {
      throw const FormatException('Not a number');
    }
    return result;
  }

  static double _sqrt(double value) {
    if (value == 0) return 0;
    var guess = value / 2;
    for (var i = 0; i < 64; i++) {
      guess = (guess + value / guess) / 2;
    }
    return guess;
  }

  /// Formats a result without trailing zeros, up to 10 significant digits.
  static String format(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.round().toString();
    }
    var text = value.toStringAsPrecision(10);
    if (text.contains('.') && !text.contains('e')) {
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
    }
    return text;
  }
}
