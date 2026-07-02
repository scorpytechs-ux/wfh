import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../state/form_data_model.dart';
import '../state/project_state_provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../data/repositories/form_repository.dart';
import '../../auth/screens/blocked_screen.dart';

class UploadFileTab extends ConsumerStatefulWidget {
  const UploadFileTab({super.key});

  @override
  ConsumerState<UploadFileTab> createState() => _UploadFileTabState();
}

class _UploadFileTabState extends ConsumerState<UploadFileTab> {
  bool _isFileUploaded = false;
  int _currentFormIndex = 1;
  int _totalForms = 1;

  // Parsed rows from the uploaded file — each entry is one record
  List<Map<String, String>> _fileRecords = [];

  final Map<String, TextEditingController> _controllers = {
    'Serial No': TextEditingController(),
    'Title': TextEditingController(),
    'First Name': TextEditingController(),
    'Last Name': TextEditingController(),
    'Initial': TextEditingController(),
    'Email': TextEditingController(),
    'Father Name': TextEditingController(),
    'DOB': TextEditingController(),
    'Gender': TextEditingController(),
    'Profession': TextEditingController(),
    'Mailing Street': TextEditingController(),
    'Mailing City': TextEditingController(),
    'Mailing Postal': TextEditingController(),
    'Mailing Country': TextEditingController(),
    'Service Provider': TextEditingController(),
    'File No': TextEditingController(),
    'Reference No': TextEditingController(),
    'Sim No': TextEditingController(),
    'Type Of Network': TextEditingController(),
    'Cell Model No': TextEditingController(),
    'IMSI 1': TextEditingController(),
    'IMSI 2': TextEditingController(),
    'Type Of Plan': TextEditingController(),
    'Credit Card Type': TextEditingController(),
    'Contract Value': TextEditingController(),
    'Date Of Issue': TextEditingController(),
    'Date Of Renewal': TextEditingController(),
    'Installment': TextEditingController(),
    'Amount In Words': TextEditingController(),
    'Remarks': TextEditingController(),
  };

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Maps the column headers in the file to the field names in the app
  static const Map<String, String> _columnMap = {
    'serial no': 'Serial No',
    'serialno': 'Serial No',
    'serial number': 'Serial No',
    'title': 'Title',
    'first name': 'First Name',
    'firstname': 'First Name',
    'last name': 'Last Name',
    'lastname': 'Last Name',
    'initial': 'Initial',
    'initials': 'Initial',
    'email': 'Email',
    'father name': 'Father Name',
    'fathername': 'Father Name',
    'dob': 'DOB',
    'date of birth': 'DOB',
    'gender': 'Gender',
    'profession': 'Profession',
    'mailing street': 'Mailing Street',
    'mailingstreet': 'Mailing Street',
    'mailing city': 'Mailing City',
    'mailingcity': 'Mailing City',
    'mailing postal': 'Mailing Postal',
    'mailingpostal': 'Mailing Postal',
    'mailing postal code': 'Mailing Postal',
    'postal': 'Mailing Postal',
    'mailing country': 'Mailing Country',
    'mailingcountry': 'Mailing Country',
    'country': 'Mailing Country',
    'service provider': 'Service Provider',
    'serviceprovider': 'Service Provider',
    'file no': 'File No',
    'fileno': 'File No',
    'file number': 'File No',
    'reference no': 'Reference No',
    'referenceno': 'Reference No',
    'ref no': 'Reference No',
    'sim no': 'Sim No',
    'simno': 'Sim No',
    'sim number': 'Sim No',
    'type of network': 'Type Of Network',
    'network': 'Type Of Network',
    'cell model no': 'Cell Model No',
    'cellmodelno': 'Cell Model No',
    'model no': 'Cell Model No',
    'imsi 1': 'IMSI 1',
    'imsi1': 'IMSI 1',
    'imsi 2': 'IMSI 2',
    'imsi2': 'IMSI 2',
    'type of plan': 'Type Of Plan',
    'typeofplan': 'Type Of Plan',
    'plan': 'Type Of Plan',
    'credit card type': 'Credit Card Type',
    'creditcardtype': 'Credit Card Type',
    'contract value': 'Contract Value',
    'contractvalue': 'Contract Value',
    'date of issue': 'Date Of Issue',
    'dateofissue': 'Date Of Issue',
    'date of renewal': 'Date Of Renewal',
    'dateofrenewal': 'Date Of Renewal',
    'installment': 'Installment',
    'amount in words': 'Amount In Words',
    'amountinwords': 'Amount In Words',
    'remarks': 'Remarks',
  };

  List<Map<String, String>> _parseExcel(List<int> bytes) {
    final excel = Excel.decodeBytes(bytes);
    final records = <Map<String, String>>[];

    final sheet = excel.sheets.values.first;
    if (sheet.rows.isEmpty) return records;

    // First row is headers
    final headers = sheet.rows.first
        .map((cell) => cell?.value?.toString().trim().toLowerCase() ?? '')
        .toList();

    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      final record = <String, String>{};

      for (int j = 0; j < headers.length; j++) {
        final header = headers[j];
        final mappedKey = _columnMap[header];
        if (mappedKey != null) {
          final cellValue = j < row.length ? row[j]?.value?.toString().trim() ?? '' : '';
          record[mappedKey] = cellValue;
        }
      }

      if (record.isNotEmpty) {
        records.add(record);
      }
    }

    return records;
  }

  List<Map<String, String>> _parseCsv(String content) {
    final records = <Map<String, String>>[];
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return records;

    final headers = lines.first.split(',').map((h) => h.trim().toLowerCase().replaceAll('"', '')).toList();

    for (int i = 1; i < lines.length; i++) {
      final values = lines[i].split(',').map((v) => v.trim().replaceAll('"', '')).toList();
      final record = <String, String>{};

      for (int j = 0; j < headers.length; j++) {
        final mappedKey = _columnMap[headers[j]];
        if (mappedKey != null) {
          record[mappedKey] = j < values.length ? values[j] : '';
        }
      }

      if (record.isNotEmpty) {
        records.add(record);
      }
    }

    return records;
  }

  /// Parses a form-style PDF page where text looks like:
  /// "Serial No: 1\nTitle: Miss.\nFirst Name: Ashlynn..."
  Map<String, String> _parseFormText(String text) {
    final record = <String, String>{};

    // Extended label map for "Label:" style PDFs
    const labelMap = <String, String>{
      'serial no': 'Serial No',
      'title': 'Title',
      'first name': 'First Name',
      'last name': 'Last Name',
      'initial': 'Initial',
      'initials': 'Initial',
      'email': 'Email',
      'father name': 'Father Name',
      'dob': 'DOB',
      'date of birth': 'DOB',
      'gender': 'Gender',
      'profession': 'Profession',
      'mailing street': 'Mailing Street',
      'mailing city': 'Mailing City',
      'mailing postal code': 'Mailing Postal',
      'mailing postal': 'Mailing Postal',
      'postal': 'Mailing Postal',
      'mailing country': 'Mailing Country',
      'country': 'Mailing Country',
      'service provider': 'Service Provider',
      'file no': 'File No',
      'file number': 'File No',
      'reference no': 'Reference No',
      'ref no': 'Reference No',
      'sim no': 'Sim No',
      'sim number': 'Sim No',
      'type of network': 'Type Of Network',
      'network': 'Type Of Network',
      'cell model no': 'Cell Model No',
      'model no': 'Cell Model No',
      'imsi 1': 'IMSI 1',
      'imsi 2': 'IMSI 2',
      'type of plan': 'Type Of Plan',
      'plan': 'Type Of Plan',
      'credit card type': 'Credit Card Type',
      'contract value': 'Contract Value',
      'date of issue': 'Date Of Issue',
      'date of renewal': 'Date Of Renewal',
      'installment': 'Installment',
      'amount in words': 'Amount In Words',
      'remarks': 'Remarks',
    };

    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    // Strategy 1: "Label: Value" on same line (e.g. "Serial No: 1                             Title: Miss")
    for (final line in lines) {
      final lineLower = line.toLowerCase();
      List<int> colonIndices = [];
      for (int i = 0; i < line.length; i++) {
        if (line[i] == ':') colonIndices.add(i);
      }

      if (colonIndices.isEmpty) continue;

      String? currentLabelKey;
      int currentValueStart = 0;

      for (int i = 0; i < colonIndices.length; i++) {
        int c = colonIndices[i];
        String textBeforeColon = lineLower.substring(currentValueStart, c).trimRight();
        
        String? foundLabel;
        for (final label in labelMap.keys) {
          if (textBeforeColon.endsWith(label)) {
            int labelStartIdx = textBeforeColon.length - label.length;
            if (labelStartIdx == 0 || textBeforeColon[labelStartIdx - 1] == ' ' || textBeforeColon[labelStartIdx - 1] == '\t') {
              if (foundLabel == null || label.length > foundLabel.length) {
                foundLabel = label;
              }
            }
          }
        }

        if (foundLabel != null) {
          int labelStartIdx = textBeforeColon.length - foundLabel.length;
          if (currentLabelKey != null) {
            String value = line.substring(currentValueStart, currentValueStart + labelStartIdx).trim();
            if (value.isNotEmpty) {
              record[labelMap[currentLabelKey]!] = value;
            }
          }
          currentLabelKey = foundLabel;
          currentValueStart = c + 1;
        }
      }

      if (currentLabelKey != null) {
        String value = line.substring(currentValueStart).trim();
        if (value.isNotEmpty) {
          record[labelMap[currentLabelKey]!] = value;
        }
      }
    }

    if (record.isNotEmpty) return record;

    // Strategy 2: Labels and values on alternating lines
    // e.g. ["Serial No:", "1", "Title:", "Miss.", ...]
    for (int i = 0; i < lines.length - 1; i++) {
      final potentialLabel = lines[i].replaceAll(':', '').trim().toLowerCase();
      final potentialValue = lines[i + 1];
      final fieldKey = labelMap[potentialLabel];
      if (fieldKey != null &&
          !potentialValue.endsWith(':') &&
          potentialValue.isNotEmpty) {
        record[fieldKey] = potentialValue;
        i++; // skip the value line
      }
    }

    return record;
  }

  Future<List<Map<String, String>>> _parsePdf(Uint8List bytes) async {
    final records = <Map<String, String>>[];

    final doc = await PdfDocument.openData(bytes);

    // Each page is treated as one customer record (form-style PDF)
    for (int i = 0; i < doc.pages.length; i++) {
      final page = doc.pages[i];
      final textPage = await page.loadText();
      final fullText = textPage.fullText;

      final record = _parseFormText(fullText);
      if (record.isNotEmpty) {
        records.add(record);
      }
    }

    doc.dispose();

    // Fallback: if still empty, try table-format on combined text
    if (records.isEmpty) {
      final doc2 = await PdfDocument.openData(bytes);
      final buffer = StringBuffer();
      for (int i = 0; i < doc2.pages.length; i++) {
        final textPage = await doc2.pages[i].loadText();
        buffer.writeln(textPage.fullText);
      }
      doc2.dispose();

      final lines = buffer.toString()
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      if (lines.length >= 2) {
        String delimiter = '\t';
        if (lines.first.contains('|')) delimiter = '|';
        else if (lines.first.contains(';')) delimiter = ';';
        else if (!lines.first.contains('\t')) delimiter = '  ';

        List<String> headers;
        if (delimiter == '  ') {
          headers = lines.first.split(RegExp(r'\s{2,}')).map((h) => h.trim().toLowerCase()).toList();
        } else {
          headers = lines.first.split(delimiter).map((h) => h.trim().toLowerCase()).toList();
        }

        for (int i = 1; i < lines.length; i++) {
          List<String> values;
          if (delimiter == '  ') {
            values = lines[i].split(RegExp(r'\s{2,}')).map((v) => v.trim()).toList();
          } else {
            values = lines[i].split(delimiter).map((v) => v.trim()).toList();
          }
          if (values.length < 2) continue;
          final record = <String, String>{};
          for (int j = 0; j < headers.length; j++) {
            final mappedKey = _columnMap[headers[j]];
            if (mappedKey != null) {
              record[mappedKey] = j < values.length ? values[j] : '';
            }
          }
          if (record.isNotEmpty) records.add(record);
        }
      }
    }

    return records;
  }

  void _handleUpload() async {
    final user = ref.read(authViewModelProvider).currentUser;
    final int monthlyTarget = (user != null && user['monthlyTarget'] != null)
        ? user['monthlyTarget']
        : 0;

    final userId = (user != null) ? (user['id'] ?? user['username'] ?? '') as String : '';
    
    int currentMonthlyForms = 0;
    if (userId.isNotEmpty) {
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        final currentMonthStr = todayStr.substring(0, 7);
        currentMonthlyForms = await FormRepository().getFormsCountForUser(userId, monthStr: currentMonthStr);
    }

    if (monthlyTarget <= 0 || currentMonthlyForms >= monthlyTarget) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have reached your monthly target limit!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    int remainingMonthly = monthlyTarget - currentMonthlyForms;
    final int count = remainingMonthly > 0 ? remainingMonthly : 1;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      List<Map<String, String>> parsedRecords = [];

      try {
        if (file.extension == 'csv') {
          final content = String.fromCharCodes(file.bytes!);
          parsedRecords = _parseCsv(content);
        } else if (file.extension == 'pdf') {
          parsedRecords = await _parsePdf(file.bytes!);
        } else {
          parsedRecords = _parseExcel(file.bytes!.toList());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not parse file: $e'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      if (parsedRecords.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No data found in file. Make sure the PDF has "Label: Value" formatted fields or check that your Excel/CSV has column headers in the first row.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Limit to required count
      final recordsToUse = parsedRecords.take(count).toList();

      ref.read(targetFormCountProvider.notifier).setCount(recordsToUse.length);

      setState(() {
        _isFileUploaded = true;
        _totalForms = recordsToUse.length;
        _currentFormIndex = 1;
        _fileRecords = recordsToUse;
      });
    }
  }

  Map<String, String> get _currentRecord {
    if (_fileRecords.isEmpty) return {};
    return _fileRecords[_currentFormIndex - 1];
  }

  String _r(String key) => _currentRecord[key] ?? '';

  Future<bool> _saveCurrentForm() async {
    final serialNo = _controllers['Serial No']!.text.trim();
    if (serialNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out the form before saving.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check for duplicates
    final existingForms = ref.read(projectStateProvider);
    final isDuplicate = existingForms.any(
        (form) => form.serialNo == serialNo && form.serialNo.isNotEmpty);

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: A form with this Serial No has already been submitted! Forms cannot be exactly the same.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final data = FormDataModel(
      id: const Uuid().v4(),
      serialNo: _controllers['Serial No']!.text,
      title: _controllers['Title']!.text,
      firstName: _controllers['First Name']!.text,
      lastName: _controllers['Last Name']!.text,
      initial: _controllers['Initial']!.text,
      email: _controllers['Email']!.text,
      fatherName: _controllers['Father Name']!.text,
      dob: _controllers['DOB']!.text,
      gender: _controllers['Gender']!.text,
      profession: _controllers['Profession']!.text,
      mailingStreet: _controllers['Mailing Street']!.text,
      mailingCity: _controllers['Mailing City']!.text,
      mailingPostal: _controllers['Mailing Postal']!.text,
      mailingCountry: _controllers['Mailing Country']!.text,
      serviceProvider: _controllers['Service Provider']!.text,
      fileNo: _controllers['File No']!.text,
      referenceNo: _controllers['Reference No']!.text,
      simNo: _controllers['Sim No']!.text,
      typeOfNetwork: _controllers['Type Of Network']!.text,
      cellModelNo: _controllers['Cell Model No']!.text,
      imsi1: _controllers['IMSI 1']!.text,
      imsi2: _controllers['IMSI 2']!.text,
      typeOfPlan: _controllers['Type Of Plan']!.text,
      creditCardType: _controllers['Credit Card Type']!.text,
      contractValue: _controllers['Contract Value']!.text,
      dateOfIssue: _controllers['Date Of Issue']!.text,
      dateOfRenewal: _controllers['Date Of Renewal']!.text,
      installment: _controllers['Installment']!.text,
      amountInWords: _controllers['Amount In Words']!.text,
      remarks: _controllers['Remarks']!.text,
    );

    if (!data.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out ALL fields properly before saving!'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    await ref.read(projectStateProvider.notifier).addForm(data);
    return true;
  }

  void _handleSave() async {
    if (!await _saveCurrentForm()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitted successfully!')),
    );

    if (_currentFormIndex < _totalForms) {
      setState(() {
        _currentFormIndex++;
        for (var controller in _controllers.values) {
          controller.clear();
        }
      });
    } else {
      setState(() {
        _isFileUploaded = false;
        _currentFormIndex = 1;
        _fileRecords = [];
        for (var controller in _controllers.values) {
          controller.clear();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All $_totalForms forms saved! You can now upload a new file.')),
      );
    }
  }

  void _handleFinalSubmit() async {
    if (!await _saveCurrentForm()) return; // Save current form before submitting

    final user = ref.read(authViewModelProvider).currentUser;
    final forms = ref.read(projectStateProvider);
    final int monthlyTarget = (user != null && user['monthlyTarget'] != null)
        ? user['monthlyTarget']
        : 0;
    final userId = (user != null) ? (user['id'] ?? user['username'] ?? '') as String : '';
    
    int currentMonthlyForms = 0;
    if (userId.isNotEmpty) {
final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        final currentMonthStr = todayStr.substring(0, 7);
        currentMonthlyForms = await FormRepository().getFormsCountForUser(userId, monthStr: currentMonthStr);
    }

    bool isComplete = currentMonthlyForms >= monthlyTarget;

    if (!isComplete) {
      // Instantly block the user ID in the database
      await ref.read(authViewModelProvider.notifier).blockCurrentUser();
      ref.read(authViewModelProvider.notifier).logout(); // Log them out
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => BlockedScreen(targetCount: monthlyTarget)),
          (route) => false,
        );
      }
    } else {
      final formRepo = FormRepository();
      for (var form in forms) {
        if (user != null) {
          await formRepo.saveForm(form, user['id']);
        }
      }

      // We keep the forms in state so progress counters remain accurate
      // ref.read(projectStateProvider.notifier).clearForms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project submitted successfully! Waiting for admin review.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isFileUploaded = false;
          _currentFormIndex = 1;
          _fileRecords = [];
          for (var controller in _controllers.values) {
            controller.clear();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isFileUploaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_file, size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            const Text(
              'Please Upload File to Begin...',
              style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Supported formats: .xlsx, .xls, .csv, .pdf',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleUpload,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select File'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Details (Form $_currentFormIndex of $_totalForms)',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Text('Form Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isFileUploaded = false;
                    _currentFormIndex = 1;
                    _fileRecords = [];
                    for (var controller in _controllers.values) {
                      controller.clear();
                    }
                  });
                },
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text('Remove File', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side: Real data from uploaded file
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDetailRow('Serial No', _r('Serial No'), 'Title', _r('Title')),
                        _buildDetailRow('First Name', _r('First Name'), 'Last Name', _r('Last Name')),
                        _buildDetailRow('Initial', _r('Initial'), 'Email', _r('Email')),
                        _buildDetailRow('Father Name', _r('Father Name'), 'DOB', _r('DOB')),
                        _buildDetailRow('Gender', _r('Gender'), 'Profession', _r('Profession')),
                        _buildDetailRow('Mailing Street', _r('Mailing Street'), 'Mailing City', _r('Mailing City')),
                        _buildDetailRow('Mailing Postal', _r('Mailing Postal'), 'Mailing Country', _r('Mailing Country')),
                        _buildDetailRow('Service Provider', _r('Service Provider'), 'File No', _r('File No')),
                        _buildDetailRow('Reference No', _r('Reference No'), 'Sim No', _r('Sim No')),
                        _buildDetailRow('Type Of Network', _r('Type Of Network'), 'Cell Model No', _r('Cell Model No')),
                        _buildDetailRow('IMSI 1', _r('IMSI 1'), 'IMSI 2', _r('IMSI 2')),
                        _buildDetailRow('Type Of Plan', _r('Type Of Plan'), 'Credit Card Type', _r('Credit Card Type')),
                        _buildDetailRow('Contract Value', _r('Contract Value'), 'Date Of Issue', _r('Date Of Issue')),
                        _buildDetailRow('Date Of Renewal', _r('Date Of Renewal'), 'Installment', _r('Installment')),
                        _buildDetailRow('Amount In Words', _r('Amount In Words'), 'Remarks', _r('Remarks')),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // Right Side: Editable Form Details (Empty Fields)
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInputRow('Serial No', 'Title'),
                        _buildInputRow('First Name', 'Last Name'),
                        _buildInputRow('Initial', 'Email'),
                        _buildInputRow('Father Name', 'DOB'),
                        _buildInputRow('Gender', 'Profession'),
                        _buildInputRow('Mailing Street', 'Mailing City'),
                        _buildInputRow('Mailing Postal', 'Mailing Country'),
                        _buildInputRow('Service Provider', 'File No'),
                        _buildInputRow('Reference No', 'Sim No'),
                        _buildInputRow('Type Of Network', 'Cell Model No'),
                        _buildInputRow('IMSI 1', 'IMSI 2'),
                        _buildInputRow('Type Of Plan', 'Credit Card Type'),
                        _buildInputRow('Contract Value', 'Date Of Issue'),
                        _buildInputRow('Date Of Renewal', 'Installment'),
                        _buildInputRow('Amount In Words', 'Remarks'),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                              ),
                              child: const Text('SAVE'),
                            ),
                            const SizedBox(width: 24),
                            ElevatedButton(
                              onPressed: _handleFinalSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.textPrimaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                              ),
                              child: const Text('SUBMIT'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label1, String val1, String label2, String val2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: _buildDetailItem(label1, val1)),
          Expanded(child: _buildDetailItem(label2, val2)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildInputRow(String label1, String label2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: _buildInputItem(label1)),
          const SizedBox(width: 16),
          Expanded(child: _buildInputItem(label2)),
        ],
      ),
    );
  }

  Widget _buildInputItem(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextField(
            controller: _controllers[label],
            decoration: const InputDecoration(
              hintText: '',
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            ),
          ),
        ),
      ],
    );
  }
}
