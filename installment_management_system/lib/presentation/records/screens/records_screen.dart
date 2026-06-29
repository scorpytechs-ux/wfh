import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../customer/viewmodels/customer_viewmodel.dart';
import '../../customer/screens/customer_form_screen.dart';
import '../../files/screens/customer_documents_screen.dart';
import '../../../core/theme/app_theme.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerViewModelProvider.notifier).loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      ref.read(customerViewModelProvider.notifier).loadCustomers();
    } else {
      ref.read(customerViewModelProvider.notifier).searchCustomers(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerViewModelProvider);
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    final dateFormatter = DateFormat('yyyy-MM-dd');

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Record Management',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: const InputDecoration(
              labelText: 'Search by Name, Contract, or Mobile',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(child: Text('Error: ${state.error}', style: const TextStyle(color: AppTheme.errorColor)))
                      : state.customers.isEmpty
                          ? const Center(child: Text('No records found.'))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  showCheckboxColumn: false,
                                  columns: const [
                                    DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Contract Number', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Installment Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Date Created', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: state.customers.map((c) {
                                    return DataRow(
                                      onSelectChanged: (_) {
                                        // Push edit screen or show details
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => Scaffold(
                                            appBar: AppBar(title: const Text('Edit Customer')),
                                            body: CustomerFormScreen(customerToEdit: c),
                                          )),
                                        ).then((_) {
                                          ref.read(customerViewModelProvider.notifier).loadCustomers();
                                        });
                                      },
                                      cells: [
                                        DataCell(Text(c.customerName)),
                                        DataCell(Text(c.contractNumber)),
                                        DataCell(Text(currencyFormatter.format(c.installmentAmount))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: c.status == 'Active' ? AppTheme.successColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              c.status,
                                              style: TextStyle(
                                                color: c.status == 'Active' ? AppTheme.successColor : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(dateFormatter.format(c.createdAt))),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.folder, color: AppTheme.secondaryColor),
                                            tooltip: 'Manage Files',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => CustomerDocumentsScreen(customer: c)),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
