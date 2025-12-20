import 'package:dmj_stock_manager/res/routes/routes.dart';
import 'package:dmj_stock_manager/res/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'bindings/initial_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Read token from local storage
  final storage = GetStorage();
  // final token = storage.read("access_token");
  //
  //    // Decide initial route based on token availability
  // final initialRoute = (token != null && token.isNotEmpty)
  //     ? RouteName.dashboard // already logged in
  //     : RouteName.auth;     // login required

  runApp(const MyApp(initialRoute: RouteName.auth,));
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
      initialRoute: RouteName.auth,
      getPages: AppRoutes.appRoute(),
    );
  }
}




// import 'package:dmj_stock_manager/res/routes/routes.dart';
// import 'package:dmj_stock_manager/res/routes/routes_names.dart';
// import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
// import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
// import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
//
// Future<void> main() async {
//   Get.put(ItemController());
//   Get.put(VendorController());
//   Get.put(StockController());
//   await GetStorage.init();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
//       ),
//       initialRoute: RouteName.auth,
//       getPages: AppRoutes.appRoute(),
//     );
//   }
// }
