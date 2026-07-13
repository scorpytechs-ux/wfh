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
    final forms = ref.watch(projectStateProvider);
    final formData = forms.firstWhere(
      (f) => f.id == widget.formData.id,
      orElse: () => widget.formData,
    );

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
                Text('Details (Form ${formData.serialNo} of 18)', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Text('Form Details', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                          _buildDetailRow('Serial No', formData.serialNo, 'serialNo', 'Title', formData.title, 'title', formData.mistakes),
                          _buildDetailRow('First Name', formData.firstName, 'firstName', 'Last Name', formData.lastName, 'lastName', formData.mistakes),
                          _buildDetailRow('Initial', formData.initial, 'initial', 'Email', formData.email, 'email', formData.mistakes),
                          _buildDetailRow('Father Name', formData.fatherName, 'fatherName', 'DOB', formData.dob, 'dob', formData.mistakes),
                          _buildDetailRow('Gender', formData.gender, 'gender', 'Profession', formData.profession, 'profession', formData.mistakes),
                          _buildDetailRow('Mailing Street', formData.mailingStreet, 'mailingStreet', 'Mailing City', formData.mailingCity, 'mailingCity', formData.mistakes),
                          _buildDetailRow('Mailing Postal', formData.mailingPostal, 'mailingPostal', 'Mailing Country', formData.mailingCountry, 'mailingCountry', formData.mistakes),
                          _buildDetailRow('Service Provider', formData.serviceProvider, 'serviceProvider', 'File No', formData.fileNo, 'fileNo', formData.mistakes),
                          _buildDetailRow('Reference No', formData.referenceNo, 'referenceNo', 'Sim No', formData.simNo, 'simNo', formData.mistakes),
                          _buildDetailRow('IMSI 1', formData.imsi1, 'imsi1', 'IMSI 2', formData.imsi2, 'imsi2', formData.mistakes),
                          _buildDetailRow('Type Of Plan', formData.typeOfPlan, 'typeOfPlan', 'Credit Card Type', formData.creditCardType, 'creditCardType', formData.mistakes),
                          _buildDetailRow('Contract Value', formData.contractValue, 'contractValue', 'Date Of Issue', formData.dateOfIssue, 'dateOfIssue', formData.mistakes),
                          _buildDetailRow('Date Of Renewal', formData.dateOfRenewal, 'dateOfRenewal', 'Installment', formData.installment, 'installment', formData.mistakes),
                          _buildDetailRow('Amount In Words', formData.amountInWords, 'amountInWords', 'Remarks', formData.remarks, 'remarks', formData.mistakes),
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

  Widget _buildDetailRow(String label1, String val1, String key1, String label2, String val2, String key2, List<String>? mistakes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: _buildDetailItem(label1, val1, key1, mistakes)),
          Expanded(child: _buildDetailItem(label2, val2, key2, mistakes)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, String key, List<String>? mistakes) {
    final isMistake = mistakes?.contains(key) ?? false;
    
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
