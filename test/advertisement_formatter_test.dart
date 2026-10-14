import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:universal_ble_example/peripheral_details/utils/advertisement_formatter.dart';

BleDevice _advertisement({int? rssi = -42}) {
  return BleDevice(
    deviceId: 'device-1',
    name: 'MockDevice',
    rssi: rssi,
    timestamp: DateTime(2024, 1, 1, 12, 34, 56).millisecondsSinceEpoch,
    manufacturerDataList: [
      ManufacturerData(0x004C, Uint8List.fromList([0x01, 0x02])),
    ],
    services: const ['180A'],
    serviceData: {
      '180F': Uint8List.fromList([0x64])
    },
  );
}

String _formatTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:'
    '${dt.minute.toString().padLeft(2, '0')}:'
    '${dt.second.toString().padLeft(2, '0')}';

String _companyIds(BleDevice device) =>
    device.manufacturerDataList.map((d) => d.companyIdRadix16).join(', ');

String _manufacturerData(BleDevice device) => device.manufacturerDataList
    .map((d) => '${d.companyIdRadix16}: ${d.payloadRadix16}')
    .join('; ');

String _serviceData(BleDevice device) => device.serviceData.entries
    .map((e) =>
        '${e.key}: 0x${e.value.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase()}')
    .join('; ');

String _advertisedServices(BleDevice device) =>
    device.services.isEmpty ? '—' : device.services.join(', ');

String _line(BleDevice ad, {required bool includeRssi}) =>
    formatAdvertisementCopyLine(
      ad,
      includeRssi: includeRssi,
      formatAdTime: _formatTime,
      formatCompanyIdentifiers: _companyIds,
      formatManufacturerData: _manufacturerData,
      formatServiceData: _serviceData,
      formatAdvertisedServices: _advertisedServices,
    );

void main() {
  group('formatAdvertisementCopyLine', () {
    test('includes RSSI by default', () {
      final line = _line(_advertisement(), includeRssi: true);

      expect(line, contains('RSSI: -42'));
    });

    test('omits RSSI when includeRssi is false', () {
      final line = _line(_advertisement(), includeRssi: false);

      expect(line, isNot(contains('RSSI')));
      expect(line, contains('Company ID: 0x04c'));
      expect(line, contains('Service Data:'));
      expect(line, contains('0x64'));
      expect(line, contains('Advertised Services: 180A'));
    });

    test('all other fields are identical regardless of RSSI', () {
      final ad = _advertisement();
      final withRssi = _line(ad, includeRssi: true);
      final withoutRssi = _line(ad, includeRssi: false);

      expect(
        withRssi.replaceFirst('RSSI: -42  ', ''),
        withoutRssi,
      );
    });
  });

  group('formatAdvertisementsForClipboard', () {
    test('omits RSSI from every line when disabled', () {
      final text = formatAdvertisementsForClipboard(
        [_advertisement(rssi: -42), _advertisement(rssi: -70)],
        includeRssi: false,
        formatAdTime: _formatTime,
        formatCompanyIdentifiers: _companyIds,
        formatManufacturerData: _manufacturerData,
        formatServiceData: _serviceData,
        formatAdvertisedServices: _advertisedServices,
      );

      expect(text, contains('Advertisements'));
      expect(text, isNot(contains('RSSI')));
      expect(text.split('\n').length, 3);
    });

    test('includes RSSI in every line when enabled', () {
      final text = formatAdvertisementsForClipboard(
        [_advertisement(rssi: -42), _advertisement(rssi: -70)],
        includeRssi: true,
        formatAdTime: _formatTime,
        formatCompanyIdentifiers: _companyIds,
        formatManufacturerData: _manufacturerData,
        formatServiceData: _serviceData,
        formatAdvertisedServices: _advertisedServices,
      );

      expect(text, contains('RSSI: -42'));
      expect(text, contains('RSSI: -70'));
    });
  });
}
