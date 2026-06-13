import 'package:dmj_stock_manager/res/routes/routes.dart';
import 'package:dmj_stock_manager/res/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'bindings/initial_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setSystemUI();
  await GetStorage.init();

  final storage = GetStorage();
  final token = storage.read("access_token");
  final user = storage.read("app_user");
  final initialRoute = (token is String && token.isNotEmpty && user is Map)
      ? RouteName.dashboard
      : RouteName.auth;

  runApp(MyApp(initialRoute: initialRoute));
}

void _setSystemUI() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor          : Colors.transparent,
      statusBarIconBrightness : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppRoutes.appRoute(),
    );
  }
}
