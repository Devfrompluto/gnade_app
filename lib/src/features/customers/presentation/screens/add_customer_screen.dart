import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/customer_providers.dart';
import '../widgets/widgets.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  final Customer? initialCustomer;

  const AddCustomerScreen({
    super.key,
    this.initialCustomer,
  });

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  bool get _isEditing => widget.initialCustomer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCustomer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCustomer() async {
    if (!await requireConnectivity()) return;
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();
    final notes = _notesController.text.trim();

    Customer? result;
    if (_isEditing) {
      result = await ref.read(customerListProvider.notifier).updateCustomer(
        id: widget.initialCustomer!.id,
        name: name,
        phone: phone,
        email: email.isNotEmpty ? email : null,
        address: address.isNotEmpty ? address : null,
        notes: notes.isNotEmpty ? notes : null,
      );
    } else {
      result = await ref.read(customerListProvider.notifier).addCustomer(
        name: name,
        phone: phone,
        email: email.isNotEmpty ? email : null,
        address: address.isNotEmpty ? address : null,
        notes: notes.isNotEmpty ? notes : null,
      );
    }

    if (!mounted) return;

    if (result != null) {
      showGlobalToast(
        message: _isEditing ? 'Customer updated successfully!' : 'Customer saved successfully!',
      );
      context.pop(result);
    } else {
      showGlobalToast(
        message: _isEditing ? 'Failed to update customer.' : 'Failed to save customer.',
        status: 'error',
      );
    }
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
        appBar: AppCustomAppBar(
          title: _isEditing ? 'Edit Customer' : 'Add Customer',
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
