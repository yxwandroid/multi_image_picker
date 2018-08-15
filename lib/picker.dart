import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:multi_image_picker/asset.dart';
import 'package:multi_image_picker/cupertino_options.dart';

class MultiImagePicker {
  static const MethodChannel _channel =
      const MethodChannel('multi_image_picker');

  static Future<List<Asset>> pickImages({
    @required int maxImages,
    CupertinoOptions options = const CupertinoOptions(),
  }) async {
    final List<dynamic> images =
        await _channel.invokeMethod('pickImages', <String, dynamic>{
      'maxImages': maxImages,
      'iosOptions': options.toJson(),
    });

    var assets = List<Asset>();
    for (var item in images) {
      var asset = Asset();
      asset.identifier = item['identifier'];
      asset.width = item['width'];
      asset.height = item['height'];
      assets.add(asset);
    }
    return assets;
  }

  static Future<bool> requestThumbnail(
      String identifier, int width, int height) async {
    bool ret =
        await _channel.invokeMethod("requestThumbnail", <String, dynamic>{
      "identifier": identifier,
      "width": width,
      "height": height,
    });
    return ret;
  }

  static Future<bool> requestOriginal(String identifier) async {
    bool ret = await _channel.invokeMethod("requestOriginal", <String, dynamic>{
      "identifier": identifier,
    });
    return ret;
  }
}
