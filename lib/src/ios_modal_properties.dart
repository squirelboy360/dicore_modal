import 'package:flutter/material.dart';

enum UIModalPresentationStyle {
  automatic,
  pageSheet,
  formSheet,
  fullScreen,
  currentContext,
  overFullScreen,
  overCurrentContext,
  popover,
  none
}

enum UIModalTransitionStyle {
  coverVertical,
  crossDissolve,
  flipHorizontal,
  partialCurl
}

class IOSModalTitleBarButton {
  final String? title;
  final String? systemImageName;
  final String? assetImageName;
  final Color? tintColor;
  final VoidCallback? onPressed;

  const IOSModalTitleBarButton({
    this.title,
    this.systemImageName,
    this.assetImageName,
    this.tintColor,
    this.onPressed,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'systemImageName': systemImageName,
    'assetImageName': assetImageName,
    'tintColor': tintColor?.value,
  };
}

class IOSModalTitleBar {
  final bool visible;
  final String? title;
  final TextStyle? titleStyle;
  final IOSModalTitleBarButton? leading;
  final IOSModalTitleBarButton? trailing;
  final Color? backgroundColor;
  final bool showsDivider;

  const IOSModalTitleBar({
    this.visible = true,
    this.title,
    this.titleStyle,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.showsDivider = true,
  });

  Map<String, dynamic> toMap() => {
    'visible': visible,
    'title': title,
    'titleStyle': {
      'fontSize': titleStyle?.fontSize,
      'fontWeight': titleStyle?.fontWeight?.index,
      'color': titleStyle?.color?.value,
    },
    'leading': leading?.toMap(),
    'trailing': trailing?.toMap(),
    'backgroundColor': backgroundColor?.value,
    'showsDivider': showsDivider,
  };
}

class IOSModalProperties {
  final double cornerRadius;
  final bool isDismissable;
  final UIModalPresentationStyle presentationStyle;
  final UIModalTransitionStyle transitionStyle;
  final bool interactiveWithScroll;
  final double? maxHeight;
  final bool detents;
  final bool prefersScrollingExpandsWhenScrolledToEdge;
  final IOSModalTitleBar titleBar;
  final bool enableDrag;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final bool keyboardDismissMode;
  final bool swipeToDismiss;
  final double? initialChildSize;
  final double? minChildSize;
  final double? maxChildSize;

  const IOSModalProperties({
    this.cornerRadius = 10.0,
    this.isDismissable = true,
    this.presentationStyle = UIModalPresentationStyle.pageSheet,
    this.transitionStyle = UIModalTransitionStyle.coverVertical,
    this.interactiveWithScroll = true,
    this.maxHeight,
    this.detents = true,
    this.prefersScrollingExpandsWhenScrolledToEdge = true,
    this.titleBar = const IOSModalTitleBar(),
    this.enableDrag = true,
    this.backgroundColor,
    this.padding = EdgeInsets.zero,
    this.keyboardDismissMode = true,
    this.swipeToDismiss = true,
    this.initialChildSize,
    this.minChildSize,
    this.maxChildSize,
  });

  Map<String, dynamic> toMap() => {
    'cornerRadius': cornerRadius,
    'isDismissable': isDismissable,
    'presentationStyle': presentationStyle.index,
    'transitionStyle': transitionStyle.index,
    'interactiveWithScroll': interactiveWithScroll,
    'maxHeight': maxHeight,
    'detents': detents,
    'prefersScrollingExpandsWhenScrolledToEdge': prefersScrollingExpandsWhenScrolledToEdge,
    'titleBar': titleBar.toMap(),
    'enableDrag': enableDrag,
    'backgroundColor': backgroundColor?.value,
    'padding': {
      'top': padding.top,
      'left': padding.left,
      'bottom': padding.bottom,
      'right': padding.right,
    },
    'keyboardDismissMode': keyboardDismissMode,
    'swipeToDismiss': swipeToDismiss,
    'initialChildSize': initialChildSize,
    'minChildSize': minChildSize,
    'maxChildSize': maxChildSize,
  };
}