library framework_example;

import 'dart:async';

import 'package:maestro_core/maestro_core.dart';
import 'package:maestro_annotations/maestro_annotations.dart';
import 'package:onboarding_module/module.dart';

part 'framework_example.g.dart';

@MaestroApp(
  modules: [
    OnboardingModule,
  ]
)
class ExampleFramework {

  static ExampleFramework? instance;

  ExampleFramework._();

  factory ExampleFramework() {
    return instance ??= ExampleFramework._();
  }

  FutureOr<Application> init() async {
    Application application = Application();

    application.register<OnboardingModule>( OnboardingModule(application) );

    await application.init();

    return application;
  }

}
