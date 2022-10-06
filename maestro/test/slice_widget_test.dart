import 'package:flutter/widgets.dart' hide Router;
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_core/maestro_core.dart';

import 'mocks/component.dart';

Application get headlessApp => Application.headless( storageID: '${DateTime.now().millisecondsSinceEpoch}' );


class ModuleImpl2 extends Module {
  ModuleImpl2({required super.application});

  @override
  List<ContentSlice> buildSlices() => [
    DemoSlice(
      owner: this,
    ),
  ];
}

void main() {

  group( 'SliceWidget Tests', () {

    testWidgets( 'Slice Widget Test 1', ( tester ) async {
      Application app = headlessApp;

      ModuleImpl3 module = ModuleImpl3( application: app );
      await module.init();

      ModuleImpl2 module2 = ModuleImpl2( application: app );
      await module2.init();

      app.register<ModuleImpl3>( module );
      app.register<ModuleImpl2>( module2 );

      await app.init();

      await tester.runAsync(() async {
        await tester.pumpWidget(
          App.create(
            application: app,
            initialRoute: '/',
          ),
        );

        await tester.pumpAndSettle( const Duration( seconds: 1) );

        var findsRealSlice = find.byKey( const ValueKey('FeatureImageKey') );
        var findsFallbackSlice = find.byKey( const ValueKey('fallback') );

        expect( findsRealSlice, findsOneWidget );
        expect( findsFallbackSlice, findsOneWidget );
      });
    });

  });
}