


import 'package:flutter/widgets.dart' hide Router;
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_core/maestro_core.dart';

import 'mocks/component.dart';


void main() {

  group( 'AppBarProxy Tests', () {

    testWidgets( 'AppBarProxy Widget Test 1', ( tester ) async {
      Application app = Application.headless( storageID: '${DateTime.now().millisecondsSinceEpoch}' );

      ModuleImpl module = ModuleImpl( application: app );
      await module.init();

      app.register<ModuleImpl>( module );

      await app.init();

      await tester.runAsync(() async {
        await tester.pumpWidget(
          App.create(
            application: app,
            initialRoute: '/',
          ),
        );

        await tester.pumpAndSettle( const Duration( seconds: 1 ) );

        expect(
              () => AppBarProxy.of(tester.element(find.byType(Container))),
          throwsAssertionError,
          reason: 'AppBarProxy SHOULD BE null and call should assert.',
        );

        expect(
          AppBarProxy.maybeOf(tester.element(find.byType(Container))),
          isNull,
          reason: 'AppBarProxy SHOULD BE null and call should assert.',
        );

        app.setAppBar(
          widget: Container(
            key: const ValueKey( 'appBar' ),
          ),
        );

        await tester.pumpAndSettle( const Duration( seconds: 1 ) );

        expect(
              () => AppBarProxy.maybeOf(tester.element(find.byType(Container))),
          isNotNull,
          reason: 'AppBarProxy should not be null.',
        );

      });
      expect(
            () => AppBarProxy.maybeOf(tester.element(find.byType(Container))),
        isNotNull,
        reason: 'AppBarProxy should not be null.',
      );
    });
  });
}