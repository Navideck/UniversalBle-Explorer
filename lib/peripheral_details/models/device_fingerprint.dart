import 'package:universal_ble/universal_ble.dart';

import '../utils/advertisement_consolidator.dart';

/// Outcome of the rolling (random/private) address check performed after
/// reconnecting to a device.
enum RollingIdResult {
  /// The device reconnected using the same identifier and no differently
  /// identified advertisement matching this device was observed.
  stable('Stable'),

  /// A matching advertisement appeared under a different identifier, or the
  /// device could not be reconnected while a matching candidate was seen.
  changed('Changed (rolling address detected)'),

  /// The check could not reach a conclusion (e.g. the device did not
  /// reconnect and no matching candidate was observed).
  inconclusive('Inconclusive');

  const RollingIdResult(this.label);

  final String label;
}

/// Result of reading a single characteristic during the fingerprint capture.
class ReadResult {
  final String serviceUuid;
  final String characteristicUuid;
  final String? value;
  final String? error;

  const ReadResult({
    required this.serviceUuid,
    required this.characteristicUuid,
    this.value,
    this.error,
  });

  bool get isError => error != null;
}

/// A consolidated snapshot of everything observed about a device: its
/// advertisements over a fixed window, discovered GATT services, readable
/// characteristic values, and whether its identifier appears to roll.
class DeviceFingerprint {
  final DateTime capturedAt;
  final String? name;
  final String deviceIdBefore;
  final String? deviceIdAfter;
  final RollingIdResult rollingId;

  /// Identifiers of advertisements that look like the same physical device but
  /// were seen under a different identifier during the check.
  final List<String> rollingIdCandidates;

  final int totalAdvertisements;
  final List<ConsolidatedAdvertisement> advertisements;
  final List<BleService> services;
  final List<ReadResult> reads;

  const DeviceFingerprint({
    required this.capturedAt,
    required this.name,
    required this.deviceIdBefore,
    required this.deviceIdAfter,
    required this.rollingId,
    required this.rollingIdCandidates,
    required this.totalAdvertisements,
    required this.advertisements,
    required this.services,
    required this.reads,
  });
}
