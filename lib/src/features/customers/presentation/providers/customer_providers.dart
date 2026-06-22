import 'package:gnade_app/src/imports/imports.dart';
import '../../domain/entities/customer.dart';

enum CustomerFilterType { all, debtors, depositers }

class CustomerListNotifier extends StateNotifier<List<CustomerMock>> {
  CustomerListNotifier() : super(_initialCustomers);

  static final List<CustomerMock> _initialCustomers = [
    const CustomerMock(
      id: 'c1',
      name: 'Christ',
      phone: '0803 123 4567',
      initialsColor: Color(0xFF7C3AED), // Purple
      purchasesCount: 8,
      balance: 0,
      lastSeen: 'Today, 10:45 AM',
      orders: [
        CustomerOrderMock(
          id: '#ORD-992',
          status: 'PAID',
          date: 'Today, 10:45 AM',
          itemsCount: 3,
          amount: '8,400',
        ),
      ],
    ),
    const CustomerMock(
      id: 'c2',
      name: 'Aunty Grace Store',
      phone: '0812 987 6543',
      initialsColor: Color(0xFF1E3A8A), // Deep Slate/Navy
      purchasesCount: 15,
      balance: -12500, // Owed 12,500
      lastSeen: '2 days ago',
      orders: [
        CustomerOrderMock(
          id: '#ORD-985',
          status: 'UNPAID',
          date: '2 days ago',
          itemsCount: 1,
          amount: '12,500',
        ),
      ],
    ),
    const CustomerMock(
      id: 'c3',
      name: 'Honorable Lara',
      phone: '0705 555 1234',
      initialsColor: Color(0xFF0D9488), // Teal
      purchasesCount: 22,
      balance: 5000, // Deposit 5,000
      lastSeen: '1 week ago',
      orders: [
        CustomerOrderMock(
          id: '#ORD-910',
          status: 'PAID',
          date: '1 week ago',
          itemsCount: 5,
          amount: '21,000',
        ),
      ],
    ),
    const CustomerMock(
      id: 'c4',
      name: 'Mr Wale',
      phone: '0902 333 8888',
      initialsColor: Color(0xFF1E293B), // Slate
      purchasesCount: 5,
      balance: 0,
      lastSeen: 'Yesterday',
    ),
    const CustomerMock(
      id: 'c5',
      name: 'Amina Yusuf',
      phone: '0803 123 4567',
      initialsColor: Color(0xFF7C3AED), // Purple
      purchasesCount: 42,
      balance: -12500, // Owed 12,500
      lastSeen: '2d ago',
      notes: 'A key retailer from central market.',
      orders: [
        CustomerOrderMock(
          id: '#ORD-992',
          status: 'PAID',
          date: 'Today, 10:45 AM',
          itemsCount: 3,
          amount: '8,400',
        ),
        CustomerOrderMock(
          id: '#ORD-985',
          status: 'UNPAID',
          date: 'Oct 24, 2023',
          itemsCount: 1,
          amount: '12,500',
        ),
        CustomerOrderMock(
          id: '#ORD-910',
          status: 'PAID',
          date: 'Oct 12, 2023',
          itemsCount: 5,
          amount: '21,000',
        ),
      ],
    ),
    const CustomerMock(
      id: 'c6',
      name: 'Kehinde Ojo',
      phone: '0814 222 5555',
      initialsColor: Color(0xFFD97706), // Amber
      purchasesCount: 3,
      balance: 0,
      lastSeen: '3 days ago',
    ),
    const CustomerMock(
      id: 'c7',
      name: 'Michael Abiodun',
      phone: '0701 444 6666',
      initialsColor: Color(0xFF059669), // Emerald
      purchasesCount: 12,
      balance: -3500, // Owed 3,500
      lastSeen: '4 days ago',
    ),
  ];

  void addCustomer(CustomerMock customer) {
    state = [customer, ...state];
  }
}

// State Providers
final customerListProvider = StateNotifierProvider<CustomerListNotifier, List<CustomerMock>>((ref) {
  return CustomerListNotifier();
});

final customerFilterProvider = StateProvider<CustomerFilterType>((ref) {
  return CustomerFilterType.all;
});

final customerSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

// Computed list provider
final filteredCustomersProvider = Provider<List<CustomerMock>>((ref) {
  final customers = ref.watch(customerListProvider);
  final filter = ref.watch(customerFilterProvider);
  final query = ref.watch(customerSearchQueryProvider).toLowerCase().trim();

  List<CustomerMock> list = customers;

  // 1. Search Query filter
  if (query.isNotEmpty) {
    list = list.where((c) => c.name.toLowerCase().contains(query) || c.phone.contains(query)).toList();
  }

  // 2. Pill filters
  if (filter == CustomerFilterType.debtors) {
    list = list.where((c) => c.balance < 0).toList();
  } else if (filter == CustomerFilterType.depositers) {
    list = list.where((c) => c.balance > 0).toList();
  }

  return list;
});
