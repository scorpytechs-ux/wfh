import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _contractValueController = TextEditingController();
  final _monthsController = TextEditingController();
  final _percentageController = TextEditingController();

  double _baseAmount = 0.0;
  double _interestAmount = 0.0;
  double _totalPayable = 0.0;
  double _finalInstallment = 0.0;

  @override
  void initState() {
    super.initState();
    _contractValueController.addListener(_calculate);
    _monthsController.addListener(_calculate);
    _percentageController.addListener(_calculate);
  }

  @override
  void dispose() {
    _contractValueController.dispose();
    _monthsController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  void _calculate() {
    final double contractValue = double.tryParse(_contractValueController.text) ?? 0.0;
    final int months = int.tryParse(_monthsController.text) ?? 0;
    final double percentage = double.tryParse(_percentageController.text) ?? 0.0;

    setState(() {
      _baseAmount = contractValue;
      _interestAmount = contractValue * (percentage / 100);
      _totalPayable = _baseAmount + _interestAmount;
      if (months > 0) {
        _finalInstallment = _totalPayable / months;
      } else {
        _finalInstallment = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Installment Calculator',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Inputs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _contractValueController,
                          decoration: const InputDecoration(labelText: 'Contract Value', prefixText: '\$'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _monthsController,
                          decoration: const InputDecoration(labelText: 'Contract Duration (Months)'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _percentageController,
                          decoration: const InputDecoration(labelText: 'Interest Percentage (Flat)', suffixText: '%'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 1,
                child: Card(
                  color: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Calculation Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 32),
                        _buildBreakdownRow('Base Amount:', currencyFormatter.format(_baseAmount)),
                        const Divider(color: Colors.white24),
                        _buildBreakdownRow('Interest Amount:', '+ ${currencyFormatter.format(_interestAmount)}'),
                        const Divider(color: Colors.white24, thickness: 2),
                        _buildBreakdownRow('Total Payable Amount:', currencyFormatter.format(_totalPayable), isBold: true),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Monthly Installment', style: TextStyle(color: Colors.white, fontSize: 18)),
                              Text(
                                currencyFormatter.format(_finalInstallment),
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: isBold ? 18 : 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: isBold ? 18 : 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
