import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

class UtilService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> barcodeScan(String barcode) async {
    final response = await _apiServices.getApi(
        '${AppUrl.barcodeScan}?barcode=$barcode');
    return response;
  }

  Future<dynamic> generateBarcode (data) async{
    final response = await _apiServices.postApi(data, AppUrl.barcodeGenerate);
    return response;
  }
}