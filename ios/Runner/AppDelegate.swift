import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let controllerMain : FlutterViewController = window?.rootViewController as! FlutterViewController
        let mm2main = FlutterMethodChannel(name: "mm2",
                                           binaryMessenger: controllerMain as! FlutterBinaryMessenger)
        
        mm2main.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if call.method == "start" {
                guard let arg = (call.arguments as! Dictionary<String,String>)["params"] else { result(0); return }
                
                start_mm2(arg)
                print(arg)
                result("starting mm2")
            } else if call.method == "status" {
                let ret = Int32(mm2_main_status());
                print(ret)
                result(ret)
            } else {
                result("Flutter method not implemented on iOS")
            }
        })
        FirebaseApp.configure()
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}


