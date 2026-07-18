import 'package:gnade_app/src/imports/imports.dart';
import '../../domain/entities/staff_member.dart';

class ResetPinSheet extends StatefulWidget {
  final StaffMember member;
  final Future<void> Function(String newPin) onConfirm;

  const ResetPinSheet({
    required this.member,
    required this.onConfirm,
    super.key,
  });

  @override
  State<ResetPinSheet> createState() => _ResetPinSheetState();
}

class _ResetPinSheetState extends State<ResetPinSheet> {
  final _pinCtr = TextEditingController();
  final _pin2Ctr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _pinCtr.dispose();
    _pin2Ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reset PIN for ${widget.member.fullName}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter a new 4–6 digit PIN',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'New PIN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            AppTextField(
              controller: _pinCtr,
              hint: '....',
              prefixIcon: const Icon(Icons.lock_outline),
              obscureText: _obscure,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) =>
                  (v?.length ?? 0) < 4 ? 'PIN must be at least 4 digits' : null,
            ),
            const SizedBox(height: 12),
            
            const Text(
              'Confirm New PIN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            AppTextField(
              controller: _pin2Ctr,
              hint: '....',
              prefixIcon: const Icon(Icons.lock_outline),
              obscureText: _obscure,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) =>
                  v != _pinCtr.text ? 'PINs do not match' : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Update PIN',
              isLoading: _loading,
              isFullWidth: true,
              onPressed: _loading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await widget.onConfirm(_pinCtr.text);
    setState(() => _loading = false);
  }
}
