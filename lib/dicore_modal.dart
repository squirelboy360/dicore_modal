import 'dart:io';
import 'package:flutter/widgets.dart';
export 'src/ios_modal_properties.dart';
export 'src/modal_icons.dart';
import 'src/dicore_modal_platform_interface.dart';
import 'src/method_channel_dicore_modal.dart';

class DicoreModal {
  static Future<void> show({
    required BuildContext context,
    required WidgetBuilder builder,
    IOSModalProperties properties = const IOSModalProperties(),
    String? modalId,
  }) {
    final String id = modalId ?? DateTime.now().microsecondsSinceEpoch.toString();
    return DicoreModalPlatform.instance.showModal(
      context: context,
      builder: builder,
      properties: properties,
      modalId: id,
    );
  }

  static Future<void> dismiss(BuildContext context, [String? modalId]) async {
    if (Platform.isIOS || Platform.isMacOS) {
      await DicoreModalPlatform.instance.dismissModal(modalId);
    } else {
      Navigator.pop(context);
    }
  }
}