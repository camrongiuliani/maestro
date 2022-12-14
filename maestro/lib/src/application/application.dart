library maestro_core;

import 'dart:async';
import 'package:abstract_kv_store/abstract_kv_store.dart';
import 'package:maestro_core/src/application/registries/component.dart';
import 'package:maestro_core/src/application/registries/route.dart';
import 'package:maestro_core/src/application/registries/slice.dart';
import 'package:maestro_core/src/application/controllers/storage_controller.dart';
import 'package:maestro_core/src/application/utils/frame_mixin.dart';
import 'package:maestro_core/src/application/controllers/view_controller.dart';
import 'package:maestro_core/src/models/framework_component.dart';
import 'package:maestro_core/src/router/framework_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:event_bus/event_bus.dart';
import 'package:uuid/uuid.dart';
import 'package:maestro_core/maestro_core.dart';

part 'bus/bus_part.dart';

class Application extends FrameworkComponent with FrameMixin {

  /// The [Application] singleton instance.
  static Application? _instance;

  /// Type adapters for use with [_StorageController]
  final List<dynamic> typeAdapters;

  /// Logging utility
  final Logger logger;
  
  /// Registry for [FrameworkComponent] dependencies
  final ComponentRegistry _componentRegistry;

  /// Registry for enabled [ContentRoute]s
  final RouteRegistry _routeRegistry;

  /// Registry for enabled [ContentSlice]s
  final SliceRegistry _sliceRegistry;

  /// Registry for enabled [UseCase]s
  final UseCaseManager _useCaseManager;

  /// App level view controller (app bars, nav bars, bottom sheets)
  final ViewController _viewController;

  /// App level storage (mutable and immutable)
  final StorageController _storageController;

  /// Default [Application] constructor.
  Application._( this.typeAdapters, Level logLevel, String? storageID ) :
        logger = Logger(
          level: logLevel,
          printer: PrettyPrinter(),
        ),
        _storageController = StorageController( storageID ),
        _viewController = ViewController( logLevel ),
        _routeRegistry = RouteRegistry( logLevel ),
        _sliceRegistry = SliceRegistry( logLevel ),
        _useCaseManager = UseCaseManager(),
        _componentRegistry = ComponentRegistry( logLevel );

  /// Returns a singleton [_instance] of [Application]
  factory Application( {  List<dynamic> typeAdapters = const [], Level logLevel = Level.verbose } ) {
    return _instance ??= Application._( typeAdapters, logLevel, null );
  }

  /// Creates a non-singleton App instance (for headless and testing).
  factory Application.headless({
    required String storageID,
    List<dynamic> typeAdapters = const [],
    String? initialRoute,
    Level logLevel = Level.verbose,
  }) {
    return Application._( typeAdapters, logLevel, storageID );
  }

  /// [Application] [Router] singleton instance.
  ///
  /// See Also:
  ///   * [Router] - Flutter navigation wrapper,
  ///   * [key] - The single GlobalKey for the [Application] router.
  FrameworkNavigator get router => _navigator ??= FrameworkNavigator( this );

  /// Single set [Router] instance.
  FrameworkNavigator? _navigator;

  /// Returns the [Application] most closely associated with the given context.
  ///
  /// Parameters:
  ///   * [context] - The current BuildContext.
  ///   * [listen] - Whether or not to register the Application as a dependency of [context].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// Application app = Application.of(context);
  /// ```
  ///
  /// The given [BuildContext] will be rebuilt if the state of the route changes
  /// while it is visible (specifically, if [isCurrent] or [canPop] change value).
  static Application of( BuildContext context, { bool listen = true } ) {
    final AppProvider? result = () {
      if ( listen ) {
        return context.dependOnInheritedWidgetOfExactType<AppProvider>();
      } else {
        return context.findAncestorWidgetOfExactType<AppProvider>();
      }
    }();

    assert(result != null, 'No ApplicationWidget found in context');
    return result!.application;
  }

  /// Tries to call [Application.of], and returns null on error.
  static Application? maybeOf( BuildContext context, { bool listen = true } ) {
    try {
      return Application.of( context, listen: listen );
    } catch ( e ) {
      if ( kDebugMode ) {
        print( e );
      }
    }
    return null;
  }

  /// Returns mutable KVStore
  KVStore get mutableStorage => _storageController.mutable;

  /// Returns immutable KVStore
  KVStore get immutableStorage => _storageController.immutable;

  /// Gets a key from StorageController
  Future<T?> get<T>( String key, { bool persistent = false, T? defaultValue } ) {
    return _storageController.get<T>( key, persistent: persistent, defaultValue: defaultValue );
  }

  /// Sets a value for [key] in StorageController
  Future<void> set<T>( String key, T? value, { bool persistent = false } ) {
    return _storageController.set( key, value, persistent: persistent );
  }

  /// Flushes StorageController
  Future<void> flush({ bool debugAllowImmutableFlush = false }) async {
    return _storageController.flush( debugAllowImmutableFlush: debugAllowImmutableFlush );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.v( 'Navigator :: Pushed (${route.settings.name}) on-top of ${previousRoute?.settings.name ?? 'the underlying component'} ' );
  }

  @override
  Future<void> dispose() async {
    await _componentRegistry.flush();
    await _sliceRegistry.flush();
    await _useCaseManager.flush();
    await _routeRegistry.flush();
    await _storageController.flush( debugAllowImmutableFlush: true );
  }

  @override
  init() async {
    logger.v( 'Application Init' );

    if ( initialized ) {
      return;
    }

    await _storageController.init(
      typeAdapters: typeAdapters,
    );

    return super.init();
  }

  // *** Dependency Registries

  /// Registers [FrameworkComponent] of type [T].
  ///
  /// - syncBus - Sync the Component bus with the Application stream, effectively
  /// passing off events to the Application for relay.
  register<T extends FrameworkComponent>( T component, { bool syncBus = true } ) {

    if ( component is Module ) {
      _sliceRegistry.registerFor( component );
      _routeRegistry.registerFor( component );
    } else if ( component is! Service  ) {
      throw Exception('Unsupported Component Registration Attempt');
    }

    for ( var useCase in component.buildUseCases() ) {
      _useCaseManager.registerUseCase( useCase );
    }

    if ( syncBus ) {
      _BusController().merge( component.bus );
    }

    _componentRegistry.register<T>( component );
  }

  /// Registers [FrameworkComponent] of type [T] asynchronously.
  ///
  /// The Component will not build nor initialize until [loadAsyncComponent] is called.
  ///
  registerAsync<T extends FrameworkComponent>( FrameworkComponentBuilder<T> builder ) {
    return _componentRegistry.registerAsync<T>( builder );
  }

  /// Finalizes registration for a previously registered async [FrameworkComponent]
  loadAsyncComponent<T extends FrameworkComponent>() {

    if ( _componentRegistry.exists<T>() ) {
      return _componentRegistry.get<T>();
    }

    var builder = _componentRegistry.getAsyncComponentBuilder<T>();

    _componentRegistry.removeAsyncComponent<T>();

    register(builder.build(), syncBus: builder.syncBus );

    return component;
  }

  /// Returns a registered component of type [T].
  ///
  /// Throws assertion if [T] has not been registered.
  T component<T extends FrameworkComponent>() => _componentRegistry.get<T>();

  /// Checks to see if a component of type [T] has been registered.
  bool componentExists<T extends FrameworkComponent>() => _componentRegistry.exists<T>();

  /// Returns a list of actively registered Modules.
  List<Module> get modules => _componentRegistry.modules;

  /// Returns a list of actively registered services.
  List<Service> get services => _componentRegistry.services;

  /// Check to see if a slice exists for the given type
  bool sliceExists( String id ) => _sliceRegistry.exists( id );

  /// Returns a ContentSlice for the given [id]
  ContentSlice slice( String id ) => _sliceRegistry.getSlice( id );

  // *** UseCase Related

  /// Registers a UseCase
  registerUseCase( covariant UseCase useCase ) {
    _useCaseManager.registerUseCase( useCase );
  }

  /// Checks to see if a UseCase was registered.
  bool useCaseExists( String id ) => _useCaseManager.useCaseExists( id );

  /// Executes a UseCase, passing result to observer (if passed).
  Future<void> callUseCase( String id, { UseCaseObserver? observer, Map<String, dynamic>? args } ) async {
    return _useCaseManager.call( id, observer: observer, args: args );
  }

  /// Execute a UseCase, return as Future. Subscriptions will also be notified.
  Future callUseCaseFuture( String id, [ Map<String, dynamic>? args ] ) {
    return _useCaseManager.callFuture( id, args );
  }

  /// Execute a UseCAse, return as broadcast stream. Subscriptions will also be notified.
  Stream callUseCaseStream( String id, [ Map<String, dynamic>? args ] ) {
    return _useCaseManager.callStream( id, args );
  }

  /// Subscribes to UseCase with [id].
  ///
  /// NOTE: You must call dispose on [UseCaseSubscription]. Not doing so will lead to a leak.
  UseCaseSubscription subscribe( String id, UseCaseObserver observer ) {
    return _useCaseManager.subscribe( id, observer );
  }

  // *** Misc

  /// Returns the currently active ModuleProvider.
  ///
  /// The [ModuleWidget] is responsible for tracking the number of Providers
  /// created by the module.
  ModuleProvider? get activeProvider => _componentRegistry.activeProvider;

  /// Returns the currently active Module by first looking for the [activeProvider].
  ///
  /// The [ModuleWidget] is responsible for tracking the number of Providers
  /// created by the module.
  Module? get activeModule => activeProvider?.module;

  // *** EventBus Related

  /// Listens for events of type [T] or dynamic.
  Stream onEvent<T>() => _BusController().onEvent<T>();

  /// Relays events from the input bus out through the app bus
  StreamSubscription mergeBus<T>( EventBus bus ) => _BusController().merge<T>( bus );

  /// Fires an event from the app bus
  @override
  void emit( event ) => _BusController().emit( event );

  /// Fires an event through the app bus, awaiting a response.
  ///
  /// [timeout] - How long to wait for a response (default 500ms).
  Future<Object?> emitWithResponse( event, { Duration timeout = const Duration( milliseconds: 500, ) } ) {
    return _BusController().emitWithResponse( event, timeout: timeout );
  }

  // *** View Related

  AppViewModel get viewModel => _viewController.viewModel;

  /// Returns the current value for appVar from the view model.
  Widget? get appBar => _viewController.appBar;

  /// Updates the current appBar value in the view model.
  void setAppBar( { Widget? widget, bool betweenFrame = false } ) {
    if ( betweenFrame ) {
      workBetweenFrames([ () => _viewController.setAppBar( widget ) ]);
    } else {
      _viewController.setAppBar( widget );
    }
  }

  /// Updates the current bottomNavigation value in the view model.
  set bottomNavigation( Widget? widget ) => _viewController.bottomNavigation = widget;

  /// Returns the current bottomNavigation value from the view model.
  Widget? get bottomNavigation => _viewController.bottomNavigation;

  /// Updates the current bottomSheet value in the view model.
  ///
  /// - Optional [show] also toggles the bottomSheet value.
  ///
  /// Work is handled in-between render frames to avoid build race conditions.
  setBottomSheet( Widget? widget, [ bool show = true ] ) {
    var work = [
          () => _viewController.setBottomSheet( widget ),
    ];

    if ( show ) {
      work.add(() => _viewController.toggleBottomSheet());
    }

    workBetweenFrames( work );
  }

  /// Toggles the current state of the bottomSheet in the view model.
  void toggleBottomSheet() => _viewController.toggleBottomSheet();

}
