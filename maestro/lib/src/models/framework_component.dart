import 'dart:async';
import 'package:maestro_core/maestro_core.dart';
import 'package:maestro_core/src/models/super_navigation_observer.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

abstract class FrameworkComponent extends SuperNavigationObserver implements UseCaseObserver {

  final EventBus bus;

  final GetIt injector;

  bool initialized = false;

  ValueNotifier<bool> progress = ValueNotifier( false );

  FrameworkComponent( { EventBus? customBus } )
      : bus = customBus ?? EventBus(),
        injector = GetIt.asNewInstance();

  @mustCallSuper
  FutureOr<void> init() async {
    initialized = true;
  }

  Future<void> dispose() async {}

  void emit( event ) => bus.fire( event );

  List<UseCase> buildUseCases() => [];

  @override
  void onUseCaseUpdate(UseCaseStatus event) {
    // print( 'Use Case Complete for $runtimeType --> ${event.request.runtimeType}' );
  }

}

class FrameworkComponentBuilder<T extends FrameworkComponent> {

  final Type type;

  final bool syncBus;

  final FrameworkComponent Function() builderFunc;

  FrameworkComponentBuilder(this.builderFunc, { this.syncBus = true }) : type = T;

  T build() => builderFunc() as T;
}