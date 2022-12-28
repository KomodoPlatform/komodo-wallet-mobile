import UIKit
import Flutter
import Foundation
import CoreLocation
import os.log
import UserNotifications
import AVFoundation

var mm2StartArgs: String?
var shouldRestartMM2: Bool = true;

func performMM2Start() -> Int32 {
    os_log("%{public}s", type: OSLogType.default, "START MM2 --------------------------------");
    let error = Int32(mm2_main(mm2StartArgs, { (line) in
        let mm2log = ["log": "AppDelegate] " + String(cString: line!)]
        NotificationCenter.default.post(name: .didReceiveData, object: nil, userInfo: mm2log)
    }));
    os_log("%{public}s", type: OSLogType.default, "START MM2 RESULT: \(error) ---------------");
    return error;
}

func performMM2Stop() -> Int32 {
    os_log("%{public}s", type: OSLogType.default, "STOP MM2 --------------------------------");
    let error = Int32(mm2_stop());
    os_log("%{public}s", type: OSLogType.default, "STOP MM2 RESULT: \(error) ---------------");
    return error;
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    var intentURI: String?
    
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

    override func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        self.intentURI = url.absoluteString
        return true
    }

    private var screenPrevent = UITextField()
    public func configurePreventionScreenshot() {
        guard let w = window else { return }
        UserDefaults.standard.register(defaults: ["flutter.disallowScreenshot" : true])
        if (!w.subviews.contains(screenPrevent)) {
            w.addSubview(screenPrevent)
            screenPrevent.centerYAnchor.constraint(equalTo: w.centerYAnchor).isActive = true
            screenPrevent.centerXAnchor.constraint(equalTo: w.centerXAnchor).isActive = true
            w.layer.superlayer?.addSublayer(screenPrevent.layer)
            screenPrevent.layer.sublayers?.first?.addSublayer(w.layer)
        }

        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification,
                                               object: nil,
                                               queue: OperationQueue.main) { notification in
           let disallowScreenshot = UserDefaults.standard.bool(forKey: "flutter.disallowScreenshot");
           if disallowScreenshot {
              self.showToast(message: "Screenshot is black due to security reasons")
           }
        }
    }

    public func showToast(message : String) {
            let toastContainer = UIView(frame: CGRect())
            toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastContainer.alpha = 0.0
            toastContainer.layer.cornerRadius = 10;
            toastContainer.clipsToBounds  =  true

            let toastLabel = UILabel(frame: CGRect())
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.font.withSize(8.0)
            toastLabel.text = message
            toastLabel.clipsToBounds  =  true
            toastLabel.numberOfLines = 0

            toastContainer.addSubview(toastLabel)
            self.window.addSubview(toastContainer)

            toastLabel.translatesAutoresizingMaskIntoConstraints = false
            toastContainer.translatesAutoresizingMaskIntoConstraints = false

            let centerX = NSLayoutConstraint(item: toastLabel, attribute: .centerX, relatedBy: .equal, toItem: toastContainer, attribute: .centerXWithinMargins, multiplier: 1, constant: 0)
            let labelBottom = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
            let labelTop = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
            toastContainer.addConstraints([centerX, labelBottom, labelTop])

            toastContainer.widthAnchor.constraint(equalToConstant: self.window.frame.size.width - 30).isActive = true
            toastContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
            toastContainer.centerXAnchor.constraint(equalTo: self.window.centerXAnchor).isActive = true
            toastContainer.centerYAnchor.constraint(equalTo: self.window.centerYAnchor).isActive = true

            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                toastContainer.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 3, options: .curveEaseOut, animations: {
                    toastContainer.alpha = 0.0
                }, completion: {_ in
                    toastContainer.removeFromSuperview()
                })
            })
    }
    
    override func application (_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let vc = window?.rootViewController as? FlutterViewController else {
            fatalError ("rootViewController is not type FlutterViewController")}
        let vcbm = vc as! FlutterBinaryMessenger

        let audioDirKey = vc.lookupKey (forAsset: "assets/audio/start.mp3")
        let audioDirPath = Bundle.main.path (forResource: audioDirKey, ofType: nil)
        save_audio_path(audioDirPath)
        handleAudioInterruptions()
        configurePreventionScreenshot()

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
                                            shouldRestartMM2 = false
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
                                            shouldRestartMM2 = true
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
                                            mm2StartArgs = arg;
                                            let error: Int32 = performMM2Start();
                                            
                                            result(error)
                                        } else if call.method == "status" {
                                            let ret = Int32(mm2_main_status());
                                            result(ret)
                                        } else if call.method == "stop" {
                                            mm2StartArgs = nil;
                                            let error: Int32 = performMM2Stop();

                                            result(error)
                                        } else if call.method == "lsof" {
                                            lsof()
                                            result(0)
                                        } else if call.method == "is_screenshot" {
                                            self.screenshotAction()
                                            result(true)
                                        } else if call.method == "metrics" {
                                            let js = metrics()
                                            result (String (cString: js!))
                                        } else if call.method == "get_intent_data" {
                                            let uri = self.intentURI;
                                            self.intentURI = nil;
                                            result (uri)
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
        screenshotAction()

        let disallowScreenshot = UserDefaults.standard.bool(forKey: "flutter.disallowScreenshot");
        if disallowScreenshot {
           self.window?.addSubview(blurEffectView)
        }
    }
    
    public override func applicationDidBecomeActive(_ application: UIApplication) {
        signal(SIGPIPE, SIG_IGN);
        screenshotAction()

        let disallowScreenshot = UserDefaults.standard.bool(forKey: "flutter.disallowScreenshot");
        if disallowScreenshot {
            self.window?.viewWithTag(61007)?.removeFromSuperview()
        }

        restartMM2IfNeeded()
    }

    public func screenshotAction() {
        let disallowScreenshot = UserDefaults.standard.bool(forKey: "flutter.disallowScreenshot");
        if disallowScreenshot {
           screenPrevent.isSecureTextEntry = true
        } else {
           screenPrevent.isSecureTextEntry = false
        }
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        signal(SIGPIPE, SIG_IGN);
    }
    
    func restartMM2IfNeeded() {
        if mm2StartArgs == nil {return}
        
        if shouldRestartMM2 || mm2_main_status() == 0 {
            let _ = performMM2Stop()

            // add blur when app freezes
           let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = window!.frame
            blurEffectView.tag = 61007
            self.window?.addSubview(blurEffectView)

            var ticker: Int = 0
            // wait until mm2 stopped, but continue after 3s anyway
            while(mm2_main_status() != 0 && ticker < 30) {
                usleep(100000) // 0.1s
                ticker += 1
            }

            // remove blur when app unfreezes
            self.window?.viewWithTag(61007)?.removeFromSuperview()
            
            let _ = performMM2Start()
        }
    }
}

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
}
