import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/database_helper.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final DatabaseHelper _databaseHelper;

  CustomerRepositoryImpl(this._databaseHelper);

  @override
  Future<void> insertCustomer(Customer customer) async {
    final db = await _databaseHelper.database;
    await db.insert('customers', CustomerModel.fromEntity(customer).toJson());
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final db = await _databaseHelper.database;
    await db.update(
      'customers',
      CustomerModel.fromEntity(customer).toJson(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  @override
  Future<void> deleteCustomer(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return CustomerModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<List<Customer>> getAllCustomers() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('customers', orderBy: 'createdAt DESC');
    return maps.map((map) => CustomerModel.fromJson(map)).toList();
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'customers',
      where: 'customerName LIKE ? OR contractNumber LIKE ? OR mobile LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => CustomerModel.fromJson(map)).toList();
  }
}
