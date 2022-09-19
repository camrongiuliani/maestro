library maestro;

import 'package:maestro/maestro.dart';
import 'package:maestro/src/models/framework_component.dart';

abstract class Service extends FrameworkComponent {

  final Application application;

  Service( { required this.application, super.customBus } );

}