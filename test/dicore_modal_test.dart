import 'package:flutter_test/flutter_test.dart';
import 'package:dicore_modal/dicore_modal.dart';
import 'package:dicore_modal/src/dicore_modal_platform_interface.dart';
import 'package:dicore_modal/src/method_channel_dicore_modal.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/services.dart';

class MockDicoreModalPlatform
    with MockPlatformInterfaceMixin
    implements DicoreModalPlatform {
  @override
  Future<void> showModal(
      String viewId, Map<String, dynamic> properties) async {}

  @override
  Future<void> dismissModal([String? modalId]) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DicoreModal', () {
    late DicoreModal dicoreModal;
    late MockDicoreModalPlatform fakePlatform;

    setUp(() {
      fakePlatform = MockDicoreModalPlatform();
      DicoreModalPlatform.instance = fakePlatform;
      dicoreModal = DicoreModal();
    });

    test('showModal passes correct parameters to platform', () async {
      final String viewId = 'test_modal';
      final Map<String, dynamic> properties = {
        'title': 'Test Modal',
        'backgroundColor': '#FFFFFF',
      };

      await dicoreModal.showModal(viewId, properties);
    });

    test('dismissModal passes correct parameters to platform', () async {
      final String modalId = 'test_modal';
      await dicoreModal.dismissModal(modalId);
    });
  });

  group('MethodChannelDicoreModal', () {
    const MethodChannel channel = MethodChannel('dicore_modal');
    final MethodChannelDicoreModal platform = MethodChannelDicoreModal();
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      log.clear();
    });

    test('showModal sends correct method call', () async {
      final String viewId = 'test_modal';
      final Map<String, dynamic> properties = {
        'title': 'Test Modal',
        'backgroundColor': '#FFFFFF',
      };

      await platform.showModal(viewId, properties);

      expect(log, hasLength(1));
      expect(
        log.first,
        isMethodCall(
          'showModal',
          arguments: {
            'viewId': viewId,
            'properties': properties,
          },
        ),
      );
    });

    test('dismissModal sends correct method call', () async {
      final String modalId = 'test_modal';
      await platform.dismissModal(modalId);

      expect(log, hasLength(1));
      expect(
        log.first,
        isMethodCall(
          'dismissModal',
          arguments: {
            'modalId': modalId,
          },
        ),
      );
    });

    test('dismissModal without modalId sends correct method call', () async {
      await platform.dismissModal();

      expect(log, hasLength(1));
      expect(
        log.first,
        isMethodCall(
          'dismissModal',
          arguments: const {},
        ),
      );
    });
  });
}
