import 'package:dmj_stock_manager/res/app_url/app_url.dart';

import '../../../data/network/network_api_service.dart';
import '../../../model/login_model.dart';

class AuthService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  // Future<dynamic> loginApi(data) async {
  //   dynamic response = await _apiServices.postApi(data, AppUrl.loginOtp);
  //   return response;
  // }

  Future<LoginResponseModel> loginApi(Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(data, AppUrl.loginOtp);
    return LoginResponseModel.fromJson(response);
  }
}
