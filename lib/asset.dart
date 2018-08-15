import 'package:flutter/services.dart';
import 'package:multi_image_picker/picker.dart';

class Asset {
  String identifier;
  int width;
  int height;
  ByteData imageData;

  void requestThumbnail(
      int width, int height, void handler(ByteData imageData)) {
    const prefix = 'multi_image_picker/image';
    var channelName = prefix + '/' + this.identifier;

    BinaryMessages.setMessageHandler(channelName, (message) {
      this.imageData = message;
      handler(message);
      BinaryMessages.setMessageHandler(channelName, null);
    });

    MultiImagePicker.requestThumbnail(this.identifier, width, height);
  }

  void requestOriginal(void handler(ByteData imageData)) {
    const prefix = 'multi_image_picker/image';
    var channelName = prefix + '/' + this.identifier;

    BinaryMessages.setMessageHandler(channelName, (message) {
      this.imageData = message;
      handler(message);
      BinaryMessages.setMessageHandler(channelName, null);
    });

    MultiImagePicker.requestOriginal(this.identifier);
  }
}
