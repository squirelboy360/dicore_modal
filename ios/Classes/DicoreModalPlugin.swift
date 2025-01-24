import Flutter
import UIKit

public class DicoreModalPlugin: NSObject, FlutterPlugin {
    private let registrar: FlutterPluginRegistrar
    private var modals: [String: DicoreModalViewController] = [:]
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dicore_modal", binaryMessenger: registrar.messenger())
        let instance = DicoreModalPlugin(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showModal":
            guard let args = call.arguments as? [String: Any],
                  let viewId = args["viewId"] as? String,
                  let properties = args["properties"] as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", 
                                  message: "Invalid arguments", 
                                  details: nil))
                return
            }
            
            showModal(viewId: viewId, properties: properties)
            result(nil)
            
        case "dismissModal":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Invalid arguments",
                                  details: nil))
                return
            }
            
            let modalId = args["modalId"] as? String
            dismissModal(modalId: modalId)
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func showModal(viewId: String, properties: [String: Any]) {
        let workItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            
            let modalVC = DicoreModalViewController(
                viewId: viewId,
                properties: properties,
                registrar: strongSelf.registrar
            )
            
            strongSelf.modals[viewId] = modalVC
            
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                rootVC.present(modalVC, animated: true)
            }
        }
        DispatchQueue.main.async(execute: workItem)
        }
    }
    
    private func dismissModal(modalId: String?) {
        let workItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            
            if let modalId = modalId {
                if let modalVC = strongSelf.modals[modalId] {
                    modalVC.dismiss(animated: true)
                    strongSelf.modals.removeValue(forKey: modalId)
                }
            } else {
                // Dismiss the topmost modal
                if let modalVC = strongSelf.modals.values.last {
                    modalVC.dismiss(animated: true)
                    if let key = strongSelf.modals.first(where: { $0.value === modalVC })?.key {
                        strongSelf.modals.removeValue(forKey: key)
                    }
                }
            }
        }
        DispatchQueue.main.async(execute: workItem)
        }
    }
}