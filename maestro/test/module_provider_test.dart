import 'package:flutter/widgets.dart' hide Router;
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_core/maestro_core.dart';

import 'mocks/component.dart';

Application get headlessApp => Application.headless( storageID: '${DateTime.now().millisecondsSinceEpoch}' );

void main() {

  group( 'ModuleProvider Tests', () {

    testWidgets('Module Provider Update Should Notify Test', (tester) async {
      await tester.pumpWidget(
        ModuleProvider(
          module: ModuleImpl( application: headlessApp ),
          widget: Container(),
        ),
      );

      var e = tester.element( find.byType( ModuleProvider ) );
      expect( e.widget, isA<ModuleProvider>() );
      var ap = e.widget as ModuleProvider;

      expect( ap.updateShouldNotify( ap ), isFalse );
    });

    testWidgets('Module Provider Module Exists Up Test', (tester) async {

      await tester.pumpWidget(
        ModuleProvider(
          module: ModuleImpl( application: headlessApp ),
          widget: Container(),
        ),
      );

      expect(
            () => Module.of(tester.element(find.byType(Container))),
        isNotNull,
        reason: 'Module should not be null.',
      );

      expect(
        Module.maybeOf(tester.element(find.byType(Container))),
        isNotNull,
        reason: 'Module should not be null.',
      );
    });

    testWidgets('Module Provider Module Exists Down 1 Test', (tester) async {

      await tester.pumpWidget(
        Container(
          child: ModuleProvider(
            module: ModuleImpl( application: headlessApp ),
            widget: const SizedBox(),
          ),
        ),
      );

      var rootElement = tester.element(find.byType(Container));

      expect(
            () => Module.of<ModuleImpl>( rootElement, searchDown: true ),
        isNotNull,
        reason: 'Module should not be null.',
      );

      expect(
            () => Module.maybeOf<ModuleImpl>( rootElement, searchDown: true ),
        isNotNull,
        reason: 'Module should not be null.',
      );
    });

    testWidgets('Module Provider Module Exists Down 2 Test', (tester) async {

      await tester.pumpWidget(
        Container(
          child: Padding(
            padding: EdgeInsets.zero,
            child: ModuleProvider(
              module: ModuleImpl( application: headlessApp ),
              widget: const SizedBox(),
            ),
          ),
        ),
      );

      var rootElement = tester.element(find.byType(Container));

      expect(
            () => Module.of<ModuleImpl>( rootElement, searchDown: true ),
        isNotNull,
        reason: 'Module should not be null.',
      );

      expect(
            () => Module.maybeOf<ModuleImpl>( rootElement, searchDown: true ),
        isNotNull,
        reason: 'Module should not be null.',
      );
    });
  });
}