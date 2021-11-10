import 'package:flutter/material.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd30_datamodel.dart';
import 'package:flutter_iot_ui/core/models/sensors/scd41_datamodel.dart';
import 'package:flutter_iot_ui/core/services/global_deps.dart';
import 'package:flutter_iot_ui/core/viewmodels/graph_settings_model.dart';
import 'package:flutter_iot_ui/core/viewmodels/token_manager_model.dart';
import 'package:flutter_iot_ui/visual/pages/devices.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/mass_concentration.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/number_concentration.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/scdxx_pages.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/typical_particle_size.dart';
import 'package:flutter_iot_ui/visual/pages/initial_loading_page.dart';
import 'package:flutter_iot_ui/visual/pages/settings.dart';
import 'package:flutter_iot_ui/visual/pages/graphs/svm30_page.dart';
import 'package:flutter_iot_ui/visual/pages/token_manager.dart';
import 'package:flutter_iot_ui/visual/pages/users.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

void main() async {
  registerGetItServices();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GraphSettingsModel()),
        ChangeNotifierProvider(create: (_) => TokenManagerPageModel()),
      ],
      child: MaterialApp(
        title: 'Flutter Graph Demo',
        theme: ThemeData(
          // This is the theme of your application.
          primarySwatch: Colors.blue,
        ),
        initialRoute: InitialLoadingPage.route,
        // TODO: clean up
        routes: {
          InitialLoadingPage.route: (context) =>
              // This is where we define the next route after the loading screen
              InitialLoadingPage(nextRoute: SettingsPage.route),
          SVM30Page.route: (context) => SVM30Page(),
          CarbonDioxidePage.route + '/scd30': (context) =>
              CarbonDioxidePage<SCD30SensorDataEntry>(),
          TemperaturePage.route + '/scd30': (context) =>
              TemperaturePage<SCD30SensorDataEntry>(),
          HumidityPage.route + '/scd30': (context) =>
              HumidityPage<SCD30SensorDataEntry>(),
          CarbonDioxidePage.route + '/scd41': (context) =>
              CarbonDioxidePage<SCD41SensorDataEntry>(),
          TemperaturePage.route + '/scd41': (context) =>
              TemperaturePage<SCD41SensorDataEntry>(),
          HumidityPage.route + '/scd41': (context) =>
              HumidityPage<SCD41SensorDataEntry>(),
          MassConcentrationPage.route: (context) => MassConcentrationPage(),
          NumberConcentrationPage.route: (context) => NumberConcentrationPage(),
          TypicalParticleSizePage.route: (context) => TypicalParticleSizePage(),
          SettingsPage.route: (context) => SettingsPage(),
          UsersPage.route: (context) => UsersPage(),
          TokenManagerPage.route: (context) => TokenManagerPage(),
          DevicesPage.route: (context) => DevicesPage(),
        },
        localizationsDelegates: [
          // TODO: remove! seems to be required due to a bug in form_builder_validators (7.1.0)
          FormBuilderLocalizations.delegate,
        ],
      ),
    );
  }
}
