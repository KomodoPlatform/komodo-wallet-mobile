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
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let controllerMain : FlutterViewController = window?.rootViewController as! FlutterViewController
        let mm2main = FlutterMethodChannel(name: "mm2",
                                           binaryMessenger: controllerMain as! FlutterBinaryMessenger)
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        
        let chargingChannel = FlutterEventChannel(name: "streamLogMM2",
                                                  binaryMessenger: controller as! FlutterBinaryMessenger)
        chargingChannel.setStreamHandler(self)
        
        
        mm2main.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            
            if call.method == "start" {
                guard let arg = (call.arguments as! Dictionary<String,String>)["params"] else { result(0); return }
                
                print("START MM2 --------------------------------")
                mm2_main(arg, { (line) in
                    let mm2log = ["log": "mm2] " + String(cString: line!)]
                    NotificationCenter.default.post(name: .didReceiveData, object: nil, userInfo: mm2log)
                });
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
    
    @objc func onDidReceiveData(_ notification:Notification) {
        if let data = notification.userInfo as? [String: String]
        {
            sendLogMM2StateEvent(str: data["log"]!)
        }
        
    }
    
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        return nil
    }
    
    private func sendLogMM2StateEvent(str: String) {
        guard let eventSink = self.eventSink else {
            return
        }
        eventSink(str)
    }

    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
}

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
}

