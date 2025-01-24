import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'ios_modal_properties.dart';

abstract class DicoreModalPlatform extends PlatformInterface {
  DicoreModalPlatform() : super(token: _token);
  static final Object _token = Object();
  static DicoreModalPlatform _instance = MethodChannelDicoreModal();
  
  static DicoreModalPlatform get instance => _instance;
  
  static set instance(DicoreModalPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  Future<void> showModal({
    required BuildContext context,
    required WidgetBuilder builder,
    required IOSModalProperties properties,
    required String modalId,
  }) {
    throw UnimplementedError('showModal() has not been implemented.');
  }

  Future<void> dismissModal([String? modalId]) {
    throw UnimplementedError('dismissModal() has not been implemented.');
  }
}