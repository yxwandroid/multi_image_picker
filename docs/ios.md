# iOS customization

You can customize different parts of the gallery picker. To do so, you can simply pass `options` param in the `pickImages` call.

```dart
List resultList = await MultiImagePicker.pickImages(
    maxImages: 3,
    options: CupertinoOptions(
      selectionFillColor: "#ff11ab",
      selectionTextColor: "#ff00a5",
      selectionCharacter: "✓",
    ),
  );
```

Available options are:
 - backgroundColor - HEX string
 - selectionFillColor - HEX string
 - selectionShadowColor - HEX string
 - selectionStrokeColor - HEX string
 - selectionTextColor - HEX string
 - selectionCharacter - Unicode character

Text overrides will be available soon.