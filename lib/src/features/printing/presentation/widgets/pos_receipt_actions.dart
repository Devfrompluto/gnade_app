import 'package:gnade_app/src/imports/imports.dart';

class POSReceiptActions extends StatelessWidget {
  const POSReceiptActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Print Bluetooth (Primary Blue)
        Expanded(
          child: SizedBox(
            height: 42.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              onPressed: () {
                showGlobalToast(message: 'Printing via Bluetooth thermal...');
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bluetooth_connected,
                        color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Print Bluetooth',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),

        // Print WiFi (Light Blue Outline/Fill)
        Expanded(
          child: SizedBox(
            height: 42.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF1E40AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              onPressed: () {
                showGlobalToast(message: 'Printing via WiFi network...');
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi,
                        color: const Color(0xFF1E40AF), size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Print WiFi',
                      style: TextStyle(
                        color: const Color(0xFF1E40AF),
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
