import UIKit
import Flutter
import CoreMotion
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let channelName = "com.example.widget/accdata"
      let rootViewController : FlutterViewController = window?.rootViewController as! FlutterViewController

      let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: rootViewController as! FlutterBinaryMessenger)

      methodChannel.setMethodCallHandler {(call: FlutterMethodCall, result: FlutterResult) -> Void in
          var initdate: Date
          if (call.method == "start") {
              if CMSensorRecorder.isAccelerometerRecordingAvailable() {
                  if CMSensorRecorder.authorizationStatus() == CMAuthorizationStatus.authorized {
                      let recorder = CMSensorRecorder()
                      initdate=Date.init()
                      recorder.recordAccelerometer(forDuration: 1 * 60)
                      let data=recorder.accelerometerData(from: initdate, to: initdate+1*60)
                      result(data)
                  }
              }
          }
          
      }
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
