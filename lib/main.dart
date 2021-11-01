import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/viewmodels/graph_settings_model.dart';
import 'package:flutter_iot_ui/visual/pages/devices.dart';
import 'package:flutter_iot_ui/visual/pages/pages.dart';
import 'package:flutter_iot_ui/visual/pages/settings.dart';
import 'package:flutter_iot_ui/visual/pages/svm30_page.dart';
import 'package:flutter_iot_ui/visual/pages/users.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GraphSettingsModel(),
      child: MaterialApp(
        title: 'Flutter Graph Demo',
        theme: ThemeData(
          // This is the theme of your application.
          primarySwatch: Colors.blue,
        ),
        initialRoute: SettingsPage.route,
        routes: {
          SVM30Page.route: (context) => SVM30Page(),
          CarbonDioxidePage.route: (context) => CarbonDioxidePage(),
          CarbonDioxidePage2.route: (contetx) => CarbonDioxidePage2(),
          TemperaturePage.route: (context) => TemperaturePage(),
          HumidityPage.route: (context) => HumidityPage(),
          MassConcentrationPage.route: (context) => MassConcentrationPage(),
          NumberConcentrationPage.route: (context) => NumberConcentrationPage(),
          TypicalParticleSizePage.route: (context) => TypicalParticleSizePage(),
          SettingsPage.route: (context) => SettingsPage(),
          UsersPage.route: (context) => UsersPage(),
          DevicesPage.route: (context) => DevicesPage(),
        },
      ),
    );
  }
}
