# Dicore Modal

A Flutter plugin that provides native modal presentations for iOS and macOS platforms with extensive customization options.

## Features

- Native modal presentations on iOS and macOS
- Customizable title bar with leading/trailing buttons
- Support for system icons and custom assets
- Configurable presentation and transition styles
- Swipe-to-dismiss gesture support (iOS)
- Sheet presentation with detents support (iOS 15+)
- Customizable appearance (background color, corner radius, etc.)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dicore_modal: ^0.0.1
```

Then run:

```bash
$ flutter pub get
```

## Usage

### Basic Modal

```dart
await DicoreModal.show(
  viewId: 'unique_modal_id',
  properties: ModalProperties(
    title: 'Modal Title',
    backgroundColor: Colors.white,
    cornerRadius: 10.0,
  ),
);
```

### Customized Title Bar

```dart
await DicoreModal.show(
  viewId: 'modal_with_buttons',
  properties: ModalProperties(
    titleBar: TitleBarProperties(
      title: 'Custom Title Bar',
      leading: ButtonProperties(
        systemImageName: 'xmark',
        tintColor: Colors.blue,
      ),
      trailing: ButtonProperties(
        title: 'Done',
        tintColor: Colors.blue,
      ),
    ),
  ),
);
```

### Sheet Presentation (iOS 15+)

```dart
await DicoreModal.show(
  viewId: 'sheet_modal',
  properties: ModalProperties(
    detents: true,
    prefersScrollingExpandsWhenScrolledToEdge: true,
    cornerRadius: 10.0,
  ),
);
```

## Platform Support

| Platform | Support |
|----------|----------|
| iOS      | ✅       |
| macOS    | ✅       |
| Android  | 🚧       |

## Customization

The modal appearance and behavior can be customized using the following properties:

- `backgroundColor`: Set the modal's background color
- `cornerRadius`: Customize the corner radius
- `presentationStyle`: Choose the modal presentation style
- `transitionStyle`: Select the transition animation style
- `swipeToDismiss`: Enable/disable swipe-to-dismiss gesture (iOS)
- `isDismissable`: Control if the modal can be dismissed
- `padding`: Add custom padding to the modal content

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Dicore (squirelwares@gmail.com)

## Links

- [GitHub Repository](https://github.com/squirelboy360/dicore_modal)
- [Bug/Issue Tracker](https://github.com/squirelboy360/dicore_modal/issues)
