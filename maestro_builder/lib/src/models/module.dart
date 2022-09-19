import 'package:maestro_builder/src/models/route.dart';
import 'package:maestro_builder/src/models/slice.dart';
import 'package:maestro_builder/src/models/use_case.dart';

class ProcessedModule {

  final String name;
  final List<ProcessedRoute> _routes;
  final List<ProcessedUseCase> _useCases;
  final List<ProcessedSlice> _slices;

  List<ProcessedRoute> get routes => _routes;
  List<ProcessedUseCase> get useCases => _useCases;
  List<ProcessedSlice> get slices => _slices;

  ProcessedModule( this.name, this._routes, this._useCases, this._slices );
}