import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../state/form_data_model.dart';
import '../state/project_state_provider.dart';

class EditFormScreen extends ConsumerStatefulWidget {
  final FormDataModel formData;

  const EditFormScreen({super.key, required this.formData});

  @override
  ConsumerState<EditFormScreen> createState() => _EditFormScreenState();
}

class _EditFormScreenState extends ConsumerState<EditFormScreen> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'Serial No': TextEditingController(text: widget.formData.serialNo),
      'Title': TextEditingController(text: widget.formData.title),
      'First Name': TextEditingController(text: widget.formData.firstName),
      'Last Name': TextEditingController(text: widget.formData.lastName),
      'Initial': TextEditingController(text: widget.formData.initial),
      'Email': TextEditingController(text: widget.formData.email),
      'Father Name': TextEditingController(text: widget.formData.fatherName),
      'DOB': TextEditingController(text: widget.formData.dob),
      'Gender': TextEditingController(text: widget.formData.gender),
      'Profession': TextEditingController(text: widget.formData.profession),
      'Mailing Street': TextEditingController(text: widget.formData.mailingStreet),
      'Mailing City': TextEditingController(text: widget.formData.mailingCity),
      'Mailing Postal': TextEditingController(text: widget.formData.mailingPostal),
      'Mailing Country': TextEditingController(text: widget.formData.mailingCountry),
      'Service Provider': TextEditingController(text: widget.formData.serviceProvider),
      'File No': TextEditingController(text: widget.formData.fileNo),
      'Reference No': TextEditingController(text: widget.formData.referenceNo),
      'Sim No': TextEditingController(text: widget.formData.simNo),
      'IMSI 1': TextEditingController(text: widget.formData.imsi1),
      'IMSI 2': TextEditingController(text: widget.formData.imsi2),
      'Type Of Plan': TextEditingController(text: widget.formData.typeOfPlan),
      'Credit Card Type': TextEditingController(text: widget.formData.creditCardType),
      'Contract Value': TextEditingController(text: widget.formData.contractValue),
      'Date Of Issue': TextEditingController(text: widget.formData.dateOfIssue),
      'Date Of Renewal': TextEditingController(text: widget.formData.dateOfRenewal),
      'Installment': TextEditingController(text: widget.formData.installment),
      'Amount In Words': TextEditingController(text: widget.formData.amountInWords),
      'Remarks': TextEditingController(text: widget.formData.remarks),
    };
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleUpdate() {
    final updatedData = widget.formData.copyWith(
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

    ref.read(projectStateProvider.notifier).updateForm(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update Successfull')), // As per video spelling
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: const Text('Back To Project', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Details (Form ${widget.formData.serialNo} of 18)', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Text('Form Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Side: Read Only Details (from original data or dummy)
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow('Serial No', widget.formData.serialNo, 'Title', 'Miss.'),
                          _buildDetailRow('First Name', 'Ashlynn', 'Last Name', 'Lipscomb'),
                          _buildDetailRow('Initial', 'Parish', 'Email', 'ashlynnlipscomb@gmail.com'),
                          _buildDetailRow('Father Name', 'Zole', 'DOB', '2006-08-27'),
                          _buildDetailRow('Gender', 'Female', 'Profession', 'Shop Manager'),
                          _buildDetailRow('Mailing Street', '777 Elmwood Dr', 'Mailing City', 'Atlanta'),
                          _buildDetailRow('Mailing Postal', '30302', 'Mailing Country', 'USA'),
                          _buildDetailRow('Service Provider', 'Shaw Communications', 'File No', '76180379'),
                          _buildDetailRow('Reference No', '@j_>B...[S|<?6]', 'Sim No', '49019504522720900000'),
                          _buildDetailRow('IMSI 1', '828120726858670', 'IMSI 2', '2410317799J...'),
                          _buildDetailRow('Type Of Plan', 'Healthcare Plans', 'Credit Card Type', 'Dunkin1'),
                          _buildDetailRow('Contract Value', 'USD150', 'Date Of Issue', '2004-12-08'),
                          _buildDetailRow('Date Of Renewal', '2007-12-08', 'Installment', ''),
                          _buildDetailRow('Amount In Words', '', 'Remarks', ''),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Right Side: Editable Form Details
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
                          _buildInputRow('IMSI 1', 'IMSI 2'),
                          _buildInputRow('Type Of Plan', 'Credit Card Type'),
                          _buildInputRow('Contract Value', 'Date Of Issue'),
                          _buildInputRow('Date Of Renewal', 'Installment'),
                          _buildInputRow('Amount In Words', 'Remarks'),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _handleUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.textPrimaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            ),
                            child: const Text('Update'),
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
