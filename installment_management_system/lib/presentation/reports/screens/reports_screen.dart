import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../customer/viewmodels/customer_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/customer.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  Future<void> _generatePdf(BuildContext context, List<Customer> customers, String title) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Name', 'Contract', 'Mobile', 'Amount', 'Status', 'Date'],
              data: customers.map((c) => [
                c.customerName,
                c.contractNumber,
                c.mobile,
                currencyFormatter.format(c.installmentAmount),
                c.status,
                dateFormatter.format(c.createdAt),
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _generateExcel(BuildContext context, List<Customer> customers, String title) async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];
    final dateFormatter = DateFormat('yyyy-MM-dd');

    sheet.appendRow([
      TextCellValue('Customer Name'),
      TextCellValue('Contract Number'),
      TextCellValue('Mobile'),
      TextCellValue('Email'),
      TextCellValue('Contract Value'),
      TextCellValue('Installment Amount'),
      TextCellValue('Status'),
      TextCellValue('Created At'),
    ]);

    for (var c in customers) {
      sheet.appendRow([
        TextCellValue(c.customerName),
        TextCellValue(c.contractNumber),
        TextCellValue(c.mobile),
        TextCellValue(c.email ?? ''),
        DoubleCellValue(c.contractValue),
        DoubleCellValue(c.installmentAmount),
        TextCellValue(c.status),
        TextCellValue(dateFormatter.format(c.createdAt)),
      ]);
    }

    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final safeTitle = title.replaceAll(' ', '_');
      final path = p.join(directory.path, 'InstallmentSystem', '${safeTitle}_$dateStr.xlsx');
      
      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(fileBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel saved to $path'), backgroundColor: AppTheme.successColor),
        );
      }
    }
  }

  void _handleReport(BuildContext context, List<Customer> customers, String type, String format) {
    List<Customer> filtered = [];
    final now = DateTime.now();

    switch (type) {
      case 'Daily':
        filtered = customers.where((c) => c.createdAt.year == now.year && c.createdAt.month == now.month && c.createdAt.day == now.day).toList();
        break;
      case 'Monthly':
        filtered = customers.where((c) => c.createdAt.year == now.year && c.createdAt.month == now.month).toList();
        break;
      case 'Installment':
        filtered = customers.where((c) => c.status == 'Active').toList();
        break;
      case 'Customer':
      default:
        filtered = customers;
        break;
    }

    if (format == 'PDF') {
      _generatePdf(context, filtered, '$type Report');
    } else {
      _generateExcel(context, filtered, '$type Report');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerViewModelProvider);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports & Exports',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 32),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (state.error != null)
            Text('Error: ${state.error}', style: const TextStyle(color: AppTheme.errorColor))
          else
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 32,
                mainAxisSpacing: 32,
                childAspectRatio: 2,
                children: [
                  _buildReportCard(context, 'Daily Report', 'Today\'s activity', state.customers, 'Daily'),
                  _buildReportCard(context, 'Monthly Report', 'This month\'s activity', state.customers, 'Monthly'),
                  _buildReportCard(context, 'Customer Report', 'All registered customers', state.customers, 'Customer'),
                  _buildReportCard(context, 'Installment Report', 'Active installments', state.customers, 'Installment'),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, String subtitle, List<Customer> customers, String type) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: AppTheme.secondaryColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(subtitle, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _handleReport(context, customers, type, 'PDF'),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _handleReport(context, customers, type, 'Excel'),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Export Excel'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
