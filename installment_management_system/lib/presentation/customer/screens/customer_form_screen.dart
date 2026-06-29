import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../../../domain/entities/customer.dart';
import '../../../core/theme/app_theme.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  final Customer? customerToEdit;

  const CustomerFormScreen({super.key, this.customerToEdit});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _contractNumController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _contractValController;
  late TextEditingController _contractMonthsController;
  late TextEditingController _installmentAmtController;
  
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 30));
  String _selectedStatus = 'Active';
  final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final c = widget.customerToEdit;
    _nameController = TextEditingController(text: c?.customerName ?? '');
    _contractNumController = TextEditingController(text: c?.contractNumber ?? '');
    _mobileController = TextEditingController(text: c?.mobile ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _contractValController = TextEditingController(text: c?.contractValue.toString() ?? '');
    _contractMonthsController = TextEditingController(text: c?.contractMonths.toString() ?? '');
    _installmentAmtController = TextEditingController(text: c?.installmentAmount.toString() ?? '');
    
    if (c != null) {
      _selectedDate = c.dob ?? DateTime.now();
      _selectedStatus = c.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contractNumController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _contractValController.dispose();
    _contractMonthsController.dispose();
    _installmentAmtController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(customerViewModelProvider.notifier).saveCustomer(
        id: widget.customerToEdit?.id,
        name: _nameController.text.trim(),
        contractNumber: _contractNumController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        dob: _selectedDate,
        contractValue: double.tryParse(_contractValController.text) ?? 0.0,
        contractMonths: int.tryParse(_contractMonthsController.text) ?? 0,
        installmentAmount: double.tryParse(_installmentAmtController.text) ?? 0.0,
        status: _selectedStatus,
      );

      if (!context.mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer saved successfully'), backgroundColor: AppTheme.successColor),
        );
        if (widget.customerToEdit == null) {
          _formKey.currentState!.reset();
          _nameController.clear();
          _contractNumController.clear();
          _mobileController.clear();
          _emailController.clear();
          _addressController.clear();
          _contractValController.clear();
          _contractMonthsController.clear();
          _installmentAmtController.clear();
        }
      } else {
        final error = ref.read(customerViewModelProvider).error;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error'), backgroundColor: AppTheme.errorColor),
          );
        }
      }
    }
  }

  void _deleteCustomer() async {
    if (widget.customerToEdit == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(customerViewModelProvider.notifier).deleteCustomer(widget.customerToEdit!.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer deleted'), backgroundColor: AppTheme.successColor),
        );
        Navigator.pop(context); // Go back if editing from another screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.customerToEdit == null ? 'New Customer Registration' : 'Edit Customer',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 32),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Customer Name'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _contractNumController,
                            decoration: const InputDecoration(labelText: 'Contract Number'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _mobileController,
                            decoration: const InputDecoration(labelText: 'Mobile Number'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email Address'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Full Address'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Date of Birth'),
                              child: Text(_dateFormat.format(_selectedDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedStatus,
                            decoration: const InputDecoration(labelText: 'Status'),
                            items: ['Active', 'Pending', 'Completed', 'Cancelled'].map((s) {
                              return DropdownMenuItem(value: s, child: Text(s));
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedStatus = v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Contract Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _contractValController,
                            decoration: const InputDecoration(labelText: 'Contract Value', prefixText: '\$'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _contractMonthsController,
                            decoration: const InputDecoration(labelText: 'Duration (Months)'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _installmentAmtController,
                            decoration: const InputDecoration(labelText: 'Installment Amount', prefixText: '\$'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.customerToEdit != null) ...[
                          OutlinedButton.icon(
                            onPressed: _deleteCustomer,
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorColor, side: const BorderSide(color: AppTheme.errorColor)),
                          ),
                          const SizedBox(width: 16),
                        ],
                        OutlinedButton(
                          onPressed: () {
                            if (widget.customerToEdit == null) {
                              _formKey.currentState!.reset();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Cancel/Reset'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _saveForm,
                          icon: const Icon(Icons.save),
                          label: Text(widget.customerToEdit == null ? 'Save Customer' : 'Update Customer'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
