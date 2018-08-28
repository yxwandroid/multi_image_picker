import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

void main() {
  group('Asset', () {
    const MethodChannel channel = MethodChannel('multi_image_picker');

    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return true;
      });

      log.clear();
    });

    test('constructor set the identifier correctly', () {
      const String id = 'SOME_ID';
      Asset asset = Asset(id);
      expect(
        asset.identifier,
        equals(id),
      );
    });

    test('thumbData can not have negative dimensions', () async {
      Asset asset = Asset('_identifier');

      expect(
        asset.requestThumbnail(-100, 10),
        throwsArgumentError,
      );

      expect(
        asset.requestThumbnail(10, -100),
        throwsArgumentError,
      );
    });
  });
}
