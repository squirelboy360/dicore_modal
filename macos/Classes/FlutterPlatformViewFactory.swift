import FlutterMacOS
import AppKit

class FlutterPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private let viewProvider: (Int64) -> NSView
    
    init(messenger: FlutterBinaryMessenger, viewProvider: @escaping (Int64) -> NSView) {
        self.messenger = messenger
        self.viewProvider = viewProvider
        super.init()
    }
    
    func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
        let platformView = viewProvider(viewId)
        
        if let args = args as? [String: Any],
           let route = args["route"] as? String {
            // Create a method channel for this specific view
            let channel = FlutterMethodChannel(
                name: "dicore_modal.platform_view/\(viewId)",
                binaryMessenger: messenger
            )
            
            // Handle platform view specific methods
            channel.setMethodCallHandler { [weak platformView] (call, result) in
                switch call.method {
                case "setRoute":
                    // Handle route changes if needed
                    result(nil)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }
        
        return platformView
    }
}