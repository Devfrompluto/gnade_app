import 'package:equatable/equatable.dart';

class PrinterDevice extends Equatable {
  final String id;
  final String name;
  final String type; // 'bluetooth' | 'wifi' | 'usb'
  final String address; // MAC address or IP address
  final int paperWidth; // 58 or 80 mm
  final bool isDefault;
  final bool isConnected;

  const PrinterDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    this.paperWidth = 80,
    this.isDefault = false,
    this.isConnected = false,
  });

  bool get isBluetooth => type.toLowerCase() == 'bluetooth';
  bool get isWifi => type.toLowerCase() == 'wifi';
  bool get isUsb => type.toLowerCase() == 'usb';

  PrinterDevice copyWith({
    String? id,
    String? name,
    String? type,
    String? address,
    int? paperWidth,
    bool? isDefault,
    bool? isConnected,
  }) {
    return PrinterDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      paperWidth: paperWidth ?? this.paperWidth,
      isDefault: isDefault ?? this.isDefault,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'paperWidth': paperWidth,
      'isDefault': isDefault,
      'isConnected': isConnected,
    };
  }

  factory PrinterDevice.fromMap(Map<String, dynamic> map) {
    return PrinterDevice(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Thermal Printer',
      type: map['type']?.toString() ?? 'bluetooth',
      address: map['address']?.toString() ?? '',
      paperWidth: (map['paperWidth'] as num?)?.toInt() ?? 80,
      isDefault: map['isDefault'] as bool? ?? false,
      isConnected: map['isConnected'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        address,
        paperWidth,
        isDefault,
        isConnected,
      ];
}
