import 'package:meta/meta.dart';

@immutable
class MaestroModule {

  final String baseRoute;
  final List<Type> routes;
  final List<Type> useCases;
  final List<Type> slices;

  /// {@macro PublicRoute}
  const MaestroModule({
    required this.baseRoute,
    this.routes = const [],
    this.useCases = const [],
    this.slices = const [],
  });
}
