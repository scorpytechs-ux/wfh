import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _contractValueController = TextEditingController();
  final _monthsController = TextEditingController();
  // Standard value is fixed at 10.33 per the formula, but user can override
  final _standardValueController = TextEditingController(text: '10.33');

  double _firstValue = 0.0;    // Contract Value / Months
  double _secondValue = 0.0;   // First Value × standard value
  double _thirdValue = 0.0;    // Second Value / 100
  double _finalInstallment = 0.0; // Third Value + First Value

  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    _contractValueController.addListener(_calculate);
    _monthsController.addListener(_calculate);
    _standardValueController.addListener(_calculate);
  }

  @override
  void dispose() {
    _contractValueController.dispose();
    _monthsController.dispose();
    _standardValueController.dispose();
    super.dispose();
  }

  void _calculate() {
    final double contractValue = double.tryParse(_contractValueController.text) ?? 0.0;
    final int months = int.tryParse(_monthsController.text) ?? 0;
    final double standardValue = double.tryParse(_standardValueController.text) ?? 10.33;

    if (contractValue <= 0 || months <= 0) {
      setState(() {
        _firstValue = 0;
        _secondValue = 0;
        _thirdValue = 0;
        _finalInstallment = 0;
        _hasResult = false;
      });
      return;
    }

    setState(() {
      // Step 1: Contract Value ÷ Months = First Value (3 decimal places)
      _firstValue = double.parse((contractValue / months).toStringAsFixed(3));
      // Step 2: First Value × 10.33 (standard value) = Second Value
      _secondValue = double.parse((_firstValue * standardValue).toStringAsFixed(3));
      // Step 3: Second Value / 100 = Third Value
      _thirdValue = double.parse((_secondValue / 100).toStringAsFixed(3));
      // Final: Third Value + First Value = Installment
      _finalInstallment = double.parse((_thirdValue + _firstValue).toStringAsFixed(3));
      _hasResult = true;
    });
  }

  void _reset() {
    setState(() {
      _contractValueController.clear();
      _monthsController.clear();
      _standardValueController.text = '10.33';
      _firstValue = 0;
      _secondValue = 0;
      _thirdValue = 0;
      _finalInstallment = 0;
      _hasResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calculate, color: AppTheme.primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Installment Calculator',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text('Based on standard 10.33 formula',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT: Inputs
              Expanded(
                flex: 1,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Inputs',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        const Text('Enter contract details to calculate installment',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 24),

                        // Contract Value
                        _buildInputField(
                          controller: _contractValueController,
                          label: 'Contract Value',
                          hint: 'e.g. 150',
                          prefix: 'USD ',
                          icon: Icons.attach_money,
                        ),
                        const SizedBox(height: 16),

                        // Contract Months
                        _buildInputField(
                          controller: _monthsController,
                          label: 'Contract Duration (Months)',
                          hint: 'e.g. 36',
                          suffix: ' months',
                          icon: Icons.calendar_month,
                        ),
                        const SizedBox(height: 16),

                        // Standard Value
                        _buildInputField(
                          controller: _standardValueController,
                          label: 'Standard Value',
                          hint: '10.33',
                          icon: Icons.percent,
                          helperText: 'Default: 10.33 (fixed per formula)',
                        ),

                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _reset,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Reset'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade200,
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 32),

              // RIGHT: Calculation Breakdown
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Formula card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: const Color(0xFF1E293B),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.functions, color: Colors.white70, size: 20),
                                const SizedBox(width: 8),
                                const Text('Formula',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildFormulaRow('Step 1', 'Contract Value ÷ Months', '= First Value', '(3 decimals)'),
                            _buildFormulaRow('Step 2', 'First Value × 10.33', '= Second Value', ''),
                            _buildFormulaRow('Step 3', 'Second Value ÷ 100', '= Third Value', ''),
                            _buildFormulaRow('Final', 'Third Value + First Value', '= Installment', ''),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Step-by-step results card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: AppTheme.primaryColor,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.receipt_long, color: Colors.white70, size: 20),
                                SizedBox(width: 8),
                                Text('Calculation Breakdown',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            _buildStepRow(
                              stepNum: '1',
                              formula: '${_contractValueController.text.isEmpty ? "CV" : _contractValueController.text} ÷ '
                                  '${_monthsController.text.isEmpty ? "M" : _monthsController.text}',
                              label: 'First Value',
                              value: _hasResult ? _firstValue.toStringAsFixed(3) : '—',
                              color: Colors.blue.shade200,
                            ),
                            const Divider(color: Colors.white24, height: 24),

                            _buildStepRow(
                              stepNum: '2',
                              formula: '${_hasResult ? _firstValue.toStringAsFixed(3) : "First Value"} × '
                                  '${_standardValueController.text.isEmpty ? "10.33" : _standardValueController.text}',
                              label: 'Second Value',
                              value: _hasResult ? _secondValue.toStringAsFixed(3) : '—',
                              color: Colors.orange.shade200,
                            ),
                            const Divider(color: Colors.white24, height: 24),

                            _buildStepRow(
                              stepNum: '3',
                              formula: '${_hasResult ? _secondValue.toStringAsFixed(3) : "Second Value"} ÷ 100',
                              label: 'Third Value',
                              value: _hasResult ? _thirdValue.toStringAsFixed(3) : '—',
                              color: Colors.purple.shade200,
                            ),
                            const Divider(color: Colors.white24, height: 24),

                            // Final installment highlight
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Monthly Installment',
                                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Text(
                                        _hasResult
                                            ? '${_thirdValue.toStringAsFixed(3)} + ${_firstValue.toStringAsFixed(3)}'
                                            : 'Third Value + First Value',
                                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _hasResult ? _finalInstallment.toStringAsFixed(3) : '—',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefix,
    String? suffix,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        suffixText: suffix,
        helperText: helperText,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildFormulaRow(String step, String formula, String result, String note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(step,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$formula $result ${note.isNotEmpty ? "[$note]" : ""}',
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String stepNum,
    required String formula,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(stepNum,
                style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text(formula, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ),
        Text(value,
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
