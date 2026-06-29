import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<void> insertCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
  Future<Customer?> getCustomerById(String id);
  Future<List<Customer>> getAllCustomers();
  Future<List<Customer>> searchCustomers(String query);
}
