import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dicore_modal_platform_interface.dart';
import 'ios_modal_properties.dart';

class MethodChannelDicoreModal extends DicoreModalPlatform {
  final MethodChannel _channel = const MethodChannel('dicore_modal');
  final Map<String, MethodChannel> _modalChannels = {};

  @override
  Future<void> showModal({
    required BuildContext context,
    required WidgetBuilder builder,
    required IOSModalProperties properties,
    required String modalId,
  }) async {
    if (Platform.isIOS || Platform.isMacOS) {
      final MethodChannel buttonChannel = MethodChannel('dicore_modal/$modalId');
      _modalChannels[modalId] = buttonChannel;
      
      buttonChannel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onLeadingButtonTap':
            properties.titleBar.leading?.onPressed?.call();
            break;
          case 'onTrailingButtonTap':
            properties.titleBar.trailing?.onPressed?.call();
            break;
        }
      });

      await _channel.invokeMethod('showModal', {
        'viewId': modalId,
        'properties': properties.toMap(),
      });
    } else {
      await showModalBottomSheet(
        context: context,
        backgroundColor: properties.backgroundColor,
        isScrollControlled: true,
        enableDrag: properties.enableDrag,
        isDismissible: properties.isDismissable,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(properties.cornerRadius),
          ),
        ),
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (properties.titleBar.visible) _buildTitleBar(context, properties),
            Flexible(child: builder(context)),
          ],
        ),
      );
    }
  }

  @override
  Future<void> dismissModal([String? modalId]) async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _channel.invokeMethod('dismissModal', {'modalId': modalId});
      if (modalId != null) {
        _modalChannels.remove(modalId);
      }
    }
  }

  Widget _buildTitleBar(BuildContext context, IOSModalProperties properties) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: properties.titleBar.backgroundColor,
        border: properties.titleBar.showsDivider ? Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 0.5,
          ),
        ) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (properties.titleBar.leading != null)
            _buildButton(properties.titleBar.leading!),
          if (properties.titleBar.title != null)
            Text(
              properties.titleBar.title!,
              style: properties.titleBar.titleStyle,
            ),
          if (properties.titleBar.trailing != null)
            _buildButton(properties.titleBar.trailing!),
        ],
      ),
    );
  }

  Widget _buildButton(IOSModalTitleBarButton button) {
    return TextButton(
      onPressed: button.onPressed,
      style: TextButton.styleFrom(
        foregroundColor: button.tintColor,
      ),
      child: button.title != null
          ? Text(button.title!)
          : button.systemImageName != null
              ? Icon(Icons.adaptive.more)
              : button.assetImageName != null
                  ? Image.asset(button.assetImageName!)
                  : SizedBox(),
    );
  }
}