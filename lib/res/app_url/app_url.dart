
class AppUrl {
  static const String baseUrl = "https://traders.testwebs.in/api";
  static const String localUrl = "http://192.168.1.28:8000/api";

  static const String addVendor = "$baseUrl/vendors/";
  static const String product = "$baseUrl/products/";
  static const String channels = "$baseUrl/channels/";
  static const String orders = "$baseUrl/orders/";
  static const String wpsReturn = "$baseUrl/wps-return/";
  static const String customerReturn = "$baseUrl/customer-return/";
  static const String inventory = "$baseUrl/inventory/";
  static const String inventoryAdjust = "$baseUrl/inventory/adjust/";
  static const String stockDetails = "$baseUrl/low-stck/";
  static const String returnOrders = "$baseUrl/return-filter-history/";

  static const String loginOtp =  "$baseUrl/login/";

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
}