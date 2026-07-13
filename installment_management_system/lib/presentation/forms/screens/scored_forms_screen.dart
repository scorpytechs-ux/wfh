import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../files/state/form_data_model.dart';
import '../../../core/theme/app_theme.dart';

class ScoredFormsScreen extends ConsumerWidget {
  const ScoredFormsScreen({super.key});

  Widget _renderField(String label, String value, bool isMistake) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              padding: isMistake ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2) : null,
              decoration: isMistake
                  ? BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    )
                  : null,
              child: Text(
                value.isEmpty ? 'N/A' : value,
                style: TextStyle(
                  color: isMistake ? Colors.red.shade700 : Colors.black87,
                  fontWeight: isMistake ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Reviewed Forms', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: user == null
          ? const Center(child: Text("Not logged in."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('forms')
                  .where('userId', isEqualTo: user['id'])
                  .where('status', isEqualTo: 'sent')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No reviewed forms available yet.',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  );
                }

                final forms = snapshot.data!.docs.map((doc) {
                  final docData = doc.data() as Map<String, dynamic>;
                  List<dynamic> parsedMistakes = [];
                  if (docData['mistakes'] is String) {
                    try { parsedMistakes = jsonDecode(docData['mistakes']); } catch (_) {}
                  } else if (docData['mistakes'] is List) {
                    parsedMistakes = docData['mistakes'];
                  }
                  
                  return FormDataModel(
                    id: docData['id'] as String? ?? '',
                    serialNo: docData['serialNo']?.toString() ?? '',
                    title: docData['title'] as String? ?? '',
                    firstName: docData['firstName'] as String? ?? '',
                    lastName: docData['lastName'] as String? ?? '',
                    initial: docData['initial'] as String? ?? '',
                    email: docData['email'] as String? ?? '',
                    fatherName: docData['fatherName'] as String? ?? '',
                    dob: docData['dob'] as String? ?? '',
                    gender: docData['gender'] as String? ?? '',
                    profession: docData['profession'] as String? ?? '',
                    mailingStreet: docData['mailingStreet'] as String? ?? '',
                    mailingCity: docData['mailingCity'] as String? ?? '',
                    mailingPostal: docData['mailingPostal']?.toString() ?? '',
                    mailingCountry: docData['mailingCountry'] as String? ?? '',
                    serviceProvider: docData['serviceProvider'] as String? ?? '',
                    fileNo: docData['fileNo'] as String? ?? '',
                    referenceNo: docData['referenceNo'] as String? ?? '',
                    simNo: docData['simNo'] as String? ?? '',
                    typeOfNetwork: docData['typeOfNetwork'] as String? ?? '',
                    cellModelNo: docData['cellModelNo'] as String? ?? '',
                    imsi1: docData['imsi1'] as String? ?? '',
                    imsi2: docData['imsi2'] as String? ?? '',
                    typeOfPlan: docData['typeOfPlan'] as String? ?? '',
                    creditCardType: docData['creditCardType'] as String? ?? '',
                    contractValue: docData['contractValue']?.toString() ?? '',
                    dateOfIssue: docData['dateOfIssue'] as String? ?? '',
                    dateOfRenewal: docData['dateOfRenewal'] as String? ?? '',
                    installment: docData['installment']?.toString() ?? '',
                    amountInWords: docData['amountInWords'] as String? ?? '',
                    remarks: docData['remarks'] as String? ?? '',
                    score: (docData['score'] as num?)?.toDouble() ?? 0.0,
                    mistakes: parsedMistakes.map((e) => e.toString()).toList(),
                    status: docData['status'] as String? ?? 'pending',
                    submittedDate: docData['submittedDate'] as String?,
                  );
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: forms.length,
                  itemBuilder: (context, index) {
                    final form = forms[index];
                    final mistakesList = form.mistakes ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 24),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.assignment_turned_in, color: AppTheme.primaryColor),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Serial No: ${form.serialNo}',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: (form.score ?? 0) >= 80 ? Colors.green.shade50 : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: (form.score ?? 0) >= 80 ? Colors.green.shade200 : Colors.red.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    'Accuracy Score: ${(form.score ?? 0).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (form.score ?? 0) >= 80 ? Colors.green.shade700 : Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _renderField('Title', form.title, mistakesList.contains('title')),
                                      _renderField('First Name', form.firstName, mistakesList.contains('firstName')),
                                      _renderField('Last Name', form.lastName, mistakesList.contains('lastName')),
                                      _renderField('Email', form.email, mistakesList.contains('email')),
                                      _renderField('Phone (Sim No)', form.simNo, mistakesList.contains('simNo')),
                                      _renderField('City', form.mailingCity, mistakesList.contains('mailingCity')),
                                      _renderField('Country', form.mailingCountry, mistakesList.contains('mailingCountry')),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _renderField('Contract Value', form.contractValue, mistakesList.contains('contractValue')),
                                      _renderField('Account No', form.fileNo, mistakesList.contains('fileNo')), // assuming accountNo is fileNo in DB
                                      _renderField('Installment', form.installment, mistakesList.contains('installment')),
                                      _renderField('Remarks', form.remarks, mistakesList.contains('remarks')),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

