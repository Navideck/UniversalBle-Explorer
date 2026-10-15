import 'package:universal_ble/universal_ble.dart';

import '../models/device_fingerprint.dart';
import 'advertisement_formatter.dart';

typedef ServicesFormatter = String Function(List<BleService> services);

/// Renders a [DeviceFingerprint] into a copyable, human-readable report.
String formatDeviceFingerprint(
  DeviceFingerprint fingerprint, {
  required AdDateTimeFormatter formatAdTime,
  required BleDeviceFieldFormatter formatCompanyIdentifiers,
  required BleDeviceFieldFormatter formatManufacturerData,
  required BleDeviceFieldFormatter formatServiceData,
  required BleDeviceFieldFormatter formatAdvertisedServices,
  required ServicesFormatter formatServices,
  bool includeRssi = true,
}) {
  final buffer = StringBuffer();

  buffer.writeln('Device Fingerprint');
  buffer.writeln('==================');
  buffer.writeln('Name: ${fingerprint.name ?? 'Unknown'}');
  buffer.writeln('Device ID: ${fingerprint.deviceIdBefore}');
  buffer.writeln('Captured: ${_formatDateTime(fingerprint.capturedAt)}');
  buffer.writeln();

  buffer.writeln('Rolling ID');
  buffer.writeln('----------');
  buffer.writeln('Result: ${fingerprint.rollingId.label}');
  buffer.writeln('ID after reconnect: ${fingerprint.deviceIdAfter ?? '—'}');
  if (fingerprint.rollingIdCandidates.isNotEmpty) {
    buffer.writeln(
      'Candidate IDs: ${fingerprint.rollingIdCandidates.join(', ')}',
    );
  }
  buffer.writeln();

  buffer.writeln('Advertisements');
  buffer.writeln('--------------');
  buffer.writeln(
    '${fingerprint.advertisements.length} unique / '
    '${fingerprint.totalAdvertisements} total',
  );
  buffer.writeln();
  for (var i = 0; i < fingerprint.advertisements.length; i++) {
    final group = fingerprint.advertisements[i];
    final first =
        group.firstSeen != null ? formatAdTime(group.firstSeen!) : '—';
    final last = group.lastSeen != null ? formatAdTime(group.lastSeen!) : '—';

    buffer.write('[${i + 1}] x${group.count}');
    if (first != '—' || last != '—') {
      buffer.write('  first: $first  last: $last');
    }
    if (includeRssi && group.rssiMin != null) {
      final avg = group.rssiAverage?.toStringAsFixed(1) ?? '—';
      buffer.write('  RSSI: ${group.rssiMin}..${group.rssiMax} (avg $avg)');
    }
    buffer.writeln();

    final ad = group.advertisement;
    buffer.writeln('    Company ID: ${formatCompanyIdentifiers(ad)}');
    buffer.writeln('    Manufacturer Data: ${formatManufacturerData(ad)}');
    buffer.writeln('    Service Data: ${formatServiceData(ad)}');
    buffer.writeln('    Advertised Services: ${formatAdvertisedServices(ad)}');
  }
  buffer.writeln();

  buffer.writeln('Discovered Services');
  buffer.writeln('-------------------');
  buffer.writeln(
    fingerprint.services.isEmpty
        ? 'No services discovered'
        : formatServices(fingerprint.services),
  );
  buffer.writeln();

  buffer.writeln('Read All');
  buffer.writeln('--------');
  if (fingerprint.reads.isEmpty) {
    buffer.writeln('No readable characteristics');
  } else {
    for (final read in fingerprint.reads) {
      final path = '${read.serviceUuid}/${read.characteristicUuid}';
      buffer.writeln(
        read.isError ? '$path: ERROR ${read.error}' : '$path: ${read.value}',
      );
    }
  }

  return buffer.toString().trimRight();
}

String _formatDateTime(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-'
    '${dt.month.toString().padLeft(2, '0')}-'
    '${dt.day.toString().padLeft(2, '0')} '
    '${dt.hour.toString().padLeft(2, '0')}:'
    '${dt.minute.toString().padLeft(2, '0')}:'
    '${dt.second.toString().padLeft(2, '0')}';
