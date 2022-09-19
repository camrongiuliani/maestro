import 'package:analyzer/dart/element/element.dart';
import 'package:maestro_builder/src/models/slice.dart';
import 'package:maestro_builder/src/processor/processor.dart';
import 'package:uuid/uuid.dart';

class SliceProcessor extends Processor<ProcessedSlice> {

  final ClassElement _classElement;
  final String owner;

  SliceProcessor( ClassElement owner, this._classElement )
      : owner = owner.displayName;

  @override
  ProcessedSlice process() {
    return ProcessedSlice( owner, _classElement.displayName, Uuid() );
  }
}