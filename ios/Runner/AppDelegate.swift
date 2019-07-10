import UIKit
import Flutter
import Firebase
import Foundation
import CoreLocation
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like viewDidLoad.
    static let viewCycle = OSLog(subsystem: subsystem, category: "viewcycle")
}

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
                
//                start_mm2(arg)
                print("START MM2 --------------------------------")
                Int32(mm2_main(arg, { (line) in
                    os_log("mm2] %@", log: OSLog.viewCycle, type: .info, String(cString: line!))
                    print("mm2] " + String(cString: line!))
                }));
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


