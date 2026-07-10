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
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('DOB')),
                              DataColumn(label: Text('Gender')),
                              DataColumn(label: Text('Profession')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: forms.map((form) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(form.serialNo.isEmpty ? '-' : form.serialNo)),
                                  DataCell(Text(form.serialNo)),
                                  DataCell(Text(form.title)),
                                  DataCell(Text(form.firstName)),
                                  DataCell(Text(form.lastName)),
                                  DataCell(Text(form.email)),
                                  DataCell(Text(form.dob)),
                                  DataCell(Text(form.gender)),
                                  DataCell(Text(form.profession)),
                                  DataCell(
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue, 
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.visibility, color: Colors.white, size: 16),
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
