import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:maestro_annotations/maestro_annotations.dart' as annotations;
import 'package:maestro_builder/src/models/module.dart';
import 'package:maestro_builder/src/models/route.dart';
import 'package:maestro_builder/src/models/slice.dart';
import 'package:maestro_builder/src/models/use_case.dart';
import 'package:maestro_builder/src/processor/processor.dart';
import 'package:maestro_builder/src/processor/route_processor.dart';
import 'package:maestro_builder/src/processor/slice_processor.dart';
import 'package:maestro_builder/src/processor/use_case_processor.dart';
import 'package:maestro_builder/src/type_utils.dart';
import 'package:maestro_builder/src/iterable_extension.dart';

class ModuleProcessor extends Processor<ProcessedModule> {

  final ClassElement _classElement;
  late final DartObject? _moduleAnnotation;
  late final String baseRoute;

  ModuleProcessor( this._classElement ) {
    _moduleAnnotation = _classElement.getAnnotation( annotations.MaestroModule );
    baseRoute = _baseRoute();
  }

  @override
  ProcessedModule process() {

    final useCases = _processUseCases();
    final routes = _processRoutes();
    final slices = _processSlices();

    return ProcessedModule( _classElement.displayName, routes, useCases, slices );

  }

  String _baseRoute() {
    return _moduleAnnotation
        ?.getField( 'baseRoute' )
        ?.toStringValue() ??
        _classElement.displayName;
  }

  List<ProcessedRoute> _processRoutes() {

    return _moduleAnnotation
        ?.getField( 'routes' )
        ?.toListValue()
        ?.mapNotNull((object) => object.toTypeValue()?.element2)
        .whereType<ClassElement>()
        .where( _isRoute )
        .map((e) {
          return RouteProcessor( baseRoute, e ).process();
        })
        .toList() ?? [];
  }

  List<ProcessedSlice> _processSlices() {
    return _moduleAnnotation
        ?.getField( 'slices' )
        ?.toListValue()
        ?.mapNotNull((object) => object.toTypeValue()?.element2)
        .whereType<ClassElement>()
        .where( _isSlice )
        .map((e) {
          return SliceProcessor( _classElement, e ).process();
        })
        .toList() ?? [];
  }

  List<ProcessedUseCase> _processUseCases() {
    return _moduleAnnotation
        ?.getField( 'useCases' )
        ?.toListValue()
        ?.mapNotNull((object) => object.toTypeValue()?.element2)
        .whereType<ClassElement>()
        .where( _isUseCase )
        .map((e) {
          return UseCaseProcessor( _classElement, e ).process();
        })
        .toList() ?? [];
  }

  bool _isRoute( final ClassElement classElement ) {
    return classElement.hasAnnotation( annotations.MaestroRoute ) &&
        !classElement.isAbstract;
  }

  bool _isSlice( final ClassElement classElement ) {
    return classElement.hasAnnotation( annotations.MaestroSlice ) &&
        !classElement.isAbstract;
  }

  bool _isUseCase( final ClassElement classElement ) {
    return classElement.hasAnnotation( annotations.MaestroUseCase ) &&
        !classElement.isAbstract;
  }
}