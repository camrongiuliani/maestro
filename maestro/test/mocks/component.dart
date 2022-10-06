import 'package:flutter/cupertino.dart';
import 'package:maestro_core/maestro_core.dart';

class ModuleImpl extends Module {

  ModuleImpl({required super.application});

  @override
  List<ContentRoute> buildRoutes() => [
    ContentRoute(
      routeName: '/',
      owner: this,
      builder: ( [args] ) => Container(
        key: const ValueKey( 'bottom' ),
      ),
    ),
  ];
}

class ModuleImpl2 extends Module {
  ModuleImpl2({required super.application});

  @override
  List<ContentRoute> buildRoutes() => [
    ContentRoute(
      routeName: '/2',
      owner: this,
      builder: ( [args] ) => Container(
        key: const ValueKey( 'bottom' ),
      ),
    ),
  ];

  @override
  List<ContentSlice> buildSlices() => [
    DemoSlice(
      owner: this,
    ),
  ];
}

class ModuleImpl3 extends Module {

  ModuleImpl3({required super.application});

  @override
  List<ContentRoute> buildRoutes() => [
    ContentRoute(
      routeName: '/',
      owner: this,
      builder: ( [args] ) => Container(
        key: const ValueKey( 'bottom' ),
        child: Column(
          children: const [
            Slice(
              sliceID: 'DemoSlice',
            ),
            Slice(
              sliceID: 'fallback',
              fallback: SizedBox(
                key: ValueKey( 'fallback' ),
              ),
            )
          ],
        ),
      ),
    ),
  ];
}

class ServiceImpl extends Service {
  ServiceImpl({required super.application});
}

class ServiceImpl2 extends Service {
  ServiceImpl2({required super.application});
}

class DemoSlice extends ContentSlice {

  @override
  String get id => 'DemoSlice';

  DemoSlice({ required super.owner, });

  @override
  Widget buildContent([ ViewArgs? args ]) {
    return Container(
      key: const ValueKey( 'FeatureImageKey' ),
    );
  }
}
