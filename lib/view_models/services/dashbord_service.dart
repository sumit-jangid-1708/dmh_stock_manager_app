import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

class DashbordService {
final NetworkApiServices _apiServices = NetworkApiServices();

Future<dynamic> lowStockapi() async{
  dynamic response = await _apiServices.getApi(AppUrl.lowStock);
  return response;
}


}