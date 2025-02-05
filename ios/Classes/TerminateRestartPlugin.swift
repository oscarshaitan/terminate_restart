import Flutter
import UIKit

public class TerminateRestartPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.ahmedsleem.terminate_restart/restart", binaryMessenger: registrar.messenger())
        let instance = TerminateRestartPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "restartApp":
            handleRestartApp(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleRestartApp(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let clearData = args["clearData"] as? Bool,
              let preserveKeychain = args["preserveKeychain"] as? Bool,
              let preserveUserDefaults = args["preserveUserDefaults"] as? Bool,
              let terminate = args["terminate"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGS",
                              message: "Invalid arguments provided",
                              details: nil))
            return
        }
        
        // Return success before restarting
        result(true)
        
        // Clear data and restart after a delay to ensure UI has updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Clear app data if requested
            if clearData {
                self.clearAppData(preserveKeychain: preserveKeychain,
                            preserveUserDefaults: preserveUserDefaults)
            }
            
            // Wait for data clearing to complete before restarting
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.restartApp(terminate: terminate)
            }
        }
    }
    
    private func restartApp(terminate: Bool) {
        // Get the app's root view controller
        guard let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first,
              let rootViewController = window.rootViewController else {
            NSLog("[TerminateRestartPlugin] Error: Could not get root view controller")
            return
        }
        
        if terminate {
            // Full app restart - create new instance and terminate current
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "\(bundleId)://") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            // Terminate the current instance
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                exit(1)
            }
        } else {
            // UI-only restart for Flutter
            let tempViewController = UIViewController()
            tempViewController.view.backgroundColor = .white
            
            // Force a reload of the view hierarchy
            UIView.transition(with: window,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: {
                window.rootViewController = tempViewController
            }) { _ in
                // Reset to original root after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // For Flutter, we can reuse the existing root controller
                    UIView.transition(with: window,
                                    duration: 0.3,
                                    options: .transitionCrossDissolve,
                                    animations: {
                        window.rootViewController = rootViewController
                    })
                }
            }
        }
    }
    
    private func clearAppData(preserveKeychain: Bool, preserveUserDefaults: Bool) {
        NSLog("[TerminateRestartPlugin] Clearing app data (preserveKeychain: \(preserveKeychain), preserveUserDefaults: \(preserveUserDefaults))")
        
        // Clear UserDefaults if not preserved
        if !preserveUserDefaults {
            if let bundleId = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleId)
                UserDefaults.standard.synchronize()
                NSLog("[TerminateRestartPlugin] Cleared UserDefaults")
            }
        }
        
        // Clear app's document directory
        if let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            try? FileManager.default.removeItem(at: docPath)
            try? FileManager.default.createDirectory(at: docPath, withIntermediateDirectories: true)
            NSLog("[TerminateRestartPlugin] Cleared document directory")
        }
        
        // Clear app's cache directory
        if let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            try? FileManager.default.removeItem(at: cachePath)
            try? FileManager.default.createDirectory(at: cachePath, withIntermediateDirectories: true)
            NSLog("[TerminateRestartPlugin] Cleared cache directory")
        }
        
        // Clear app's temporary directory
        try? FileManager.default.removeItem(at: FileManager.default.temporaryDirectory)
        try? FileManager.default.createDirectory(at: FileManager.default.temporaryDirectory, withIntermediateDirectories: true)
        NSLog("[TerminateRestartPlugin] Cleared temporary directory")
        
        // Clear Keychain if not preserved
        if !preserveKeychain {
            clearKeychain()
            NSLog("[TerminateRestartPlugin] Cleared keychain")
        }
        
        // Force changes to be written
        UserDefaults.standard.synchronize()
    }
    
    private func clearKeychain() {
        let secItemClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]
        
        for itemClass in secItemClasses {
            let spec: [String: Any] = [kSecClass as String: itemClass]
            SecItemDelete(spec as CFDictionary)
        }
    }
}
