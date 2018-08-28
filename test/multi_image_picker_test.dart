import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

void main() {
  group('MultiImagePicker', () {
    const MethodChannel channel = MethodChannel('multi_image_picker');

    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return [
          {'identifier': 'SOME_ID_1'},
          {'identifier': 'SOME_ID_2'}
        ];
      });

      log.clear();
    });

    group('#pickImages', () {
      test('passes max images argument correctly', () async {
        await MultiImagePicker.pickImages(maxImages: 5);

        expect(
          log,
          <Matcher>[
            isMethodCall('pickImages', arguments: <String, dynamic>{
              'maxImages': 5,
              'iosOptions': CupertinoOptions().toJson(),
            }),
          ],
        );
      });

      test('passes cuppertino options argument correctly', () async {
        CupertinoOptions options = CupertinoOptions(
          backgroundColor: '#ffde05',
          selectionCharacter: 'A',
          selectionFillColor: '#004ed5',
          selectionShadowColor: '#05e43d',
          selectionStrokeColor: '#0f5e4D',
          selectionTextColor: '#ffffff',
        );
        await MultiImagePicker.pickImages(maxImages: 5, options: options);

        expect(
          log,
          <Matcher>[
            isMethodCall('pickImages', arguments: <String, dynamic>{
              'maxImages': 5,
              'iosOptions': options.toJson(),
            }),
          ],
        );
      });

      test('does not accept a negative images count', () {
        expect(
          MultiImagePicker.pickImages(maxImages: -10),
          throwsArgumentError,
        );
      });
    });
  });
}
