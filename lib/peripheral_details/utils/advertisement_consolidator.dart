import 'package:universal_ble/universal_ble.dart';

/// A group of identical advertisements collapsed into a single entry.
///
/// Advertisements are considered identical when their advertising *payload*
/// matches (name, connectability, advertised services, manufacturer data and
/// service data). RSSI and timestamps are summarised instead of being used for
/// grouping, since they vary between repetitions of the same advertisement.
class ConsolidatedAdvertisement {
  final BleDevice advertisement;
  final int count;
  final DateTime? firstSeen;
  final DateTime? lastSeen;
  final int? rssiMin;
  final int? rssiMax;
  final double? rssiAverage;

  const ConsolidatedAdvertisement({
    required this.advertisement,
    required this.count,
    this.firstSeen,
    this.lastSeen,
    this.rssiMin,
    this.rssiMax,
    this.rssiAverage,
  });
}

/// Groups [advertisements] that share the same payload, preserving the order in
/// which each distinct payload was first observed.
List<ConsolidatedAdvertisement> consolidateAdvertisements(
  Iterable<BleDevice> advertisements,
) {
  final groups = <String, List<BleDevice>>{};
  final order = <String>[];
  for (final ad in advertisements) {
    final key = advertisementPayloadKey(ad);
    final group = groups.putIfAbsent(key, () {
      order.add(key);
      return [];
    });
    group.add(ad);
  }
  return [for (final key in order) _consolidate(groups[key]!)];
}

/// Builds a stable key describing an advertisement's payload, ignoring RSSI and
/// timestamps.
String advertisementPayloadKey(BleDevice advertisement) {
  final services = [...advertisement.services]..sort();
  final manufacturer = advertisement.manufacturerDataList
      .map((d) => '${d.companyId}:${_hex(d.payload)}')
      .toList()
    ..sort();
  final serviceData = advertisement.serviceData.entries
      .map((e) => '${e.key}:${_hex(e.value)}')
      .toList()
    ..sort();

  return [
    advertisement.name ?? '',
    advertisement.connectable?.toString() ?? '',
    services.join(','),
    manufacturer.join('|'),
    serviceData.join('|'),
  ].join('||');
}

ConsolidatedAdvertisement _consolidate(List<BleDevice> advertisements) {
  final times = advertisements
      .map((a) => a.timestampDateTime)
      .whereType<DateTime>()
      .toList()
    ..sort();
  final rssis = advertisements.map((a) => a.rssi).whereType<int>().toList();

  int? rssiMin;
  int? rssiMax;
  double? rssiAverage;
  if (rssis.isNotEmpty) {
    rssiMin = rssis.reduce((a, b) => a < b ? a : b);
    rssiMax = rssis.reduce((a, b) => a > b ? a : b);
    rssiAverage = rssis.reduce((a, b) => a + b) / rssis.length;
  }

  return ConsolidatedAdvertisement(
    advertisement: advertisements.first,
    count: advertisements.length,
    firstSeen: times.isEmpty ? null : times.first,
    lastSeen: times.isEmpty ? null : times.last,
    rssiMin: rssiMin,
    rssiMax: rssiMax,
    rssiAverage: rssiAverage,
  );
}

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
