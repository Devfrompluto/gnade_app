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
}
