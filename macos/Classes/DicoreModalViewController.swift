import FlutterMacOS
import AppKit

class DicoreModalViewController: NSViewController {
    private let flutterEngine: FlutterEngine
    private let properties: [String: Any]
    private let viewId: String
    private let channel: FlutterMethodChannel
    private let registrar: FlutterPluginRegistrar
    private var flutterViewController: FlutterViewController?
    
    init(viewId: String, properties: [String: Any], registrar: FlutterPluginRegistrar) {
        self.viewId = viewId
        self.properties = properties
        self.registrar = registrar
        self.flutterEngine = FlutterEngine(name: "dicore_modal.\(viewId)", project: nil)
        self.flutterEngine.run(withEntrypoint: nil)
        self.channel = FlutterMethodChannel(name: "dicore_modal/\(viewId)", binaryMessenger: registrar.messenger)
        
        super.init(nibName: nil, bundle: nil)
        
        setupModalProperties()
        setupTitleBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFlutterView()
    }
    
    private func setupModalProperties() {
        if let backgroundColor = properties["backgroundColor"] as? Int {
            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor(rgb: backgroundColor).cgColor
        }
        
        if let cornerRadius = properties["cornerRadius"] as? CGFloat {
            view.wantsLayer = true
            view.layer?.cornerRadius = cornerRadius
        }
    }
    
    private func setupTitleBar() {
        guard let titleBarProps = properties["titleBar"] as? [String: Any],
              titleBarProps["visible"] as? Bool ?? true else { return }
        
        let titleBarView = NSView(frame: NSRect(x: 0, y: 0, width: view.frame.width, height: 44))
        titleBarView.translatesAutoresizingMaskIntoConstraints = false
        
        if let title = titleBarProps["title"] as? String {
            let titleLabel = NSTextField(labelWithString: title)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.alignment = .center
            titleLabel.backgroundColor = .clear
            titleLabel.isBezeled = false
            titleLabel.isEditable = false
            titleBarView.addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: titleBarView.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: titleBarView.centerYAnchor)
            ])
        }
        
        if let leadingProps = titleBarProps["leading"] as? [String: Any] {
            let button = createButton(from: leadingProps, isLeading: true)
            button.translatesAutoresizingMaskIntoConstraints = false
            titleBarView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: titleBarView.leadingAnchor, constant: 16),
                button.centerYAnchor.constraint(equalTo: titleBarView.centerYAnchor)
            ])
        }
        
        if let trailingProps = titleBarProps["trailing"] as? [String: Any] {
            let button = createButton(from: trailingProps, isLeading: false)
            button.translatesAutoresizingMaskIntoConstraints = false
            titleBarView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: titleBarView.trailingAnchor, constant: -16),
                button.centerYAnchor.constraint(equalTo: titleBarView.centerYAnchor)
            ])
        }
        
        view.addSubview(titleBarView)
        
        NSLayoutConstraint.activate([
            titleBarView.topAnchor.constraint(equalTo: view.topAnchor),
            titleBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleBarView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        if titleBarProps["showsDivider"] as? Bool ?? true {
            let divider = NSBox()
            divider.boxType = .separator
            divider.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(divider)
            
            NSLayoutConstraint.activate([
                divider.topAnchor.constraint(equalTo: titleBarView.bottomAnchor),
                divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                divider.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }
    
    private func createButton(from props: [String: Any], isLeading: Bool) -> NSButton {
        let button = NSButton(frame: .zero)
        
        if let title = props["title"] as? String {
            button.title = title
        }
        
        if let systemImageName = props["systemImageName"] as? String {
            if #available(macOS 11.0, *) {
                button.image = NSImage(systemSymbolName: systemImageName, accessibilityDescription: nil)
            }
        }
        
        if let tintColor = props["tintColor"] as? Int {
            if #available(macOS 10.14, *) {
                button.contentTintColor = NSColor(rgb: tintColor)
            }
        }
        
        button.target = self
        button.action = isLeading ? #selector(leadingButtonTapped) : #selector(trailingButtonTapped)
        
        return button
    }
    
    @objc private func leadingButtonTapped() {
        channel.invokeMethod("onLeadingButtonTap", arguments: nil)
    }
    
    @objc private func trailingButtonTapped() {
        channel.invokeMethod("onTrailingButtonTap", arguments: nil)
    }
    
    private func setupFlutterView() {
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        let flutterView = flutterViewController.view
        addChild(flutterViewController)
        view.addSubview(flutterView)
        flutterView.translatesAutoresizingMaskIntoConstraints = false
        
        let topView = view.subviews.first { $0 != flutterView }
        
        NSLayoutConstraint.activate([
            flutterView.topAnchor.constraint(equalTo: (topView?.bottomAnchor ?? view.topAnchor)),
            flutterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flutterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            flutterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.flutterViewController = flutterViewController
    }
}

extension NSColor {
    convenience init(rgb: Int) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: CGFloat((rgb >> 24) & 0xFF) / 255.0
        )
    }
}