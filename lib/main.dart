import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/firebase_options.dart';
import 'package:imeasure_mobile/utils/navigator_util.dart';
import 'package:imeasure_mobile/utils/theme_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: iMeasure()));
}

// ignore: camel_case_types
class iMeasure extends StatelessWidget {
  const iMeasure({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeData,
      routes: routes,
      initialRoute: NavigatorRoutes.login,
    );
  }
}
