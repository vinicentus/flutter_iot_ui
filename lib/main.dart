import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/visual/pages.dart';
import 'package:flutter_iot_ui/visual/settings.dart';
import 'package:flutter_iot_ui/visual/svm30_page.dart';
import 'package:flutter_iot_ui/data/web3.dart';
import 'package:web3dart/credentials.dart';

void main() async {
  runApp(MyApp());
  await Web3Manager().loadContracts();
  print(await Web3Manager().loadUser(EthereumAddress.fromHex(
      '0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0',
      enforceEip55: true)));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Graph Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: CarbonDioxidePage.route,
      routes: {
        SVM30Page.route: (context) => SVM30Page(),
        CarbonDioxidePage.route: (context) => CarbonDioxidePage(),
        TemperaturePage.route: (context) => TemperaturePage(),
        HumidityPage.route: (context) => HumidityPage(),
        MassConcentrationPage.route: (context) => MassConcentrationPage(),
        NumberConcentrationPage.route: (context) => NumberConcentrationPage(),
        TypicalParticleSizePage.route: (context) => TypicalParticleSizePage(),
        SettingsPage.route: (context) => SettingsPage(),
      },
    );
  }
}
