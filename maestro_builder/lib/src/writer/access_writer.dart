import 'package:code_builder/code_builder.dart';
import 'package:maestro_builder/src/writer/writer.dart';

class AccessWriter extends Writer {

  AccessWriter();

  @override
  Spec write() {
    String className = 'Maestro';

    final classBuilder = ClassBuilder();

    final constructorBuilder = ConstructorBuilder();
    constructorBuilder..constant = true;

    classBuilder..name = className;
    classBuilder..fields.addAll( _getFields() );
    classBuilder..constructors.add( constructorBuilder.build() );

    return classBuilder.build();
  }

  List<Field> _getFields() {
    return [
      // _buildApplication( 'app', 'Application' ),
      _buildField(' routes', '_Routes' ),
      _buildField(' useCases', '_UseCases' ),
      _buildField(' slices', '_Slices' ),
    ];
  }
}

// Field _buildApplication( String name, String type ) {
//   return Field( ( builder) {
//     builder
//       ..name = name
//       ..static = true
//       ..modifier = FieldModifier.constant
//       ..assignment = Code( '$type()' )
//       ..type = refer(type);
//   });
// }

Field _buildField( String name, String type ) {
  return Field( ( builder) {
    builder
      ..name = name
      ..static = true
      ..modifier = FieldModifier.constant
      ..assignment = Code( '$type()' )
      ..type = refer(type);
  });
}