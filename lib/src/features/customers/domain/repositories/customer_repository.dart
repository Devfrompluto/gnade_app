import 'package:gnade_app/src/imports/imports.dart';

abstract class CustomerRepository {
  FutureEither<List<Customer>> getCustomers(String businessId);
  FutureEither<Customer> createCustomer({
    required String businessId,
    required String name,
    required String phone,
    String? email,
    String? address,
    String? notes,
  });
  FutureEither<Customer> updateCustomer({
    required String id,
    required String name,
    required String phone,
    String? email,
    String? address,
    String? notes,
  });
  FutureEither<void> deleteCustomer(String id);
}
