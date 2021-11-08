import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/util/view_state_enum.dart';
import 'package:flutter_iot_ui/core/viewmodels/token_manager_model.dart';
import 'package:flutter_iot_ui/visual/widgets/drawer.dart';
import 'package:flutter_iot_ui/visual/widgets/purchase_tokens_dialog.dart';
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
        body: Center(
          child: model.viewState == ViewState.loading
              ? CircularProgressIndicator()
              : Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('token symbol/name: ${model.symbol}'),
                      Text('price per token (in wei): ${model.price}'),
                      Text('capacity: ${model.capacity}'),
                      Text('number of tokens sold: ${model.sold}'),
                      Text('initialized: ${model.initialized}'),
                      Text('task manager: ${model.taskManager.hexEip55}'),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => PurchaseTokensDialog());
                        },
                        child: Text('Purchase tokens (for yourself)'),
                      )
                    ],
                  ),
                ),
        ));
  }
}
