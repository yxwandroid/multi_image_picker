import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class MultiImagePicker {
  static const MethodChannel _channel =
      const MethodChannel('multi_image_picker');

  static Future<List<File>> pickImages({
    @required int maxImages,
  }) async {
    final List<dynamic> images =
        await _channel.invokeMethod('pickImages', <String, dynamic>{
      'maxImages': maxImages,
    });
    return images.map<File>((path) => new File(path)).toList();
  }
}
