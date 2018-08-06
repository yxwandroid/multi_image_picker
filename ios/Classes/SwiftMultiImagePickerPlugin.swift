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
            vc.maxNumberOfSelections = maxImages
                
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
    
    func getURL(ofPhotoWith mPhasset: PHAsset, completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
            return true
        }
        mPhasset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
            completionHandler(contentEditingInput!.fullSizeImageURL)
        })
    }
    
    func getUrlsFromPHAssets(assets: [PHAsset], completion: @escaping ((_ urls:[String]) -> ())) {
        var array = [String]()
        let group = DispatchGroup()
        for asset in assets {
            group.enter()
            self.getURL(ofPhotoWith: asset) { (url) in
                if let url = url {
                    let absoluteUrl = url.absoluteString;
                    let start = absoluteUrl.index(absoluteUrl.startIndex, offsetBy: 7)
                    let end = absoluteUrl.index(absoluteUrl.endIndex, offsetBy: 0)
                    let range = start..<end
                    
                    let slicedUrl = absoluteUrl[range]

                    array.append(String(slicedUrl))// Remove all file:// crap
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
}
