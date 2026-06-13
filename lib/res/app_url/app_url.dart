class AppUrl {
  static const String serverBaseUrl = "http://69.62.75.208:8000";
  static const String baseUrl = "$serverBaseUrl/api";
  // static const String baseUrl = "https://traders.testwebs.in/api";
  static const String localUrl = "http://127.0.0.1:8000/api";
  static const String imageBaseUrl = serverBaseUrl;
  static const String addVendor = "$baseUrl/vendors/";
  static const String product = "$baseUrl/products/";
  static const String channels = "$baseUrl/channels/";
  static const String orders = "$baseUrl/orders/";
  static const String wpsReturn = "$baseUrl/wps-return/";
  static const String inventory = "$baseUrl/inventory/";
  static const String inventoryAdjust = "$baseUrl/inventory/adjust/";
  static const String stockDetails = "$baseUrl/low-stck/";
  static const String returnOrders = "$baseUrl/return-filter-history/";

  static const String loginOtp = "$baseUrl/login/";
  static const String appLogin = "$baseUrl/app/login/";
  static const String createBill = "$baseUrl/order-bills-perticuler";
  static const String allBills = "$baseUrl/all-bills";
  static const String barcodeScan = "$baseUrl/scan-barcode-product";
  static const String barcodeGenerate = "$baseUrl/genrate-barcode";
  static const String hsnCode = "$baseUrl/hsn/";
  static const String lowStock = "$baseUrl/low-stock-products/";
  static const String vendorDetails = "$baseUrl/vendor-dashboard/";
  static const String bestSellingProducts = "$baseUrl/product-list";
  static const String purchaseItem = "$baseUrl/purchase-item";
  static const String getPurchaseDetails = "$baseUrl/purchase-list";
  static const String updatePurchase = "$baseUrl/purchase-update";
  static const String deletePurchase = "$baseUrl/purchase-delete";

  // courier return
  static const String courierReturn = "$baseUrl/courier-return/";
  static const String courierReturnList = "$baseUrl/courier-return-list/";
  // customer return
  static const String customerReturn = "$baseUrl/customer-return/";
  static const String customerReturnList = "$baseUrl/customer-return-list/";

  static const String orderBarcode = "$baseUrl/order-barcodes/";
  static const String editProduct = "$baseUrl/products-update";
  static const String updateVendor = '$baseUrl/vendors-updated/';
  static const String deleteProduct = "$baseUrl/products-delete";
  static const String uploadImage = "$baseUrl/upload-image/";
  static const String cancelOrder = "$baseUrl/order";
  static const String deleteOrder = "$baseUrl/order";
  static const String createCourierPartner = "$baseUrl/courier/create/";
  static const String courierList = '$baseUrl/courier/list/';
  static const String createShipment = "$baseUrl/order";
  static const String packOrder = "$baseUrl/order-ui-pack";
  static const String shipmentList = "$baseUrl/order-with-shipments";
  static const String returnReport = "$baseUrl/return-report/";
  static const String orderStatus = "$baseUrl/order-status/";
  static const String appDashboard = "$baseUrl/app/dashboard/";
  static const String appProducts = "$baseUrl/app/products/";
  static const String appVendors = "$baseUrl/app/vendors/";
  static const String appUsers = "$baseUrl/app/users/";
  static const String appPurchases = "$baseUrl/app/purchases/";
  static const String appOrders = "$baseUrl/app/orders/";

  static String mediaUrl(String path) {
    final raw = path.trim();
    if (raw.isEmpty) return "";
    if (raw.startsWith("http://") || raw.startsWith("https://")) return raw;
    return "$imageBaseUrl${raw.startsWith("/") ? raw : "/$raw"}";
  }
}

//
// class AppUrl {
//   static const String baseUrl  = 'http://192.168.1.24:8000/api';
//
//   static const String addVendor = "$baseUrl/vendors/";
//   static const String product = "$baseUrl/products/";
//   static const String channels = "$baseUrl/channels/";
//   static const String orders = "$baseUrl/orders/";
//   static const String wpsReturn = "$baseUrl/wps-return/";
//   static const String inventory = "$baseUrl/inventory/";
//   static const String inventoryAdjust = "$baseUrl/inventory/adjust/";
//   static const String stockDetails = "$baseUrl/low-stck/";
//   static const String returnOrders = "$baseUrl/return-filter-history/";
//
//   static const String loginOtp = "$baseUrl/login/";
//   static const String createBill = "$baseUrl/order-bills-perticuler";
//   static const String allBills = "$baseUrl/all-bills";
//   static const String barcodeScan = "$baseUrl/scan-barcode-product";
//   static const String barcodeGenerate = "$baseUrl/genrate-barcode";
//   static const String hsnCode = "$baseUrl/hsn/";
//   static const String lowStock = "$baseUrl/low-stock-products/";
//   static final String vendorDetails = "$baseUrl/vendor-dashboard/";
//   static const String bestSellingProducts = "$baseUrl/product-list";
//   static const String purchaseItem = "$baseUrl/purchase-item";
//   static const String getPurchaseDetails = "$baseUrl/purchase-list";
//
//   // courier return
//   static const String courierReturn = "$baseUrl/courier-return/";
//   static const String courierReturnList = "$baseUrl/courier-return-list/";
//   // customer return
//   static const String customerReturn = "$baseUrl/customer-return/";
//   static const String customerReturnList = "$baseUrl/customer-return-list/";
//
//   static const String orderBarcode = "$baseUrl/order-barcodes/";
// }
