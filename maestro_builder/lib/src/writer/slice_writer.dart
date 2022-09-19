import 'package:code_builder/code_builder.dart';
import 'package:maestro_builder/src/misc/string_ext.dart';
import 'package:maestro_builder/src/models/slice.dart';
import 'package:maestro_builder/src/writer/writer.dart';

class SliceWriter extends Writer {

  final List<ProcessedSlice> _slices;

  SliceWriter( this._slices );

  @override
  Spec write() {
    String className = '_Slices';

    final classBuilder = ClassBuilder();

    final constructorBuilder = ConstructorBuilder();
    constructorBuilder..constant = true;

    classBuilder..name = className;
    classBuilder..fields.addAll( _getFields() );
    classBuilder..constructors.add( constructorBuilder.build() );

    return classBuilder.build();
  }

  List<Field> _getFields() {
    return _slices.map((e) {
      return Field( ( builder) {
        builder
          ..name = '/${e.owner}/${e.name.split('<')[0]}'.canonicalize
          ..modifier = FieldModifier.final$
          ..assignment = Code( '\'${e.uuid}\'' )
          ..type = refer('String');
      });
    }).toList();
  }
}