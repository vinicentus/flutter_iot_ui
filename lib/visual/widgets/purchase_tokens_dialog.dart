import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iot_ui/core/viewmodels/token_manager_model.dart';
import 'package:provider/provider.dart';

class PurchaseTokensDialog extends StatefulWidget {
  @override
  State<PurchaseTokensDialog> createState() => _PurchaseTokensDialogState();
}

class _PurchaseTokensDialogState extends State<PurchaseTokensDialog> {
  // TODO: maybe move into model
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      // This notifies the UI of a new value in the TextEditingCOntroller.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<TokenManagerPageModel>();

    return AlertDialog(
      title: Text(
        'How many?',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.always,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                print('empty');
                return 'Can\'t be empty';
              }
              return null;
            },
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          Text(
              'Cost (in wei): ${model.calculatePurchasePrice(_controller.text)}'),
          Text('Current balance (in wei): ${model.currentUserBalance}'),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ElevatedButton(
                onPressed: () {
                  // Setstate is note needed because we have defined a listener...
                  _controller.text = '0';
                },
                child: Text('min')),
            ElevatedButton(
                onPressed: () {
                  // Setstate is note needed because we have defined a listener...
                  _controller.text = model.computeMaxPurchaseableAMount();
                },
                child: Text('max')),
          ]),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context, 'cancel');
            },
            child: Text('cancel')),
        TextButton(
            onPressed: () {
              model.purchaseTokens(_controller.text);
              Navigator.pop(context, 'purchase');
            },
            child: Text('purchase'))
      ],
    );
  }
}
