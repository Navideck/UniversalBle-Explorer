import 'package:flutter_test/flutter_test.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:universal_ble_example/data/utils.dart';

BleService _sampleService() {
  return BleService('180A', [
    BleCharacteristic('2A29', [CharacteristicProperty.read], const []),
    BleCharacteristic(
      '2A19',
      [CharacteristicProperty.read, CharacteristicProperty.notify],
      const [],
    ),
    BleCharacteristic(
      '2A00',
      [CharacteristicProperty.read, CharacteristicProperty.write],
      const [],
    ),
  ]);
}

List<String> _uuids(
  List<({BleService service, BleCharacteristic characteristic})> result,
) =>
    result.map((e) => e.characteristic.uuid).toList();

void main() {
  group('normalizeUuidForSearch', () {
    test('lowercases and strips hyphens and spaces', () {
      expect(
        normalizeUuidForSearch(' 00002A19-0000-1000-8000-00805F9B34FB '),
        '00002a1900001000800000805f9b34fb',
      );
    });
  });

  group('characteristicMatchesQuery', () {
    final characteristic = BleCharacteristic('2A19', const [], const []);

    test('empty query matches everything', () {
      expect(characteristicMatchesQuery(characteristic, ''), isTrue);
      expect(characteristicMatchesQuery(characteristic, '   '), isTrue);
    });

    test('matches short form regardless of case', () {
      expect(characteristicMatchesQuery(characteristic, '2a19'), isTrue);
      expect(characteristicMatchesQuery(characteristic, '2A19'), isTrue);
    });

    test('matches full hyphenated UUID', () {
      expect(
        characteristicMatchesQuery(
          characteristic,
          '00002a19-0000-1000-8000-00805f9b34fb',
        ),
        isTrue,
      );
    });

    test('does not match unrelated UUID', () {
      expect(characteristicMatchesQuery(characteristic, '2a29'), isFalse);
    });
  });

  group('getFilteredBleCharacteristics', () {
    test('returns all characteristics when no filters are set', () {
      final result = getFilteredBleCharacteristics([_sampleService()]);

      expect(_uuids(result), hasLength(3));
    });

    test('filters by text query on UUID', () {
      final result = getFilteredBleCharacteristics(
        [_sampleService()],
        characteristicQuery: '2a19',
      );

      expect(_uuids(result), ['00002a19-0000-1000-8000-00805f9b34fb']);
    });

    test('text query is case and hyphen insensitive', () {
      final result = getFilteredBleCharacteristics(
        [_sampleService()],
        characteristicQuery: '00002A19-0000-1000-8000-00805F9B34FB',
      );

      expect(_uuids(result), ['00002a19-0000-1000-8000-00805f9b34fb']);
    });

    test('returns empty when nothing matches', () {
      final result = getFilteredBleCharacteristics(
        [_sampleService()],
        characteristicQuery: 'ffff',
      );

      expect(result, isEmpty);
    });

    test('combines property filter and text query with AND semantics', () {
      final result = getFilteredBleCharacteristics(
        [_sampleService()],
        propertyFilters: {CharacteristicProperty.write},
        characteristicQuery: '2a',
      );

      expect(_uuids(result), ['00002a00-0000-1000-8000-00805f9b34fb']);
    });

    test('property filter alone still works', () {
      final result = getFilteredBleCharacteristics(
        [_sampleService()],
        propertyFilters: {CharacteristicProperty.notify},
      );

      expect(_uuids(result), ['00002a19-0000-1000-8000-00805f9b34fb']);
    });
  });
}
