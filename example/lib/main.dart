import 'package:maestro_core/maestro_core.dart';
import 'package:flutter/material.dart';
import 'package:framework_example/framework_example.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Application application = await ExampleFramework().init();

  runApp( App.create(
    application: application,
    initialRoute: Maestro.routes.myRouteStoreFront,
  ) );

}