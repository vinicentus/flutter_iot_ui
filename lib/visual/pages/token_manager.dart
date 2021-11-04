import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/viewmodels/token_manager_model.dart';
import 'package:flutter_iot_ui/visual/widgets/drawer.dart';
import 'package:provider/provider.dart';

class TokenManagerPage extends StatefulWidget {
  static const String route = '/TokenManagerPage';

  @override
  State<TokenManagerPage> createState() => _TokenManagerPageState();
}

class _TokenManagerPageState extends State<TokenManagerPage> {
  final String title = 'TokenManager';

  @override
  void initState() {
    super.initState();
    var model = context.read<TokenManagerPageModel>();
    model.init();
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<TokenManagerPageModel>();

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        drawer: NavDrawer(TokenManagerPage.route),
        body: Column(
          children: [Text('template')],
        ));
  }
}
