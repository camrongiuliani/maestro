import 'package:bvvm/bvvm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_core/maestro_core.dart';
import 'package:maestro_core/src/models/framework_component.dart';

import 'mocks/component.dart';

Application get headlessApp => Application.headless( storageID: '${DateTime.now().millisecondsSinceEpoch}' );

void main() {

  group('Application', () {

    test( 'App Init', () async {
      Application app = Application();
      expect( app.initialized, false );
      await app.init();
      expect( app.initialized, isTrue );
      expect( app.modules.isEmpty, isTrue );
      expect( app.services.isEmpty, isTrue );
    });

    test( 'App Dispose', () async {
      // TODO: Write better test.
      Application app = headlessApp;
      expect( app.initialized, false );
      app.register<ModuleImpl>( ModuleImpl( application: app ) );
      await app.init();
      await expectLater( app.dispose(), completion( isNot( throwsException ) ) );
    });

    test( 'App Init Debug', () async {
      Application app = headlessApp;
      expect( app.initialized, false );
      await app.init();
      expect( app.initialized, isTrue );
      expect( app.modules.isEmpty, isTrue );
      expect( app.services.isEmpty, isTrue );
    });

    test( 'App Bus Test', () async {
      Application app = headlessApp;
      await app.init();
      expect( app.onEvent().first, completion( equals( 1 ) ) );
      app.emit( 1 );
    });

    test( 'App Register Non-Typed Test', () async {
      Application app = headlessApp;
      await app.init();

      expect( () {
        app.component();
      }, throwsAssertionError );
    });

    test( 'App Register Single Async Module Test', () async {
      Application app = headlessApp;
      app.registerAsync<ModuleImpl>( FrameworkComponentBuilder(() => ModuleImpl( application: app )) );
      await app.init();
      expect( app.initialized, isTrue );
      expect( app.modules.isEmpty, isTrue );
      expect( app.services.isEmpty, isTrue );
      await app.loadAsyncComponent<ModuleImpl>();
      expect( app.modules.length, 1 );
      expect( app.services.isEmpty, isTrue );
    });

    test( 'App Load Async Module Twice Test', () async {
      Application app = headlessApp;
      app.registerAsync<ModuleImpl>( FrameworkComponentBuilder(() => ModuleImpl( application: app )) );
      await app.init();
      expect( app.initialized, isTrue );
      expect( app.modules.isEmpty, isTrue );
      expect( app.services.isEmpty, isTrue );
      await app.loadAsyncComponent<ModuleImpl>();
      await app.loadAsyncComponent<ModuleImpl>();
      expect( app.modules.length, 1 );
      expect( app.services.isEmpty, isTrue );
    });

    test( 'App Destroy Mutable Storage Test', () async {
      Application app = headlessApp;
      app.registerAsync<ModuleImpl>( FrameworkComponentBuilder(() => ModuleImpl( application: app )) );
      await app.init();
      await app.set( 'testKey', 'testVal' );
      await app.flush( debugAllowImmutableFlush: true );
      var read = await app.get( 'testKey' );
      expect( read, isNull );
    });

    test( 'App Get Persist Test', () async {
      Application app = headlessApp;
      await app.init();

      await app.flush( debugAllowImmutableFlush: true );

      await expectLater( app.get( 'deviceID', persistent: true ), completion( isNull ) );

      await app.set( 'deviceID', 1, persistent: true );

      await expectLater( app.get( 'deviceID', persistent: true ), completion( equals( 1 ) ) );
    });

    test( 'App Get Mutable Test', () async {
      Application app = headlessApp;
      await app.init();

      await app.flush( debugAllowImmutableFlush: true );

      await expectLater( app.get( 'deviceID' ), completion( isNull ) );

      await app.set( 'deviceID', 1 );

      await expectLater( app.get( 'deviceID' ), completion( equals( 1 ) ) );
    });

    test( 'App Check Component Exists Test', () async {
      Application app = headlessApp;
      await app.init();

      app.register<ModuleImpl>( ModuleImpl( application: app ) );

      expect( app.componentExists<ModuleImpl>(), isTrue );
      expect( app.componentExists<ModuleImpl2>(), isFalse );
    });

    test( 'App Register Duplicate Async Module Test', () async {
      Application app = headlessApp;
      app.registerAsync<ModuleImpl>( FrameworkComponentBuilder(() => ModuleImpl( application: app )) );
      expect( () {
        app.registerAsync<ModuleImpl>( FrameworkComponentBuilder(() => ModuleImpl( application: app )) );
      }, throwsAssertionError );
    });

    test( 'App Register Duplicate Module Type Sync/Async Test', () async {
      Application app = headlessApp;
      app.registerAsync<ModuleImpl>( FrameworkComponentBuilder(() => ModuleImpl( application: app )) );
      expect( () {
        app.register<ModuleImpl>( ModuleImpl( application: app ) );
      }, throwsAssertionError );
    });

    test( 'App Register Single Module Test', () async {
      Application app = headlessApp;
      app.register<ModuleImpl>(ModuleImpl( application: app ));
      await app.init();
      expect( app.initialized, isTrue );
      expect( app.modules.length, 1 );
      expect( app.services.isEmpty, isTrue );
    });

    test( 'App Register Duplicate Module Test', () async {
      Application app = headlessApp;
      app.register<ModuleImpl>(ModuleImpl( application: app ));
      expect( () {
        app.register<ModuleImpl>(ModuleImpl( application: app ));
      }, throwsAssertionError );
    });

    test( 'App Register Two Modules Test', () async {
      Application app = headlessApp;
      app.register<ModuleImpl>(ModuleImpl( application: app ));
      app.register<ModuleImpl2>(ModuleImpl2( application: app ));
      await app.init();
      expect( app.initialized, isTrue );
      expect( app.modules.length, 2 );
      expect( app.services.isEmpty, isTrue );
    });

    test( 'App Get Module Test', () async {
      Application app = headlessApp;
      app.register<ModuleImpl>(ModuleImpl( application: app ));
      await app.init();

      expect( app.component<ModuleImpl>(), isNotNull );
      expect( app.component<ModuleImpl>(), isA<ModuleImpl>() );
      expect( app.component<ModuleImpl>(), isA<Module>() );
      expect( app.component<ModuleImpl>(), isA<FrameworkComponent>() );
      expect( app.component<ModuleImpl>().initialized, false );
    });

    test( 'App Receive Module Event Test', () async {
      Application app = headlessApp;
      app.register<ModuleImpl>(ModuleImpl( application: app ));
      await app.init();

      expect( app.onEvent().first, completion( equals( 1 ) ) );
      app.component<ModuleImpl>().emit( 1 );
    });

    test( 'App Register Single Service Test', () async {
      Application app = headlessApp;
      app.register<ServiceImpl>(ServiceImpl( application: app ));
      await app.init();
      expect( app.initialized, isTrue );
      expect( app.services.length, 1 );
      expect( app.modules.isEmpty, isTrue );
    });

    test( 'App Register Single Async Service Test', () async {
      Application app = headlessApp;
      app.registerAsync<ServiceImpl>( FrameworkComponentBuilder(() => ServiceImpl( application: app )) );
      await app.init();
      expect( app.initialized, isTrue );
      expect( app.modules.isEmpty, isTrue );
      expect( app.services.isEmpty, isTrue );
      await app.loadAsyncComponent<ServiceImpl>();
      expect( app.services.length, 1 );
      expect( app.modules.isEmpty, isTrue );
    });

    test( 'App Register Duplicate Async Service Test', () async {
      Application app = headlessApp;
      app.registerAsync<ServiceImpl>( FrameworkComponentBuilder(() => ServiceImpl( application: app )) );
      expect( () {
        app.registerAsync<ServiceImpl>( FrameworkComponentBuilder(() => ServiceImpl( application: app )) );
      }, throwsAssertionError );
    });

    test( 'App Register Duplicate Service Type Sync/Async Test', () async {
      Application app = headlessApp;
      app.registerAsync<ServiceImpl>( FrameworkComponentBuilder(() => ServiceImpl( application: app )) );
      expect( () {
        app.register<ServiceImpl>( ServiceImpl( application: app ) );
      }, throwsAssertionError );
    });

    test( 'App Register Duplicate Async Service Test', () async {
      Application app = headlessApp;
      app.registerAsync<ServiceImpl>( FrameworkComponentBuilder(() => ServiceImpl( application: app )) );
      expect( () {
        app.registerAsync<ServiceImpl>( FrameworkComponentBuilder(() => ServiceImpl( application: app )) );
      }, throwsAssertionError );
    });

    test( 'App Register Duplicate Service Test', () async {
      Application app = headlessApp;
      app.register<ServiceImpl>(ServiceImpl( application: app ));
      expect( () {
        app.register<ServiceImpl>(ServiceImpl( application: app ));
      }, throwsAssertionError );
    });

    test( 'App Register Two Services Test', () async {
      Application app = headlessApp;
      app.register<ServiceImpl>(ServiceImpl( application: app ));
      app.register<ServiceImpl2>(ServiceImpl2( application: app ));
      await app.init();
      expect( app.initialized, isTrue );
      expect( app.services.length, equals( 2 ) );
      expect( app.modules.isEmpty, isTrue );
    });

    test( 'App Get Service Test', () async {
      Application app = headlessApp;
      app.register<ServiceImpl>(ServiceImpl( application: app ));
      await app.init();

      expect( app.component<ServiceImpl>(), isNotNull );
      expect( app.component<ServiceImpl>(), isA<ServiceImpl>() );
      expect( app.component<ServiceImpl>(), isA<FrameworkComponent>() );
      expect( app.component<ServiceImpl>().initialized, isFalse );
    });

    test( 'App Receive Service Event Test', () async {
      Application app = headlessApp;
      app.register<ServiceImpl>(ServiceImpl( application: app ));
      await app.init();
      expect( app.onEvent().first, completion( equals( 2 ) ) );
      app.component<ServiceImpl>().emit( 2 );
    });
    

    test( 'App Stores Dump Test', () async {
      Application app = headlessApp;
      await app.init();

      dynamic exception;
      try {
        await app.immutableStorage.dump();
      } catch ( e ) {
        exception = e;
      }

      expect( exception, isAssertionError );

      await app.flush( debugAllowImmutableFlush: true );
      expect( app.mutableStorage.isOpen, isFalse );
      expect( app.immutableStorage.isOpen, isFalse );
    });

    test( 'App Event Store Can Open', () async {
      Application app = headlessApp;
      await app.init();
      await app.mutableStorage.open();
      expect( app.mutableStorage.isOpen, isTrue );
    });

    test( 'App Event Store Does Open On Write Test', () async {
      Application app = headlessApp;
      await app.init();
      expect( app.mutableStorage.isOpen, isFalse );
      await app.mutableStorage.set( 'k1', 1 );
      expect( app.mutableStorage.isOpen, isTrue );
    });

    test( 'App Event Store Dump, Write, Re-Open Test', () async {
      Application app = headlessApp;
      await app.init();
      expect( app.mutableStorage.isOpen, isFalse );
      await app.mutableStorage.set( 'k1', 1 );
      expect( app.mutableStorage.isOpen, isTrue );
      await app.mutableStorage.dump();
      expect( app.mutableStorage.isOpen, isFalse );
      var read = await app.mutableStorage.get('k1');
      expect( app.mutableStorage.isOpen, isTrue );
      expect( read, isNull );
    });

    test( 'App Event Store Write/Read Test', () async {
      Application app = headlessApp;
      await app.init();
      await app.mutableStorage.set( 'k1', 1 );
      var read = await app.mutableStorage.get( 'k1' );
      expect( read, 1, reason: "Written value in event store did not match the read value." );
    });

    test( 'App Persist Store Can Open', () async {
      Application app = headlessApp;
      await app.init();
      await app.immutableStorage.open();
      expect( app.immutableStorage.isOpen, isTrue );
    });

    test( 'App Persist Store Does Open On Write Test', () async {
      Application app = headlessApp;
      await app.init();
      await app.immutableStorage.dump(debugAllowDumpLocked: true);
      expect( app.immutableStorage.isOpen, isFalse );
      var read = await app.immutableStorage.get( 'k2' );
      expect( app.immutableStorage.isOpen, isTrue );
      expect( read, isNull );
      await app.immutableStorage.set( 'k2', 2 );
      expect( app.immutableStorage.isOpen, isTrue );
      read = await app.immutableStorage.get( 'k2' );
      expect( read, equals( 2 ) );
    });

    test( 'App Persist Store Dump, Write, Re-Open Test', () async {
      Application app = headlessApp;
      await app.init();

      await app.immutableStorage.dump( debugAllowDumpLocked: true );

      expect( app.immutableStorage.isOpen, isFalse );

      await app.immutableStorage.set( 'k1', 1 );
      expect( app.immutableStorage.isOpen, isTrue );

      dynamic exception;
      try {
        await app.immutableStorage.dump();
      } catch ( e ) {
        exception = e;
      }

      expect( exception, isAssertionError );

      expect( app.immutableStorage.isOpen, isTrue );

      await app.immutableStorage.dump( debugAllowDumpLocked: true );
      expect( app.immutableStorage.isOpen, isFalse );

      var read = await app.immutableStorage.get('k1');
      expect( app.immutableStorage.isOpen, isTrue );
      expect( read, isNull );
    });

    test( 'App Persist Store Write/Read Test', () async {
      Application app = headlessApp;
      await app.init();
      await app.immutableStorage.set( 'k1', 1 );
      var read = await app.immutableStorage.get( 'k1' );
      expect( read, equals( 1 ), reason: "Written value in persist store did not match the read value." );
    });

    test( 'App Can Route to ContentType', () async {
      Application app = headlessApp;
      app.register<ModuleImpl>( ModuleImpl( application: app ) );
      await app.init();

      expect( app.router.canHandleRoute( 'NaN' ), isFalse, reason: 'App should not be able to route here because no module is registered to handle it.' );
      expect( app.router.canHandleRoute( '/' ), isTrue, reason: 'App should be able to route here because a module is registered to handle it.' );
    });


    test( 'App Slice Exists Test', () async {
      Application app = headlessApp;
      app.register<ModuleImpl2>( ModuleImpl2( application: app ) );
      await app.init();

      expect( app.sliceExists( 'NaN' ), isFalse, reason: 'App should not have this slice because the specified content type should not correlate to a slice.' );
      expect( app.sliceExists( DemoSlice( owner: app.component<ModuleImpl2>() ).id ), isTrue, reason: 'App should have this slice because it is provided by the Mock.' );
    });

    test( 'App Slice Builder Test', () async {
      Application app = headlessApp;
      app.register<ModuleImpl2>( ModuleImpl2( application: app ) );
      await app.init();

      var s = app.slice( DemoSlice( owner: app.component<ModuleImpl2>() ).id );

      expect( s.buildContent(), isA<Container>() );
    });
  });
}