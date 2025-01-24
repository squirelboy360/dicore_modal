import Flutter
import UIKit

class DicoreModalViewController: UIViewController {
    private let flutterEngine: FlutterEngine
    private let properties: [String: Any]
    private let viewId: String
    private let channel: FlutterMethodChannel
    private let registrar: FlutterPluginRegistrar
    private var flutterViewController: FlutterViewController
    
    init(viewId: String, properties: [String: Any], registrar: FlutterPluginRegistrar) {
        self.viewId = viewId
        self.properties = properties
        self.registrar = registrar
        self.flutterEngine = (registrar.messenger() as! FlutterEngine)
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
        setupGestures()
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
    
    private func setupFlutterView() {
        flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        if let flutterView = flutterViewController.view {
            view.addSubview(flutterView)
            flutterView.translatesAutoresizingMaskIntoConstraints = false
            
            let topAnchor = view.subviews.first(where: { $0 is UINavigationBar })?.bottomAnchor ?? view.topAnchor
            
            NSLayoutConstraint.activate([
                flutterView.topAnchor.constraint(equalTo: topAnchor),
                flutterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                flutterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                flutterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
    
    private func setupGestures() {
        if properties["swipeToDismiss"] as? Bool ?? true {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            view.addGestureRecognizer(panGesture)
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            if velocity.y > 1000 || translation.y > view.bounds.height / 3 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                }
            }
        default:
            break
        }
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