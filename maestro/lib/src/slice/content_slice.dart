import 'package:maestro_core/src/content/content.dart';

abstract class ContentSlice extends Content {

  String get id;

  const ContentSlice({ required super.owner });

}