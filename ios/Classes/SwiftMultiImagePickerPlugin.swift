import Flutter
import UIKit
import Photos
import BSImagePicker
    
public class SwiftMultiImagePickerPlugin: NSObject, FlutterPlugin {
    var controller: FlutterViewController!
    var imagesResult: FlutterResult?
    
    let genericError = "500"
    
    init(cont: FlutterViewController) {
        controller = cont;
        super.init();
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "multi_image_picker", binaryMessenger: registrar.messenger())
        
        let app =  UIApplication.shared
        let controller : FlutterViewController = app.delegate!.window!!.rootViewController as! FlutterViewController;
        let instance = SwiftMultiImagePickerPlugin.init(cont: controller)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "pickImages":
            let vc = BSImagePickerViewController()
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let maxImages = arguments["maxImages"] as! Int
            let options = arguments["iosOptions"] as! Dictionary<String, String>
            vc.maxNumberOfSelections = maxImages

            if let backgroundColor = options["backgroundColor"] {
                if (!backgroundColor.isEmpty) {
                    vc.backgroundColor = hexStringToUIColor(hex: backgroundColor)
                }
            }
            
            if let selectionFillColor = options["selectionFillColor"] {
                if (!selectionFillColor.isEmpty) {
                    vc.selectionFillColor = hexStringToUIColor(hex: selectionFillColor)
                }
            }
            
            if let selectionShadowColor = options["selectionShadowColor"] {
                if (!selectionShadowColor.isEmpty) {
                    vc.selectionShadowColor = hexStringToUIColor(hex: selectionShadowColor)
                }
            }
            
            if let selectionStrokeColor = options["selectionStrokeColor"] {
                if (!selectionStrokeColor.isEmpty) {
                    vc.selectionStrokeColor = hexStringToUIColor(hex: selectionStrokeColor)
                }
            }

            if let selectionTextColor = options["selectionTextColor"] {
                if (!selectionTextColor.isEmpty) {
                    vc.selectionTextAttributes[NSAttributedStringKey.foregroundColor] = hexStringToUIColor(hex: selectionTextColor)
                }
            }

            if let selectionCharacter = options["selectionCharacter"] {
                if (!selectionCharacter.isEmpty) {
                    vc.selectionCharacter = Character(selectionCharacter)
                }
            }

            controller!.bs_presentImagePickerController(vc, animated: true,
                select: { (asset: PHAsset) -> Void in

                }, deselect: { (asset: PHAsset) -> Void in

                }, cancel: { (assets: [PHAsset]) -> Void in
                    result([])
                }, finish: { (assets: [PHAsset]) -> Void in
                    self.getUrlsFromPHAssets(assets: assets, completion: { (urls) in
                        result(urls)
                    })
                }, completion: nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func getAsset(asset: PHAsset, completionHandler : @escaping ((_ image : NSData) -> Void)) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: {
            (image, info) in
            let imageData: NSData = UIImageJPEGRepresentation(image!, 1.0)! as NSData
            completionHandler(imageData)
        })
    }
    
    func getUrlsFromPHAssets(assets: [PHAsset], completion: @escaping ((_ urls:[String]) -> ())) {
        var array = [String]()
        let group = DispatchGroup()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        for asset in assets {
            group.enter()
            self.getAsset(asset: asset) { (image) in
                let uuid = UUID().uuidString
                let fileName = String(format: "multi_image_picker_%@.jpg", uuid)
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    do {
                        try image.write(to: fileURL)
                        array.append(fileURL.path)
                    } catch {
                        print("error saving file:", error)
                    }
                }
                
                group.leave()
            }
        }
        // This closure will be called once group.leave() is called
        // for every asset in the above for loop
        group.notify(queue: .main) {
            completion(array)
        }
    }

    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
