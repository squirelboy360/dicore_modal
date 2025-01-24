import Flutter
import UIKit

class DicoreModalViewController: UIViewController {
    private let properties: [String: Any]
    private let viewId: String
    private let channel: FlutterMethodChannel
    private let registrar: FlutterPluginRegistrar
    private var platformView: UIView?
    
    init(viewId: String, properties: [String: Any], registrar: FlutterPluginRegistrar) {
        self.viewId = viewId
        self.properties = properties
        self.registrar = registrar
        self.channel = FlutterMethodChannel(name: "dicore_modal/\(viewId)", binaryMessenger: registrar.messenger())
        
        super.init(nibName: nil, bundle: nil)
        
        setupModalProperties()
        setupTitleBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFlutterView()
    }
    
    private func setupModalProperties() {
        if let style = properties["presentationStyle"] as? Int {
            modalPresentationStyle = UIModalPresentationStyle(rawValue: style) ?? .pageSheet
        }
        
        if let style = properties["transitionStyle"] as? Int {
            modalTransitionStyle = UIModalTransitionStyle(rawValue: style) ?? .coverVertical
        }
        
        if #available(iOS 15.0, *) {
            if properties["detents"] as? Bool == true {
                sheetPresentationController?.detents = [.medium(), .large()]
                sheetPresentationController?.prefersGrabberVisible = true
                sheetPresentationController?.preferredCornerRadius = properties["cornerRadius"] as? CGFloat ?? 10.0
                sheetPresentationController?.prefersScrollingExpandsWhenScrolledToEdge = properties["prefersScrollingExpandsWhenScrolledToEdge"] as? Bool ?? true
            }
        }
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = !(properties["isDismissable"] as? Bool ?? true)
        }
        
        if let backgroundColor = properties["backgroundColor"] as? Int {
            view.backgroundColor = UIColor(rgb: backgroundColor)
        }
        
        if let padding = properties["padding"] as? [String: CGFloat] {
            additionalSafeAreaInsets = UIEdgeInsets(
                top: padding["top"] ?? 0,
                left: padding["left"] ?? 0,
                bottom: padding["bottom"] ?? 0,
                right: padding["right"] ?? 0
            )
        }
    }
    
    private func setupTitleBar() {
        guard let titleBarProps = properties["titleBar"] as? [String: Any],
              titleBarProps["visible"] as? Bool ?? true else { return }
        
        let navigationBar = UINavigationBar()
        let navigationItem = UINavigationItem()
        
        if let title = titleBarProps["title"] as? String {
            navigationItem.title = title
        }
        
        if let titleStyle = titleBarProps["titleStyle"] as? [String: Any] {
            let fontSize = titleStyle["fontSize"] as? CGFloat ?? 17
            let fontWeight = UIFont.Weight(rawValue: titleStyle["fontWeight"] as? CGFloat ?? 0)
            let font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
            
            if let colorValue = titleStyle["color"] as? Int {
                navigationBar.titleTextAttributes = [
                    .font: font,
                    .foregroundColor: UIColor(rgb: colorValue)
                ]
            } else {
                navigationBar.titleTextAttributes = [.font: font]
            }
        }
        
        if let leadingProps = titleBarProps["leading"] as? [String: Any] {
            navigationItem.leftBarButtonItem = createBarButtonItem(from: leadingProps, isLeading: true)
        }
        
        if let trailingProps = titleBarProps["trailing"] as? [String: Any] {
            navigationItem.rightBarButtonItem = createBarButtonItem(from: trailingProps, isLeading: false)
        }
        
        if let backgroundColor = titleBarProps["backgroundColor"] as? Int {
            navigationBar.backgroundColor = UIColor(rgb: backgroundColor)
        }
        
        if !(titleBarProps["showsDivider"] as? Bool ?? true) {
            navigationBar.shadowImage = UIImage()
        }
        
        navigationBar.items = [navigationItem]
        view.addSubview(navigationBar)
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func createBarButtonItem(from props: [String: Any], isLeading: Bool) -> UIBarButtonItem? {
        let action = isLeading ? #selector(leadingButtonTapped) : #selector(trailingButtonTapped)
        
        if let title = props["title"] as? String {
            let button = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
            if let tintColor = props["tintColor"] as? Int {
                button.tintColor = UIColor(rgb: tintColor)
            }
            return button
        } else if #available(iOS 13.0, *), let systemImageName = props["systemImageName"] as? String {
            let image = UIImage(systemName: systemImageName)
            let button = UIBarButtonItem(image: image, style: .plain, target: self, action: action)
            if let tintColor = props["tintColor"] as? Int {
                button.tintColor = UIColor(rgb: tintColor)
            }
            return button
        } else if let assetImageName = props["assetImageName"] as? String,
                  let image = UIImage(named: assetImageName) {
            let button = UIBarButtonItem(image: image, style: .plain, target: self, action: action)
            if let tintColor = props["tintColor"] as? Int {
                button.tintColor = UIColor(rgb: tintColor)
            }
            return button
        }
        return nil
    }
    
    @objc private func leadingButtonTapped() {
        channel.invokeMethod("onLeadingButtonTap", arguments: nil)
    }
    
    @objc private func trailingButtonTapped() {
        channel.invokeMethod("onTrailingButtonTap", arguments: nil)
    }
    
    private class ModalPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
        private let messenger: FlutterBinaryMessenger
        private weak var parentVC: DicoreModalViewController?
        
        init(messenger: FlutterBinaryMessenger, parentVC: DicoreModalViewController) {
            self.messenger = messenger
            self.parentVC = parentVC
            super.init()
        }
        
        func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
            return FlutterStandardMessageCodec.sharedInstance()
        }       
        func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
            return ModalPlatformView(frame: frame, viewIdentifier: viewId, arguments: args, messenger: messenger, parentVC: parentVC)
        }
    }
    
    private class ModalPlatformView: NSObject, FlutterPlatformView {
        private let flutterView: UIView
        private let stateChannel: FlutterMethodChannel
        
        init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, messenger: FlutterBinaryMessenger, parentVC: DicoreModalViewController?) {
            flutterView = UIView(frame: frame)
            flutterView.translatesAutoresizingMaskIntoConstraints = false
            
            stateChannel = FlutterMethodChannel(
                name: "dicore_modal/state/\(parentVC?.viewId ?? "")",
                binaryMessenger: messenger
            )
            
            super.init()
            
            stateChannel.setMethodCallHandler { [weak self] call, result in
                switch call.method {
                case "updateState":
                    guard let args = call.arguments as? [String: Any] else {
                        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                        return
                    }
                    // Handle state updates from Flutter
                    result(nil)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }
        
        func view() -> UIView {
            return flutterView
        }
    }
    
    private func setupFlutterView() {
        let factory = ModalPlatformViewFactory(messenger: registrar.messenger(), parentVC: self)
        registrar.register(factory, withId: viewId)
        
        let platformView = factory.create(withFrame: .zero,
                                         viewIdentifier: Int64(viewId) ?? 0,
                                         arguments: ["initialState": properties])
        
        view.addSubview(platformView)
        platformView.translatesAutoresizingMaskIntoConstraints = false
        
        let topView = view.subviews.first { $0 != platformView }
        
        NSLayoutConstraint.activate([
            platformView.topAnchor.constraint(equalTo: (topView?.bottomAnchor ?? view.topAnchor)),
            platformView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            platformView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            platformView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.platformView = platformView
    }
}

extension UIColor {
    convenience init(rgb: Int) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: CGFloat((rgb >> 24) & 0xFF) / 255.0
        )
    }
}