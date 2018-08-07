import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:multi_image_picker/cupertino_options.dart';

class MultiImagePicker {
  static const MethodChannel _channel =
      const MethodChannel('multi_image_picker');

  static Future<List<File>> pickImages({
    @required int maxImages,
    CupertinoOptions options = const CupertinoOptions(),
  }) async {
    final List<dynamic> images =
        await _channel.invokeMethod('pickImages', <String, dynamic>{
      'maxImages': maxImages,
      'iosOptions': options.toJson(),
    });
    return images.map<File>((path) => new File(path)).toList();
  }
}
