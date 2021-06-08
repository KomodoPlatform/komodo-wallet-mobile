import UIKit
import Flutter
import Foundation
import CoreLocation
import os.log
import UserNotifications
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    
    // Handle audio interruptions by Siri or calls.
    // Regular audio, like 'Apple Music' will be mixed with the app playback.
    func handleAudioInterruptions() {
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(onAudioInterrupted),
                       name: AVAudioSession.interruptionNotification,
                       object: nil)
    }
    
    @objc func onAudioInterrupted(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .ended:
            // An interruption ended. Resume playback, if appropriate.
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                audio_resume ()
            } else {
                // Interruption ended. Playback should not resume.
            }
            
        default: ()
        }
    }
    
    override func application (_ application: UIApplication,
                               didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let vc = window?.rootViewController as? FlutterViewController else {
            fatalError ("rootViewController is not type FlutterViewController")}
        let vcbm = vc as! FlutterBinaryMessenger
        
        let audioDirKey = vc.lookupKey (forAsset: "assets/audio/start.mp3")
        let audioDirPath = Bundle.main.path (forResource: audioDirKey, ofType: nil)
        save_audio_path(audioDirPath)
        handleAudioInterruptions()
        
        let mm2main = FlutterMethodChannel (name: "mm2", binaryMessenger: vcbm)
        let chargingChannel = FlutterEventChannel (name: "AtomicDEX/logC", binaryMessenger: vcbm)
        chargingChannel.setStreamHandler (self)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notifications allowed!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        mm2main.setMethodCallHandler ({(call: FlutterMethodCall, result: FlutterResult) -> Void in
                                        if call.method == "audio_bg" {
                                            let argDict = call.arguments as! Dictionary<String, Any>
                                            let path = argDict["path"] as! String
                                            result (Int (audio_bg (path)))
                                        } else if call.method == "audio_fg" {
                                            let argDict = call.arguments as! Dictionary<String, Any>
                                            let path = argDict["path"] as! String
                                            result (Int (audio_fg (path)))
                                        } else if call.method == "audio_volume" {
                                            let volume = NSNumber (value: call.arguments as! Double)
                                            result (Int (audio_volume (volume)))
                                        } else if call.method == "audio_stop" {
                                            audio_bg ("")
                                            result (Int (audio_deactivate()))
                                        } else if call.method == "show_notification" {
                                            let argDict = call.arguments as! Dictionary<String, Any>
                                            let id = String(argDict["uid"] as! Int)
                                            let content = UNMutableNotificationContent()
                                            content.title = argDict["title"] as! String
                                            content.subtitle = argDict["text"] as! String
                                            content.sound = UNNotificationSound.default
                                            
                                            let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
                                            UNUserNotificationCenter.current().add(request)
                                            
                                            result(nil);
                                        } else if call.method == "is_camera_denied" {
                                            var authorized = false
                                            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
                                                authorized = true;
                                            }
                                            result(!authorized)
                                        } else if call.method == "battery" {
                                            let level: Float = UIDevice.current.batteryLevel;
                                            let lowPowerMode: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled;
                                            let charging: Bool = UIDevice.current.batteryState == .charging;
                                            
                                            result(["level": level, "lowPowerMode": lowPowerMode, "charging": charging]);
                                        } else if call.method == "start" {
                                            guard let arg = (call.arguments as! Dictionary<String,String>)["params"] else { result(0); return }
                                            
                                            print("START MM2 --------------------------------")
                                            let error = Int32(mm2_main(arg, { (line) in
                                                let mm2log = ["log": "AppDelegate] " + String(cString: line!)]
                                                NotificationCenter.default.post(name: .didReceiveData, object: nil, userInfo: mm2log)
                                            }));
                                            //print(arg)
                                            result(error)
                                        } else if call.method == "status" {
                                            let ret = Int32(mm2_main_status());
                                            result(ret)
                                        } else if call.method == "stop" {
                                            print("STOP MM2 --------------------------------")
                                            let error = Int32(mm2_stop());

                                            print(error)
                                            result(error)
                                        } else if call.method == "lsof" {
                                            lsof()
                                            result(0)
                                        } else if call.method == "metrics" {
                                            let js = metrics()
                                            result (String (cString: js!))
                                        } else if call.method == "log" {
                                            // Allows us to log via the `os_log` default channel
                                            // (Flutter currently does it for us, but there's a chance that it won't).
                                            let arg = call.arguments as! String;
                                            os_log("%{public}s", type: OSLogType.default, arg);
                                        } else {result (FlutterMethodNotImplemented)}})
        
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
    
    public override func applicationWillResignActive(_ application: UIApplication) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window!.frame
        blurEffectView.tag = 61007
        
        self.window?.addSubview(blurEffectView)
    }
    
    public override func applicationDidBecomeActive(_ application: UIApplication) {
        signal(SIGPIPE, SIG_IGN)
        self.window?.viewWithTag(61007)?.removeFromSuperview()
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        signal(SIGPIPE, SIG_IGN)
    }
}

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
}

