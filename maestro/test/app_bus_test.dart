
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_core/maestro_core.dart';

import 'mocks/component.dart';

void main() {

  group( 'App Event Bus Tests', () {

    test( 'Emit With Response To/From App Test', () async {
      Application app = Application.headless( storageID: '${DateTime.now().millisecondsSinceEpoch}' );
      expect( app.initialized, false );
      await app.init();

      app.onEvent().listen((event) {
        if ( event is RequestEvent && event.event == 1 ) {
          app.emit( event.response( 'one' ) );
        }
      });

      var result = await app.emitWithResponse( 1, timeout: const Duration( seconds: 5 ) );

      expect( result, equals( 'one' ) );

    });

    test( 'Emit With Response Cross Module Test', () async {
      Application app = Application.headless( storageID: '${DateTime.now().millisecondsSinceEpoch}' );

      expect( app.initialized, false );

      app.register<ModuleImpl>( ModuleImpl( application: app ) );

      await app.init();

      app.component<ModuleImpl>().application.onEvent().listen((event) {
        if ( event is RequestEvent && event.event == 2 ) {
          app.component<ModuleImpl>().emit( event.response( 'two' ) );
        }
      });

      var result = await app.emitWithResponse( 2, timeout: const Duration( seconds: 5 ) );

      expect( result, equals( 'two' ) );

    });

  });
}