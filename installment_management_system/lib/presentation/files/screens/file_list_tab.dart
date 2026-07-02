import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../state/project_state_provider.dart';
import 'edit_form_screen.dart';

class FileListTab extends ConsumerWidget {
  const FileListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forms = ref.watch(projectStateProvider);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('List', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              child: forms.isEmpty
                  ? const Center(child: Text("No forms submitted yet. Go to Upload File tab to submit forms."))
                  : ListView(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(AppTheme.primaryColor.withOpacity(0.1)),
                            columns: const [
                              DataColumn(label: Text('#')),
                              DataColumn(label: Text('Serial No')),
                              DataColumn(label: Text('Title')),
                              DataColumn(label: Text('First Name')),
                              DataColumn(label: Text('Last Name')),
                              DataColumn(label: Text('Initial')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Father Name')),
                              DataColumn(label: Text('DOB')),
                              DataColumn(label: Text('Gender')),
                              DataColumn(label: Text('Profession')),
                              DataColumn(label: Text('Mailing Street')),
                              DataColumn(label: Text('Mailing City')),
                              DataColumn(label: Text('Mailing Postal')),
                              DataColumn(label: Text('Mailing Country')),
                              DataColumn(label: Text('Service Provider')),
                              DataColumn(label: Text('File No')),
                              DataColumn(label: Text('Reference No')),
                              DataColumn(label: Text('Sim No')),
                              DataColumn(label: Text('IMSI 1')),
                              DataColumn(label: Text('IMSI 2')),
                              DataColumn(label: Text('Type Of Plan')),
                              DataColumn(label: Text('Credit Card Type')),
                              DataColumn(label: Text('Contract Value')),
                              DataColumn(label: Text('Date Of Issue')),
                              DataColumn(label: Text('Date Of Renewal')),
                              DataColumn(label: Text('Installment')),
                              DataColumn(label: Text('Amount In Words')),
                              DataColumn(label: Text('Remarks')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: forms.map((form) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(form.serialNo.isEmpty ? '-' : form.serialNo)), // Treat as index or display serial
                                  DataCell(Text(form.serialNo)),
                                  DataCell(Text(form.title)),
                                  DataCell(Text(form.firstName)),
                                  DataCell(Text(form.lastName)),
                                  DataCell(Text(form.initial)),
                                  DataCell(Text(form.email)),
                                  DataCell(Text(form.fatherName)),
                                  DataCell(Text(form.dob)),
                                  DataCell(Text(form.gender)),
                                  DataCell(Text(form.profession)),
                                  DataCell(Text(form.mailingStreet)),
                                  DataCell(Text(form.mailingCity)),
                                  DataCell(Text(form.mailingPostal)),
                                  DataCell(Text(form.mailingCountry)),
                                  DataCell(Text(form.serviceProvider)),
                                  DataCell(Text(form.fileNo)),
                                  DataCell(Text(form.referenceNo)),
                                  DataCell(Text(form.simNo)),
                                  DataCell(Text(form.imsi1)),
                                  DataCell(Text(form.imsi2)),
                                  DataCell(Text(form.typeOfPlan)),
                                  DataCell(Text(form.creditCardType)),
                                  DataCell(Text(form.contractValue)),
                                  DataCell(Text(form.dateOfIssue)),
                                  DataCell(Text(form.dateOfRenewal)),
                                  DataCell(Text(form.installment)),
                                  DataCell(Text(form.amountInWords)),
                                  DataCell(Text(form.remarks)),
                                  DataCell(
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue, // Blue box with pen from video
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => EditFormScreen(formData: form),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        if (ref.read(projectStateProvider.notifier).hasMore)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  ref.read(projectStateProvider.notifier).loadMoreForms();
                                },
                                child: const Text('Load More'),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
