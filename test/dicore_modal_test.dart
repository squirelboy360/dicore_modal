import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dicore_modal/dicore_modal.dart';
import 'package:dicore_modal/src/dicore_modal_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDicoreModalPlatform
    with MockPlatformInterfaceMixin
    implements DicoreModalPlatform {
  final List<String> methodCalls = [];

  @override
  Future<void> showModal({
    required BuildContext context,
    required WidgetBuilder builder,
    required IOSModalProperties properties,
    required String modalId,
  }) async {
    methodCalls.add('showModal');
  }

  @override
  Future<void> dismissModal([String? modalId]) async {
    methodCalls.add('dismissModal');
  }
}

void main() {
  late MockDicoreModalPlatform mockPlatform;
  late BuildContext context;

  setUp(() {
    mockPlatform = MockDicoreModalPlatform();
    DicoreModalPlatform.instance = mockPlatform;
    context = MockBuildContext();
  });

  group('DicoreModal', () {
    test('can show modal', () async {
      await DicoreModal.show(
        context: context,
        builder: (context) => const SizedBox(),
      );

      expect(mockPlatform.methodCalls, ['showModal']);
    });

    test('can dismiss modal', () async {
      await DicoreModal.dismiss(context);
      expect(mockPlatform.methodCalls, ['dismissModal']);
    });
  });
}

class MockBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
