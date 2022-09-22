import 'package:bvvm/bvvm.dart';
import 'package:flutter/material.dart';
import 'package:maestro_annotations/maestro_annotations.dart';


@MaestroRoute( name: 'store_front' )
class StoreFrontPage extends StatefulWidget {

  const StoreFrontPage({Key? key}) : super(key: key);

  @override
  State<StoreFrontPage> createState() => _StoreFrontPageState();
}

class _StoreFrontPageState extends BVVMState<StoreFrontPage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }

}
