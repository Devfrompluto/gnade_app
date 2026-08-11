import 'dart:convert';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../domain/entities/printer_device.dart';

const String _savedPrintersPrefsKey = 'saved_thermal_printers_v1';

class SavedPrintersNotifier extends StateNotifier<List<PrinterDevice>> {
  SavedPrintersNotifier() : super(const []) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_savedPrintersPrefsKey);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(rawJson) as List<dynamic>;
        final loaded = list
            .map((item) => PrinterDevice.fromMap(Map<String, dynamic>.from(item)))
            .toList();
        state = loaded;
      } catch (_) {
        state = const [];
      }
    } else {
      state = const [];
    }
  }

  Future<void> _saveToPrefs(List<PrinterDevice> printers) async {
    state = printers;
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(printers.map((p) => p.toMap()).toList());
    await prefs.setString(_savedPrintersPrefsKey, jsonStr);
  }

  Future<void> addPrinter(PrinterDevice printer) async {
    final bool isFirst = state.isEmpty;
    final updatedPrinter = printer.copyWith(
      isDefault: printer.isDefault || isFirst,
    );

    List<PrinterDevice> newList;
    if (updatedPrinter.isDefault) {
      newList = state.map((p) => p.copyWith(isDefault: false)).toList();
      newList.add(updatedPrinter);
    } else {
      newList = [...state, updatedPrinter];
    }

    await _saveToPrefs(newList);
  }

  Future<void> removePrinter(String id) async {
    final newList = state.where((p) => p.id != id).toList();
    if (newList.isNotEmpty && !newList.any((p) => p.isDefault)) {
      newList[0] = newList[0].copyWith(isDefault: true);
    }
    await _saveToPrefs(newList);
  }

  Future<void> setDefaultPrinter(String id) async {
    final newList = state.map((p) {
      return p.copyWith(isDefault: p.id == id);
    }).toList();
    await _saveToPrefs(newList);
  }
}

final savedPrintersProvider =
    StateNotifierProvider<SavedPrintersNotifier, List<PrinterDevice>>((ref) {
  return SavedPrintersNotifier();
});

final defaultPrinterProvider = Provider<PrinterDevice?>((ref) {
  final printers = ref.watch(savedPrintersProvider);
  if (printers.isEmpty) return null;
  return printers.firstWhere(
    (p) => p.isDefault,
    orElse: () => printers.first,
  );
});

/// Helper method to check if a default printer is configured.
/// If no printer exists, shows a dialog prompting the user to set up a printer.
/// Returns true if printer exists, false if dialog was shown.
bool checkAndPromptPrinterSetup(BuildContext context, WidgetRef ref) {
  final defaultPrinter = ref.read(defaultPrinterProvider);
  if (defaultPrinter == null) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.print_disabled_rounded,
                color: const Color(0xFF1E40AF),
                size: 22.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'No Printer Set Up',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'You have not added or set a default thermal printer yet. Would you like to set up a printer now?',
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 13.sp,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E40AF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push(AppRoutes.savedPrinters);
            },
            child: Text(
              'Set Up Printer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return false;
  }
  return true;
}
