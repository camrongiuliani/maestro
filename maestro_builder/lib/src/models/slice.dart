import 'package:uuid/uuid.dart';

class ProcessedSlice {

  final String name;
  final String owner;
  final String uuid;

  ProcessedSlice( this.owner, this.name, Uuid uuid ) : uuid = uuid.v4();

}