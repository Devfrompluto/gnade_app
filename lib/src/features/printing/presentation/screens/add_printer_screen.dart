import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/printer_providers.dart';
import '../../domain/entities/printer_device.dart';

class AddPrinterScreen extends ConsumerStatefulWidget {
  const AddPrinterScreen({super.key});

  @override
  ConsumerState<AddPrinterScreen> createState() => _AddPrinterScreenState();
}

class _AddPrinterScreenState extends ConsumerState<AddPrinterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedType = 'bluetooth'; // bluetooth | wifi | usb
  int _selectedPaperWidth = 80; // 58 or 80 mm
  bool _isDefault = false;

  bool _isScanning = false;
  List<Printer> _discoveredPrinters = [];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _discoveredPrinters = [];
    });

    try {
      final flutterThermalPrinter = FlutterThermalPrinter.instance;

      List<ConnectionType> connectionTypesToScan;
      if (_selectedType == 'wifi') {
        connectionTypesToScan = ConnectionType.values.where((c) {
          final n = c.name.toLowerCase();
          return n.contains('net') || n.contains('wifi');
        }).toList();
        if (connectionTypesToScan.isEmpty) connectionTypesToScan = ConnectionType.values;
      } else if (_selectedType == 'usb') {
        connectionTypesToScan = ConnectionType.values.where((c) {
          return c.name.toLowerCase().contains('usb');
        }).toList();
        if (connectionTypesToScan.isEmpty) connectionTypesToScan = ConnectionType.values;
      } else {
        connectionTypesToScan = ConnectionType.values.where((c) {
          final n = c.name.toLowerCase();
          return n.contains('ble') || n.contains('blue');
        }).toList();
        if (connectionTypesToScan.isEmpty) connectionTypesToScan = ConnectionType.values;
      }

      await flutterThermalPrinter.getPrinters(
        connectionTypes: connectionTypesToScan,
      );

      flutterThermalPrinter.devicesStream.listen((devices) {
        if (mounted) {
          setState(() {
            _discoveredPrinters = devices;
            _isScanning = false;
          });
        }
      });

      Future.delayed(const Duration(seconds: 6), () {
        if (mounted && _isScanning) {
          setState(() => _isScanning = false);
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _selectDiscoveredPrinter(Printer printer) {
    setState(() {
      _nameController.text = printer.name ?? 'Thermal Printer';
      _addressController.text = printer.address ?? printer.vendorId ?? '';
      final connName = printer.connectionType?.name.toLowerCase() ?? '';
      if (connName.contains('net') || connName.contains('wifi')) {
        _selectedType = 'wifi';
      } else if (connName.contains('usb')) {
        _selectedType = 'usb';
      } else {
        _selectedType = 'bluetooth';
      }
    });

    showGlobalToast(
      message: 'Selected ${printer.name ?? "Printer"}',
      status: 'success',
    );
  }

  void _savePrinter() {
    if (!_formKey.currentState!.validate()) return;

    final printer = PrinterDevice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      type: _selectedType,
      address: _addressController.text.trim(),
      paperWidth: _selectedPaperWidth,
      isDefault: _isDefault,
    );

    ref.read(savedPrintersProvider.notifier).addPrinter(printer);
    showGlobalToast(message: '${printer.name} saved successfully!');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF0F172A), size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Printer',
          style: TextStyle(
            color: const Color(0xFF1E40AF),
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Scan / Import Paired Devices Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bluetooth_searching_rounded, color: const Color(0xFF1E40AF), size: 20.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Paired & Discovered Devices',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _startScan,
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: _isScanning
                                  ? SizedBox(
                                      width: 14.w,
                                      height: 14.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF1E40AF),
                                      ),
                                    )
                                  : Icon(Icons.refresh_rounded, color: const Color(0xFF1E40AF), size: 18.sp),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Tap a connected or paired printer to automatically import its details.',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      if (_discoveredPrinters.isNotEmpty) ...[
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _discoveredPrinters.map((p) {
                            return InkWell(
                              onTap: () => _selectDiscoveredPrinter(p),
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: const Color(0xFF2563EB)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                     Icon(
                                       (p.connectionType?.name.toLowerCase() ?? '').contains('net') || (p.connectionType?.name.toLowerCase() ?? '').contains('wifi') ? Icons.wifi : Icons.bluetooth,
                                       size: 14.sp,
                                       color: const Color(0xFF1E40AF),
                                     ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      p.name ?? 'Thermal Printer',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        Text(
                          _isScanning ? 'Scanning nearby devices...' : 'No active devices found automatically. You can enter details manually below.',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // 2. Connection Type Selector
                Text(
                  'Connection Type',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildTypeChip('bluetooth', 'Bluetooth', Icons.bluetooth),
                    SizedBox(width: 10.w),
                    _buildTypeChip('wifi', 'WiFi / Net', Icons.wifi),
                    SizedBox(width: 10.w),
                    _buildTypeChip('usb', 'USB', Icons.usb),
                  ],
                ),
                SizedBox(height: 20.h),

                // 3. Printer Name Field
                Text(
                  'Printer Name',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6.h),
                AppTextField(
                  controller: _nameController,
                  hint: 'e.g. 80mm Bluetooth Printer',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Printer name is required';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // 4. Address Field (MAC or IP)
                Text(
                  _selectedType == 'wifi' ? 'IP Address' : 'MAC / Address (Optional)',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6.h),
                AppTextField(
                  controller: _addressController,
                  hint: _selectedType == 'wifi' ? 'e.g. 192.168.1.105' : 'e.g. 00:11:22:33:44:55',
                ),
                if (_selectedType == 'wifi') ...[
                  SizedBox(height: 6.h),
                  Text(
                    'Ensure your phone and printer are on the same Wi-Fi network. Network printers connect over TCP Port 9100.',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
                SizedBox(height: 20.h),

                // 5. Paper Width Selector
                Text(
                  'Paper Size',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildPaperWidthChip(58, '58 mm (Standard Receipt)'),
                    SizedBox(width: 12.w),
                    _buildPaperWidthChip(80, '80 mm (Wide Receipt)'),
                  ],
                ),
                SizedBox(height: 24.h),

                // 6. Default Switch
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set as Default Printer',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Used automatically for 1-tap receipt printing',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isDefault,
                        activeThumbColor: const Color(0xFF1E40AF),
                        onChanged: (val) => setState(() => _isDefault = val),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // 7. Save Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _savePrinter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E40AF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Save Printer',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedType = type);
          _startScan();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
                size: 20.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaperWidthChip(int width, String label) {
    final isSelected = _selectedPaperWidth == width;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPaperWidth = width),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
