import 'package:analyzer/dart/element/element.dart';
import 'package:maestro_builder/src/models/use_case.dart';
import 'package:maestro_builder/src/processor/processor.dart';
import 'package:uuid/uuid.dart';

class UseCaseProcessor extends Processor<ProcessedUseCase> {

  final ClassElement _classElement;
  final String owner;

  UseCaseProcessor( ClassElement owner, this._classElement )
      : owner = owner.displayName;

  @override
  ProcessedUseCase process() {
    return ProcessedUseCase( owner, _classElement.displayName, Uuid() );
  }
}