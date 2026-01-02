import 'package:dmj_stock_manager/res/routes/routes_names.dart';
import 'package:dmj_stock_manager/view/auth/auth_screen.dart';
import 'package:dmj_stock_manager/view/billings/billing_screen.dart';
import 'package:dmj_stock_manager/view/dashboard/dashboard.dart';
import 'package:dmj_stock_manager/view/history/history_screen.dart';
import 'package:dmj_stock_manager/view/home_screen/home_screen.dart';
import 'package:dmj_stock_manager/view/items/items_screen.dart';
import 'package:dmj_stock_manager/view/orders/order_create_bottom_sheet.dart';
import 'package:dmj_stock_manager/view/orders/order_screen.dart';
import 'package:dmj_stock_manager/view/stock/stock_screen.dart';
import 'package:dmj_stock_manager/view/vendors/vendor_detail_screen.dart';
import 'package:dmj_stock_manager/view/vendors/vendor_screen.dart';
import 'package:get/get.dart';

import '../../bindings/billing_binding.dart';
import '../../bindings/dashboard_binding.dart';
import '../../bindings/item_binding.dart';
import '../../bindings/order_binding.dart';
import '../../bindings/stock_binding.dart';
import '../../bindings/vendor_binding.dart';
import '../../view/billings/bill_detail_screen.dart';

class AppRoutes {
  static List<GetPage> appRoute() => [
    GetPage(name: RouteName.auth, page: () => AuthScreen()),
    GetPage(
        name: RouteName.dashboard,
        page: () => DashboardScreen(),
        binding: DashboardBinding(),
    ),
    GetPage(
        name: RouteName.homeScreen,
        page: () => HomeScreen(),
    ),
    GetPage(
        name: RouteName.itemScreen,
        page: () => ItemsScreen(),
        binding: ItemBinding(),
    ),
    GetPage(
        name: RouteName.stockScreen,
        page: () => StockScreen(),
        binding: StockBinding(),
    ),
    GetPage(
        name: RouteName.vendorScreen,
        page: ()=> VendorScreen(),
        binding: VendorBinding(),
    ),
    // GetPage(
    //     name: RouteName.vendorDetailScreen,
    //     page: ()=> VendorDetailScreen(),
    //     binding: VendorBinding()
    // ),
    GetPage(
        name: RouteName.historyScreen,
        page: ()=> HistoryScreen(),
        binding : OrderBinding(),
    ),
    GetPage(
        name: RouteName.orderScreen,
        page: ()=> OrderScreen(),
        binding: OrderBinding(),
    ),
    GetPage(
        name: RouteName.billingScreen,
        page: ()=>BillingScreen(),
        binding: BillingBinding(),
    ),
    GetPage(
      name:RouteName.billDetail,
      page: () =>  BillDetailScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
