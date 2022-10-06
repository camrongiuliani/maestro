import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_core/maestro_core.dart';
import 'mocks/component.dart';

Application get headlessApp => Application.headless( storageID: '${DateTime.now().millisecondsSinceEpoch}' );

void main() {
  group( 'Module Tests', () {

    test( 'Module Init', () async {
      Application app = headlessApp;
      await app.init();

      ModuleImpl module = ModuleImpl( application: app );

      expect( module.initialized, false );
      await module.init();
      expect( module.initialized, isTrue );

      module.buildRoutes();
      expect( module.routes.isEmpty, isTrue );

      module.buildSlices();
      expect( module.slices.isEmpty, isTrue );

      expect( module.activeProvider, isNull );
    });

    test( 'Module Bus Test', () async {
      Application app = headlessApp;
      await app.init();

      ModuleImpl module = ModuleImpl( application: app );
      await module.init();

      expect( module.bus.on().first, completion( equals( 1 ) ) );
      module.emit( 1 );
    });

    test( 'Module Bus Merge Test', () async {
      Application app = headlessApp;
      ModuleImpl module = ModuleImpl( application: app );

      await module.init();

      app.register<ModuleImpl>( module );

      await app.init();

      expect( app.onEvent().first, completion( equals( 1 ) ) );
      expect( module.bus.on().first, completion( equals( 1 ) ) );
      module.emit( 1 );
    });

    testWidgets( 'Module Active Provider Test 1', ( tester ) async {
      Application app = headlessApp;

      ModuleImpl module = ModuleImpl( application: app );
      await module.init();

      ModuleImpl2 module2 = ModuleImpl2( application: app );
      await module2.init();

      app.register<ModuleImpl>( module );
      app.register<ModuleImpl2>( module2 );

      await app.init();

      await tester.runAsync(() async {
        await tester.pumpWidget(
          App.create(
            application: app,
            initialRoute: '/',
          ),
        );

        await tester.pumpAndSettle( const Duration( seconds: 1 ) );

        var providers = tester.elementList( find.byType( ModuleProvider ) );

        expect( providers.length, 1 );

        app.router.pushNamed( '/2' );

        await tester.pumpAndSettle( const Duration( seconds: 1 ) );

        await expectLater( Future<int>.delayed( const Duration( seconds: 1 ), () {
          return tester.elementList( find.byType( ModuleProvider, skipOffstage: false ) ).length;
        }), completion( equals( 2 ) ) );

        await expectLater( Future<bool>.delayed( const Duration( seconds: 1 ), () {
          try {
            return app.activeProvider == module2.activeProvider;
          } catch ( e ) {
            return false;
          }
        }), completion( isTrue ) );

      });
    });
  });
}