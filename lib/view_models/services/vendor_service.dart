
import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

class VendorService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> getVendors () async{
    dynamic response = await _apiServices.getApi(AppUrl.addVendor);
    return response;
  }

  Future<dynamic> addNewVendor( var data) async{
    dynamic response = await _apiServices.postApi(data, AppUrl.addVendor);
    return response;
  }

  Future<dynamic> vendorDetails(int vendorId) async{
    dynamic response = await _apiServices.getApi("${AppUrl.vendorDetails}$vendorId/");
    return response;
  }
}