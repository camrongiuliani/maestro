import 'package:maestro_core/maestro_core.dart';

class ResponseEvent {

  String uuid;

  final dynamic response;

  final RequestEvent request;

  ResponseEvent(this.uuid, this.response, this.request);
}