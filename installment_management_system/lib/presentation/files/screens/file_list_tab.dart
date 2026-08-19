import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../state/project_state_provider.dart';
import 'edit_form_screen.dart';

class FileListTab extends ConsumerStatefulWidget {
  const FileListTab({super.key});

  @override
  ConsumerState<FileListTab> createState() => _FileListTabState();
}

class _FileListTabState extends ConsumerState<FileListTab> {
  int _visibleCount = 50;

  @override
  Widget build(BuildContext context) {
    final forms = ref.watch(projectStateProvider);
    final displayedForms = forms.take(_visibleCount).toList();
    final hasMore = forms.length > _visibleCount;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('List (${forms.length} total)', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                            rows: displayedForms.asMap().entries.map((entry) {
                              final index = entry.key;
                              final form = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(Text(form.formNumber != null ? '${form.formNumber}' : '${index + 1}')),
                                  DataCell(Text(form.serialNo.isEmpty ? '-' : form.serialNo)),
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
                        if (hasMore)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _visibleCount += 50;
                                  });
                                },
                                child: Text('Load More (${forms.length - _visibleCount} remaining)'),
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
