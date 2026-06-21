import 'package:gnade_app/src/imports/imports.dart';
import '../../domain/entities/customer.dart';

class CustomerListNotifier extends StateNotifier<List<CustomerMock>> {
  CustomerListNotifier() : super(_initialCustomers);

  static final List<CustomerMock> _initialCustomers = [
    const CustomerMock(
      id: 'c1',
      name: 'Oluwaseun Adeyemi',
      phone: '0803 123 4567',
      initialsColor: Color(0xFF0F2C59), // Deep Slate/Navy
    ),
    const CustomerMock(
      id: 'c2',
      name: 'Chidi Okonkwo',
      phone: '0812 987 6543',
      initialsColor: Color(0xFF0D9488), // Teal
    ),
    const CustomerMock(
      id: 'c3',
      name: 'Fatima Bello',
      phone: '0705 555 1234',
      initialsColor: Color(0xFF7C3AED), // Purple
    ),
    const CustomerMock(
      id: 'c4',
      name: 'Emeka Eze',
      phone: '0902 333 8888',
      initialsColor: Color(0xFF059669), // Emerald
    ),
    const CustomerMock(
      id: 'c5',
      name: 'Aisha Mohammed',
      phone: '0808 777 9999',
      initialsColor: Color(0xFFD97706), // Amber
    ),
    const CustomerMock(
      id: 'c6',
      name: 'Kehinde Ojo',
      phone: '0814 222 5555',
      initialsColor: Color(0xFF1E293B), // Slate
    ),
    const CustomerMock(
      id: 'c7',
      name: 'Michael Abiodun',
      phone: '0701 444 6666',
      initialsColor: Color(0xFF0D9488), // Teal/Green
    ),
  ];

  void addCustomer(CustomerMock customer) {
    state = [customer, ...state];
  }
}

// Manual provider definition (per project rules - no riverpod_generator)
final customerListProvider = StateNotifierProvider<CustomerListNotifier, List<CustomerMock>>((ref) {
  return CustomerListNotifier();
});
