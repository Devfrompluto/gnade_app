import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/printer_providers.dart';
import '../../domain/entities/printer_device.dart';

class SavedPrintersScreen extends ConsumerWidget {
  const SavedPrintersScreen({super.key});

  void _testPrint(BuildContext context, PrinterDevice printer) {
    showGlobalToast(
      message: 'Sending test receipt to ${printer.name}...',
      status: 'info',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printers = ref.watch(savedPrintersProvider);
    final isEmpty = printers.isEmpty;

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
          'Saved Printers',
          style: TextStyle(
            color: const Color(0xFF1E40AF),
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: const Color(0xFF1E40AF), size: 24.sp),
            onPressed: () => context.push(AppRoutes.addPrinter),
          ),
        ],
      ),
      body: SafeArea(
        child: isEmpty
            ? _buildEmptyState(context)
            : _buildPrintersList(context, ref, printers),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        children: [
          const Spacer(),
          Center(
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.print_outlined,
                  size: 54.sp,
                  color: const Color(0xFF1E40AF),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No saved printers',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add a printer to enable one-tap receipt printing',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.addPrinter),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Add Printer',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintersList(
    BuildContext context,
    WidgetRef ref,
    List<PrinterDevice> printers,
  ) {
    final notifier = ref.read(savedPrintersProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: printers.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final printer = printers[index];

              final Color iconBg = printer.isBluetooth
                  ? const Color(0xFFEFF6FF)
                  : (printer.isWifi ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB));
              final Color iconFg = printer.isBluetooth
                  ? const Color(0xFF1E40AF)
                  : (printer.isWifi ? const Color(0xFF059669) : const Color(0xFFD97706));
              final IconData typeIcon = printer.isBluetooth
                  ? Icons.bluetooth
                  : (printer.isWifi ? Icons.wifi : Icons.usb);

              return Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Icon(typeIcon, color: iconFg, size: 20.sp),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  printer.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (printer.isDefault) ...[
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'DEFAULT',
                                    style: TextStyle(
                                      color: const Color(0xFFD97706),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9.sp,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${printer.type.toUpperCase()} · ${printer.address.isNotEmpty ? "${printer.address} · " : ""}${printer.paperWidth}mm paper',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: const Color(0xFF64748B), size: 20.sp),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      onSelected: (val) {
                        if (val == 'default') {
                          notifier.setDefaultPrinter(printer.id);
                          showGlobalToast(message: '${printer.name} set as default printer');
                        } else if (val == 'test') {
                          _testPrint(context, printer);
                        } else if (val == 'delete') {
                          notifier.removePrinter(printer.id);
                          showGlobalToast(message: 'Printer removed');
                        }
                      },
                      itemBuilder: (context) => [
                        if (!printer.isDefault)
                          PopupMenuItem(
                            value: 'default',
                            child: Row(
                              children: [
                                Icon(Icons.star_outline_rounded, size: 18.sp, color: const Color(0xFF1E40AF)),
                                SizedBox(width: 8.w),
                                Text('Set as default', style: TextStyle(fontSize: 13.sp)),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'test',
                          child: Row(
                            children: [
                              Icon(Icons.print_outlined, size: 18.sp, color: const Color(0xFF0F172A)),
                              SizedBox(width: 8.w),
                              Text('Test print', style: TextStyle(fontSize: 13.sp)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 18.sp, color: Colors.red),
                              SizedBox(width: 8.w),
                              Text('Remove printer', style: TextStyle(fontSize: 13.sp, color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.addPrinter),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1E40AF), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(Icons.add, color: const Color(0xFF1E40AF), size: 18.sp),
              label: Text(
                'Add New Printer',
                style: TextStyle(
                  color: const Color(0xFF1E40AF),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
