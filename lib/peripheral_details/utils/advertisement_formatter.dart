import 'package:universal_ble/universal_ble.dart';

typedef AdDateTimeFormatter = String Function(DateTime dateTime);
typedef BleDeviceFieldFormatter = String Function(BleDevice device);

String formatAdvertisementCopyLine(
  BleDevice advertisement, {
  bool includeRssi = true,
  required AdDateTimeFormatter formatAdTime,
  required BleDeviceFieldFormatter formatCompanyIdentifiers,
  required BleDeviceFieldFormatter formatManufacturerData,
  required BleDeviceFieldFormatter formatServiceData,
  required BleDeviceFieldFormatter formatAdvertisedServices,
}) {
  final timestamp = advertisement.timestampDateTime;
  final time = timestamp != null ? formatAdTime(timestamp) : '—';
  final rssi = advertisement.rssi?.toString() ?? '—';
  final companyIdentifiers = formatCompanyIdentifiers(advertisement);
  final manufacturerData = formatManufacturerData(advertisement);
  final serviceData = formatServiceData(advertisement);
  final advertisedServices = formatAdvertisedServices(advertisement);

  final rssiSegment = includeRssi ? 'RSSI: $rssi  ' : '';

  return 'Time: $time  ${rssiSegment}Company ID: $companyIdentifiers  '
      'Manufacturer Data: $manufacturerData  Service Data: $serviceData  '
      'Advertised Services: $advertisedServices';
}

String formatAdvertisementsForClipboard(
  Iterable<BleDevice> advertisements, {
  bool includeRssi = true,
  required AdDateTimeFormatter formatAdTime,
  required BleDeviceFieldFormatter formatCompanyIdentifiers,
  required BleDeviceFieldFormatter formatManufacturerData,
  required BleDeviceFieldFormatter formatServiceData,
  required BleDeviceFieldFormatter formatAdvertisedServices,
}) {
  final lines = advertisements
      .map(
        (advertisement) => formatAdvertisementCopyLine(
          advertisement,
          includeRssi: includeRssi,
          formatAdTime: formatAdTime,
          formatCompanyIdentifiers: formatCompanyIdentifiers,
          formatManufacturerData: formatManufacturerData,
          formatServiceData: formatServiceData,
          formatAdvertisedServices: formatAdvertisedServices,
        ),
      )
      .join('\n');

  return 'Advertisements\n$lines';
}
