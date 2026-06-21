import 'dart:math';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_providers.dart';
import '../widgets/widgets.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  final List<Color> _brandColors = [
    const Color(0xFF0F2C59), // Deep Navy
    const Color(0xFF0D9488), // Teal
    const Color(0xFF7C3AED), // Purple
    const Color(0xFF059669), // Emerald
    const Color(0xFFD97706), // Amber
    const Color(0xFF1E293B), // Slate
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();
    final notes = _notesController.text.trim();

    // Pick random brand color for initials badge
    final randomColor = _brandColors[Random().nextInt(_brandColors.length)];

    final newCustomer = CustomerMock(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email.isNotEmpty ? email : null,
      address: address.isNotEmpty ? address : null,
      notes: notes.isNotEmpty ? notes : null,
      initialsColor: randomColor,
    );

    // Save using Riverpod notifier with explicit generic type argument
    ref.read<CustomerListNotifier>(customerListProvider.notifier).addCustomer(newCustomer);

    showGlobalToast(message: 'Customer saved successfully!');
    context.pop();
  }

  Future<void> _importFromContacts() async {
    try {
      final contacts.PermissionStatus status = await contacts.FlutterContacts.permissions.request(contacts.PermissionType.read);
      if (status != contacts.PermissionStatus.granted) {
        showGlobalToast(message: 'Contacts permission not granted.');
        return;
      }

      final contact = await contacts.FlutterContacts.native.showPicker(
        properties: {
          contacts.ContactProperty.phone,
          contacts.ContactProperty.email,
        },
      );
      if (contact == null) return; // User cancelled

      final String? contactId = contact.id;
      if (contactId == null) {
        showGlobalToast(message: 'Could not identify contact.');
        return;
      }

      // Fetch full details
      final fullContact = await contacts.FlutterContacts.get(
        contactId,
        properties: {
          contacts.ContactProperty.phone,
          contacts.ContactProperty.email,
        },
      );
      if (fullContact == null) return;

      final name = (fullContact.displayName ?? '').trim();
      final phone = fullContact.phones.isNotEmpty
          ? (fullContact.phones.first.number).trim()
          : '';
      final email = fullContact.emails.isNotEmpty
          ? (fullContact.emails.first.address).trim()
          : '';

      if (name.isNotEmpty) {
        _nameController.text = name;
      }
      if (phone.isNotEmpty) {
        _phoneController.text = phone;
      }
      if (email.isNotEmpty) {
        _emailController.text = email;
      }

      showGlobalToast(message: 'Contact details imported successfully!');
    } catch (e) {
      AppLogger.error('Error importing contact: $e');
      showGlobalToast(message: 'Could not import details from contact.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: const AppCustomAppBar(
          title: 'Add Customer',
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding.w,
                    vertical: 16.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Import from Contacts Card Widget
                        ImportContactsButton(
                          onTap: _importFromContacts,
                        ),
                        SizedBox(height: 16.h),

                        // Core Customer Details Form Card
                        Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: const Color(0xFFF1F5F9),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomerInputField(
                                label: 'Customer Name *',
                                controller: _nameController,
                                icon: Icons.person_outline_rounded,
                                hint: 'Enter full name',
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter customer name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.h),
                              CustomerInputField(
                                label: 'Phone Number *',
                                controller: _phoneController,
                                icon: Icons.phone_outlined,
                                hint: 'e.g. 0801 234 5678',
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter phone number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.h),
                              CustomerInputField(
                                label: 'Email Address (Optional)',
                                controller: _emailController,
                                icon: Icons.mail_outline_rounded,
                                hint: 'name@example.com',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: 16.h),
                              CustomerInputField(
                                label: 'Residential Address (Optional)',
                                controller: _addressController,
                                icon: Icons.location_on_outlined,
                                hint: 'Street address, City',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Notes Optional Card Widget
                        CustomerNotesField(
                          controller: _notesController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer Save / Cancel Controls Widget
              AddCustomerFooter(
                onSavePressed: _saveCustomer,
                onCancelPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
