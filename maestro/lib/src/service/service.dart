library maestro_core;

import 'package:maestro_core/maestro_core.dart';
import 'package:maestro_core/src/models/framework_component.dart';

abstract class Service extends FrameworkComponent {

  final Application application;

  Service( { required this.application, super.customBus } );

}