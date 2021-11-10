import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Used to show a loding indicator until all necessary singletons are ready and registered with GetIt
class InitialLoadingPage extends StatefulWidget {
  static const String route = '/InitialLoadingPage';

  final String nextRoute;

  const InitialLoadingPage({Key? key, required this.nextRoute})
      : super(key: key);

  @override
  State<InitialLoadingPage> createState() => _InitialLoadingPageState();
}

class _InitialLoadingPageState extends State<InitialLoadingPage> {
  @override
  initState() {
    super.initState();
    GetIt.instance.allReady().then((value) {
      Navigator.of(context).pushReplacementNamed(widget.nextRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: CircularProgressIndicator(),
    ));
  }
}
