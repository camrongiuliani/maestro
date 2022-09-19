library framework_example;

import 'dart:async';

import 'package:maestro/framework.dart';
import 'package:maestro_annotations/base.dart';
import 'package:onboarding_module/module.dart';

@MaestroApp()
class ExampleApp {

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
