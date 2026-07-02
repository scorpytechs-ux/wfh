import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../data/repositories/form_repository.dart';
import '../../files/state/form_data_model.dart';
import '../../../core/theme/app_theme.dart';

class ScoredFormsScreen extends ConsumerStatefulWidget {
  const ScoredFormsScreen({super.key});

  @override
  ConsumerState<ScoredFormsScreen> createState() => _ScoredFormsScreenState();
}

class _ScoredFormsScreenState extends ConsumerState<ScoredFormsScreen> {
  bool _isLoading = true;
  List<FormDataModel> _forms = [];

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    final user = ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      final formRepo = FormRepository();
      final allForms = await formRepo.getSentFormsForUser(user['id']);
      setState(() {
        _forms = allForms;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Reviewed Forms', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _forms.isEmpty
              ? const Center(
                  child: Text(
                    'No reviewed forms available yet.',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _forms.length,
                  itemBuilder: (context, index) {
                    final form = _forms[index];
                    List<String> mistakesList = [];
                    try {
                      if (form.mistakes != null) {
                        mistakesList = form.mistakes!;
                      }
                    } catch (_) {}

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
                ),
    );
  }
}
