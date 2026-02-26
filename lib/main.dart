import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

/// Part I: Core calculator
/// Part II Feature #1: Theme Toggle (light / dark)
/// Part II Feature #2: Clear / All Clear (C / AC)
/// Part II Feature #3: Error Handling (division by zero, incomplete input)
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(useMaterial3: true),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // =========================
  // Feature #1: Theme Toggle
  // =========================
  bool isDarkMode = true; // Start in dark mode

  /// Toggle between light and dark color scheme
  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  // =========================
  // Calculator state
  // =========================
  String displayText = '0';    // Current value shown on screen
  String? errorMessage;         // Non-null when calculator is in error state
  double? firstOperand;         // Stored first number
  String? selectedOperator;     // Pending operator: +, -, *, /
  bool startNewNumber = true;   // Whether next digit starts a fresh number

  // -------------------------
  // Feature #3: Error helpers
  // -------------------------

  /// True when the calculator is displaying an error
  bool get hasError => errorMessage != null;

  /// Enter error state with a descriptive message
  void _setError(String message) {
    setState(() {
      errorMessage = message;
      displayText = 'Error';
    });
  }

  /// Dismiss the current error so the user can continue typing
  void _clearErrorOnly() {
    setState(() {
      errorMessage = null;
      if (displayText == 'Error') displayText = '0';
    });
  }

  // =========================
  // Feature #2: C / AC
  // =========================

  /// Clear only the current entry; keep firstOperand and operator intact
  void clearEntry() {
    setState(() {
      errorMessage = null;
      displayText = '0';
      startNewNumber = true;
    });
  }

  /// Reset the entire calculator back to its initial state
  void allClear() {
    setState(() {
      displayText = '0';
      errorMessage = null;
      firstOperand = null;
      selectedOperator = null;
      startNewNumber = true;
    });
  }

  // -------------------------
  // Helpers
  // -------------------------

  /// Parse the display string into a double
  double? _parseDisplay() {
    return double.tryParse(displayText);
  }

  /// Format a double for display, stripping unnecessary trailing zeros
  String _formatNumber(double value) {
    final asInt = value.toInt();
    if ((value - asInt).abs() < 1e-10) return asInt.toString();
    String out = value.toStringAsFixed(10);
    out = out.replaceFirst(RegExp(r'\.?0+$'), '');
    return out;
  }

  // =========================
  // Part I: Input handlers
  // =========================

  /// Append a digit to the display
  void pressDigit(String digit) {
    if (hasError) _clearErrorOnly(); // Feature #3: dismiss error on new input
    setState(() {
      if (startNewNumber || displayText == '0') {
        displayText = digit;
        startNewNumber = false;
      } else {
        if (displayText.length < 14) displayText += digit;
      }
    });
  }

  /// Append a decimal point to the display
  void pressDot() {
    if (hasError) _clearErrorOnly();
    setState(() {
      if (startNewNumber) {
        displayText = '0.';
        startNewNumber = false;
        return;
      }
      if (!displayText.contains('.')) displayText += '.';
    });
  }

  /// Store first operand and selected operator; compute chain if needed
  void pressOperator(String op) {
    if (hasError) return; // Feature #3: block operators while in error state

    final currentNumber = _parseDisplay();
    if (currentNumber == null) {
      _setError('Invalid number');
      return;
    }

    setState(() {
      // If an operation is already pending, compute intermediate result
      if (firstOperand != null && selectedOperator != null && !startNewNumber) {
        final result = _compute(firstOperand!, selectedOperator!, currentNumber);
        if (result == null) return;
        firstOperand = result;
        displayText = _formatNumber(result);
      } else {
        firstOperand = currentNumber;
      }
      selectedOperator = op;
      startNewNumber = true;
      errorMessage = null;
    });
  }

  /// Evaluate the pending operation and show the result
  void pressEquals() {
    if (hasError) return;

    final secondOperand = _parseDisplay();

    // Feature #3: detect incomplete input before trying to compute
    if (firstOperand == null || selectedOperator == null || secondOperand == null) {
      _setError('Incomplete input');
      return;
    }

    final result = _compute(firstOperand!, selectedOperator!, secondOperand);
    if (result == null) return;

    setState(() {
      displayText = _formatNumber(result);
      firstOperand = result;
      selectedOperator = null;
      startNewNumber = true;
      errorMessage = null;
    });
  }

  // =========================
  // Part I: Arithmetic function
  // =========================

  /// Perform the requested arithmetic operation on two operands
  double? _compute(double a, String op, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        if (b.abs() < 1e-12) {
          _setError('Cannot divide by 0'); // Feature #3: division by zero
          return null;
        }
        return a / b;
      default:
        _setError('Unknown operator');
        return null;
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    // Feature #1: Two color schemes — switch based on isDarkMode
    final background =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final panel =
        isDarkMode ? const Color(0xFF111827) : Colors.white;
    final displayBg =
        isDarkMode ? const Color(0xFF0B1220) : const Color(0xFFE2E8F0);
    final numberBtn =
        isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final operatorBtn =
        isDarkMode ? const Color(0xFF5B4BCE) : const Color(0xFF2563EB);
    final textColor =
        isDarkMode ? const Color(0xFFE5E7EB) : const Color(0xFF0F172A);
    final displayColor =
        isDarkMode ? const Color(0xFF34D399) : const Color(0xFF16A34A);
    const displayErr = Color(0xFFF87171); // Red for error state

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 24,
                      offset: Offset(0, 16),
                      color: Colors.black38,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row: title + theme toggle button (Feature #1)
                    Row(
                      children: [
                        Text(
                          'Calculator',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        // Sun/moon icon toggles the theme
                        IconButton(
                          onPressed: toggleTheme,
                          icon: Icon(
                            isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          ),
                          color: textColor.withValues(alpha: 0.85),
                          tooltip: 'Toggle theme',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Display area
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 22),
                      decoration: BoxDecoration(
                        color: displayBg,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            displayText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: hasError ? displayErr : displayColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Show error message or pending operator as hint
                          Text(
                            errorMessage ??
                                (selectedOperator != null
                                    ? 'Op: $selectedOperator'
                                    : ''),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Button grid (4 columns)
                    _Grid(
                      gap: 12,
                      children: [
                        // Row 1: C (span 2), AC (span 2)
                        GridItem(
                          span: 2,
                          child: CalcButton(
                            label: 'C',
                            bg: operatorBtn,
                            fg: Colors.white,
                            onTap: clearEntry,
                          ),
                        ),
                        GridItem(
                          span: 2,
                          child: CalcButton(
                            label: 'AC',
                            bg: operatorBtn,
                            fg: Colors.white,
                            onTap: allClear,
                          ),
                        ),

                        // Row 2: 7 8 9 /
                        ...['7', '8', '9'].map(
                          (d) => GridItem(
                            child: CalcButton(
                              label: d,
                              bg: numberBtn,
                              fg: textColor,
                              onTap: () => pressDigit(d),
                            ),
                          ),
                        ),
                        GridItem(
                          child: CalcButton(
                            label: '/',
                            bg: operatorBtn,
                            fg: Colors.white,
                            onTap: () => pressOperator('/'),
                          ),
                        ),

                        // Row 3: 4 5 6 *
                        ...['4', '5', '6'].map(
                          (d) => GridItem(
                            child: CalcButton(
                              label: d,
                              bg: numberBtn,
                              fg: textColor,
                              onTap: () => pressDigit(d),
                            ),
                          ),
                        ),
                        GridItem(
                          child: CalcButton(
                            label: '*',
                            bg: operatorBtn,
                            fg: Colors.white,
                            onTap: () => pressOperator('*'),
                          ),
                        ),

                        // Row 4: 1 2 3 -
                        ...['1', '2', '3'].map(
                          (d) => GridItem(
                            child: CalcButton(
                              label: d,
                              bg: numberBtn,
                              fg: textColor,
                              onTap: () => pressDigit(d),
                            ),
                          ),
                        ),
                        GridItem(
                          child: CalcButton(
                            label: '-',
                            bg: operatorBtn,
                            fg: Colors.white,
                            onTap: () => pressOperator('-'),
                          ),
                        ),

                        // Row 5: 0 (span 2), . , +
                        GridItem(
                          span: 2,
                          child: CalcButton(
                            label: '0',
                            bg: numberBtn,
                            fg: textColor,
                            onTap: () => pressDigit('0'),
                          ),
                        ),
                        GridItem(
                          child: CalcButton(
                            label: '.',
                            bg: numberBtn,
                            fg: textColor,
                            onTap: pressDot,
                          ),
                        ),
                        GridItem(
                          child: CalcButton(
                            label: '+',
                            bg: operatorBtn,
                            fg: Colors.white,
                            onTap: () => pressOperator('+'),
                          ),
                        ),

                        // Row 6: = (full width)
                        GridItem(
                          span: 4,
                          child: CalcButton(
                            label: '=',
                            bg: operatorBtn,
                            fg: Colors.white,
                            onTap: pressEquals,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A grid item that can span multiple columns
class GridItem {
  final Widget child;
  final int span;
  const GridItem({required this.child, this.span = 1});
}

/// Simple 4-column grid with span support for the 0 button
class _Grid extends StatelessWidget {
  final List<GridItem> children;
  final double gap;
  const _Grid({required this.children, this.gap = 12});

  @override
  Widget build(BuildContext context) {
    const cols = 4;
    final rows = <List<GridItem>>[];
    var currentRow = <GridItem>[];
    var used = 0;

    for (final item in children) {
      final span = item.span.clamp(1, cols);
      if (used + span > cols) {
        rows.add(currentRow);
        currentRow = <GridItem>[];
        used = 0;
      }
      currentRow.add(item);
      used += span;
      if (used == cols) {
        rows.add(currentRow);
        currentRow = <GridItem>[];
        used = 0;
      }
    }
    if (currentRow.isNotEmpty) rows.add(currentRow);

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: row == rows.last ? 0 : gap),
          child: Row(
            children: row.map((item) {
              return Expanded(
                flex: item.span,
                child: Padding(
                  padding:
                      EdgeInsets.only(right: item == row.last ? 0 : gap),
                  child: item.child,
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

/// Simple calculator button (StatelessWidget — no animation yet)
class CalcButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const CalcButton({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 64,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
