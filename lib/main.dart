import 'package:dmj_stock_manager/res/routes/routes.dart';
import 'package:dmj_stock_manager/res/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'bindings/initial_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  final storage = GetStorage();
  final token = storage.read("access_token");
  final user = storage.read("app_user");
  final initialRoute = (token is String && token.isNotEmpty && user is Map)
      ? RouteName.dashboard
      : RouteName.auth;

  // ── Status Bar fix ──────────────────────
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor           : Colors.transparent,
      statusBarIconBrightness  : Brightness.dark,
      systemNavigationBarColor : Colors.transparent,
    ),
  );
  // ────────────────────────────────────────

  runApp(MyApp(initialRoute: initialRoute));
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
