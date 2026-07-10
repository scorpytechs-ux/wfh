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
                          _buildDetailRow('Serial No', widget.formData.serialNo, 'serialNo', 'Title', widget.formData.title, 'title'),
                          _buildDetailRow('First Name', widget.formData.firstName, 'firstName', 'Last Name', widget.formData.lastName, 'lastName'),
                          _buildDetailRow('Initial', widget.formData.initial, 'initial', 'Email', widget.formData.email, 'email'),
                          _buildDetailRow('Father Name', widget.formData.fatherName, 'fatherName', 'DOB', widget.formData.dob, 'dob'),
                          _buildDetailRow('Gender', widget.formData.gender, 'gender', 'Profession', widget.formData.profession, 'profession'),
                          _buildDetailRow('Mailing Street', widget.formData.mailingStreet, 'mailingStreet', 'Mailing City', widget.formData.mailingCity, 'mailingCity'),
                          _buildDetailRow('Mailing Postal', widget.formData.mailingPostal, 'mailingPostal', 'Mailing Country', widget.formData.mailingCountry, 'mailingCountry'),
                          _buildDetailRow('Service Provider', widget.formData.serviceProvider, 'serviceProvider', 'File No', widget.formData.fileNo, 'fileNo'),
                          _buildDetailRow('Reference No', widget.formData.referenceNo, 'referenceNo', 'Sim No', widget.formData.simNo, 'simNo'),
                          _buildDetailRow('IMSI 1', widget.formData.imsi1, 'imsi1', 'IMSI 2', widget.formData.imsi2, 'imsi2'),
                          _buildDetailRow('Type Of Plan', widget.formData.typeOfPlan, 'typeOfPlan', 'Credit Card Type', widget.formData.creditCardType, 'creditCardType'),
                          _buildDetailRow('Contract Value', widget.formData.contractValue, 'contractValue', 'Date Of Issue', widget.formData.dateOfIssue, 'dateOfIssue'),
                          _buildDetailRow('Date Of Renewal', widget.formData.dateOfRenewal, 'dateOfRenewal', 'Installment', widget.formData.installment, 'installment'),
                          _buildDetailRow('Amount In Words', widget.formData.amountInWords, 'amountInWords', 'Remarks', widget.formData.remarks, 'remarks'),
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

  Widget _buildDetailRow(String label1, String val1, String key1, String label2, String val2, String key2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: _buildDetailItem(label1, val1, key1)),
          Expanded(child: _buildDetailItem(label2, val2, key2)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, String key) {
    final isMistake = widget.formData.mistakes?.contains(key) ?? false;
    
    return Container(
      padding: const EdgeInsets.all(6.0),
      decoration: isMistake ? BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '-' : value, style: TextStyle(
            fontSize: 14,
            color: isMistake ? Colors.red : null,
            fontWeight: isMistake ? FontWeight.bold : FontWeight.normal,
          )),
        ],
      ),
    );
  }


}
