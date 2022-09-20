import 'package:maestro_core/maestro_core.dart';

class RequestEvent {

  String uuid;

  dynamic event;

  RequestEvent(this.uuid, this.event);

  ResponseEvent response( dynamic response ) {
    return ResponseEvent( uuid, response, this );
  }
}