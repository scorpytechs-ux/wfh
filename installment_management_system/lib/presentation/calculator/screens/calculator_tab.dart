import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CalculatorTab extends StatefulWidget {
  const CalculatorTab({super.key});

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  String _display = "0";

  void _onPressed(String text) {
    setState(() {
      if (_display == "0") {
        _display = text;
      } else {
        _display += text;
      }
    });
  }

  void _clear() {
    setState(() {
      _display = "0";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomRight,
                child: Text(
                  _display,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildRow(['7', '8', '9', '/']),
                  _buildRow(['4', '5', '6', '*']),
                  _buildRow(['1', '2', '3', '-']),
                  _buildRow(['C', '0', '=', '+']),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((btn) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextButton(
              onPressed: () {
                if (btn == 'C') {
                  _clear();
                } else if (btn == '=') {
                  // Dummy equal
                  setState(() { _display = "Result"; });
                } else {
                  _onPressed(btn);
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.backgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(btn, style: const TextStyle(fontSize: 24, color: AppTheme.textPrimaryColor)),
            ),
          ),
        )).toList(),
      ),
    );
  }
}
