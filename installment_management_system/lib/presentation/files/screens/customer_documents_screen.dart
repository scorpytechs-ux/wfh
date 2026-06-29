import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../viewmodels/document_viewmodel.dart';
import '../../../domain/entities/customer.dart';
import '../../../core/theme/app_theme.dart';

class CustomerDocumentsScreen extends ConsumerStatefulWidget {
  final Customer customer;

  const CustomerDocumentsScreen({super.key, required this.customer});

  @override
  ConsumerState<CustomerDocumentsScreen> createState() => _CustomerDocumentsScreenState();
}

class _CustomerDocumentsScreenState extends ConsumerState<CustomerDocumentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(documentViewModelProvider.notifier).loadDocuments(widget.customer.id));
  }

  void _handleUpload(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final success = await ref.read(documentViewModelProvider.notifier).uploadDocument(
        customerId: widget.customer.id,
        filePath: file.path,
        documentType: 'Uploaded File',
        description: 'Uploaded document',
      );
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded'), backgroundColor: AppTheme.successColor),
        );
      }
    }
  }

  void _handlePreview(String filePath) async {
    final uri = Uri.file(filePath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentViewModelProvider);
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Documents - ${widget.customer.customerName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => _handleUpload(context),
            tooltip: 'Upload Document',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No documents uploaded yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _handleUpload(context),
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload File'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(32),
                  itemCount: state.documents.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final doc = state.documents[index];
                    return ListTile(
                      leading: Icon(
                        doc.fileName.endsWith('.pdf') ? Icons.picture_as_pdf :
                        doc.fileName.endsWith('.docx') ? Icons.description :
                        Icons.image,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      title: Text(doc.fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Uploaded on ${dateFormatter.format(doc.uploadedAt)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, color: AppTheme.secondaryColor),
                            onPressed: () => _handlePreview(doc.filePath),
                            tooltip: 'Preview / Open',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete Document'),
                                  content: const Text('Are you sure?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref.read(documentViewModelProvider.notifier).deleteDocument(doc.id, widget.customer.id);
                              }
                            },
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
