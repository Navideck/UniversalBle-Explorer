import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:universal_ble_example/peripheral_details/models/device_fingerprint.dart';
import 'package:universal_ble_example/peripheral_details/utils/advertisement_consolidator.dart';
import 'package:universal_ble_example/peripheral_details/utils/fingerprint_formatter.dart';
import 'package:universal_ble_example/peripheral_details/utils/services_formatter.dart';

BleDevice _advertisement({
  String deviceId = 'device-1',
  String? name = 'MockDevice',
  int? rssi = -42,
  int second = 0,
  List<int> manufacturerPayload = const [0x01, 0x02],
}) {
  return BleDevice(
    deviceId: deviceId,
    name: name,
    rssi: rssi,
    timestamp: DateTime(2024, 1, 1, 12, 0, second).millisecondsSinceEpoch,
    manufacturerDataList: [
      ManufacturerData(0x004C, Uint8List.fromList(manufacturerPayload)),
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

void main() {
  group('consolidateAdvertisements', () {
    test('groups identical payloads regardless of RSSI and timestamp', () {
      final groups = consolidateAdvertisements([
        _advertisement(rssi: -40, second: 1),
        _advertisement(rssi: -55, second: 30),
        _advertisement(rssi: -48, second: 45),
      ]);

      expect(groups, hasLength(1));
      expect(groups.first.count, 3);
      expect(groups.first.rssiMin, -55);
      expect(groups.first.rssiMax, -40);
      expect(groups.first.rssiAverage, closeTo(-47.67, 0.01));
      expect(groups.first.firstSeen, DateTime(2024, 1, 1, 12, 0, 1));
      expect(groups.first.lastSeen, DateTime(2024, 1, 1, 12, 0, 45));
    });

    test('keeps different payloads in separate groups', () {
      final groups = consolidateAdvertisements([
        _advertisement(manufacturerPayload: const [0x01, 0x02]),
        _advertisement(manufacturerPayload: const [0x09, 0x09]),
      ]);

      expect(groups, hasLength(2));
      expect(groups[0].count, 1);
      expect(groups[1].count, 1);
    });

    test('treats a different name as a different payload', () {
      final groups = consolidateAdvertisements([
        _advertisement(name: 'A'),
        _advertisement(name: 'B'),
      ]);

      expect(groups, hasLength(2));
    });

    test('preserves first-observed group order', () {
      final groups = consolidateAdvertisements([
        _advertisement(name: 'First', manufacturerPayload: const [0x01]),
        _advertisement(name: 'Second', manufacturerPayload: const [0x02]),
        _advertisement(name: 'First', manufacturerPayload: const [0x01]),
      ]);

      expect(groups, hasLength(2));
      expect(groups[0].advertisement.name, 'First');
      expect(groups[0].count, 2);
      expect(groups[1].advertisement.name, 'Second');
    });

    test('returns an empty list for no advertisements', () {
      expect(consolidateAdvertisements(const []), isEmpty);
    });
  });

  group('formatDeviceFingerprint', () {
    DeviceFingerprint buildFingerprint() {
      final groups = consolidateAdvertisements([
        _advertisement(rssi: -40, second: 1),
        _advertisement(rssi: -50, second: 20),
      ]);
      final services = [
        BleService('180A', [
          BleCharacteristic(
            '2A29',
            [CharacteristicProperty.read],
            const [],
          ),
        ]),
      ];
      return DeviceFingerprint(
        capturedAt: DateTime(2024, 1, 1, 12, 0, 0),
        name: 'MockDevice',
        deviceIdBefore: 'AA:BB:CC',
        deviceIdAfter: 'AA:BB:CC',
        rollingId: RollingIdResult.stable,
        rollingIdCandidates: const [],
        totalAdvertisements: 2,
        advertisements: groups,
        services: services,
        reads: const [
          ReadResult(
            serviceUuid: '180A',
            characteristicUuid: '2A29',
            value: '"Apple Inc."',
          ),
        ],
      );
    }

    String format(DeviceFingerprint fp) => formatDeviceFingerprint(
          fp,
          formatAdTime: _formatTime,
          formatCompanyIdentifiers: _companyIds,
          formatManufacturerData: _manufacturerData,
          formatServiceData: _serviceData,
          formatAdvertisedServices: _advertisedServices,
          formatServices: formatBleServices,
        );

    test('includes every section', () {
      final text = format(buildFingerprint());

      expect(text, contains('Device Fingerprint'));
      expect(text, contains('Rolling ID'));
      expect(text, contains('Stable'));
      expect(text, contains('Advertisements'));
      expect(text, contains('1 unique / 2 total'));
      expect(text, contains('Discovered Services'));
      expect(text, contains('180A'));
      expect(text, contains('Read All'));
      expect(text, contains('180A/2A29'));
    });

    test('summarises consolidated advertisements', () {
      final text = format(buildFingerprint());

      expect(text, contains('[1] x2'));
      expect(text, contains('first: 12:00:01'));
      expect(text, contains('last: 12:00:20'));
      expect(text, contains('RSSI: -50..-40'));
    });

    test('reports a rolling identifier with candidates', () {
      final fp = buildFingerprint();
      final rolling = DeviceFingerprint(
        capturedAt: fp.capturedAt,
        name: fp.name,
        deviceIdBefore: fp.deviceIdBefore,
        deviceIdAfter: fp.deviceIdBefore,
        rollingId: RollingIdResult.changed,
        rollingIdCandidates: const ['DD:EE:FF'],
        totalAdvertisements: fp.totalAdvertisements,
        advertisements: fp.advertisements,
        services: fp.services,
        reads: fp.reads,
      );

      final text = format(rolling);

      expect(text, contains('Changed (rolling address detected)'));
      expect(text, contains('Candidate IDs: DD:EE:FF'));
    });

    test('handles devices with no services or reads', () {
      final fp = DeviceFingerprint(
        capturedAt: DateTime(2024, 1, 1, 12, 0, 0),
        name: null,
        deviceIdBefore: 'device-1',
        deviceIdAfter: 'device-1',
        rollingId: RollingIdResult.inconclusive,
        rollingIdCandidates: const [],
        totalAdvertisements: 0,
        advertisements: const [],
        services: const [],
        reads: const [],
      );

      final text = format(fp);

      expect(text, contains('Name: Unknown'));
      expect(text, contains('No services discovered'));
      expect(text, contains('No readable characteristics'));
      expect(text, contains('Inconclusive'));
    });
  });
}
