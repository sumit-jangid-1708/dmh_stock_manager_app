import 'package:dmj_stock_manager/data/network/network_api_service.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';

class QuotationService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> getQuotationListApi(
    int page,
    int limit,
    String search,
  ) async {
    final response = await _apiServices.getApi(
      "${AppUrl.createQuotation}?search=$search&page=$page&limit=$limit",
    );
    return response;
  }

  Future<dynamic> getQuotationDetailApi(int quotId) async {
    String url = AppUrl.createQuotation;
    if (!url.endsWith('/')) {
      url = "$url/";
    }
    final response = await _apiServices.getApi("$url$quotId/");
    return response;
  }

  Future<dynamic> createQuotationApi(Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(data, AppUrl.createQuotation);
    return response;
  }

  // ✅ New Delete API
  Future<dynamic> deleteQuotationApi(int quotId) async {
    String url = AppUrl.createQuotation;
    if (!url.endsWith('/')) {
      url = "$url/";
    }
    final response = await _apiServices.deleteApi("$url$quotId/");
    return response;
  }

  // ✅ New Update API
  Future<dynamic> updateQuotationApi(int quotId, Map<String, dynamic> data) async {
    String url = AppUrl.createQuotation;
    if (!url.endsWith('/')) {
      url = "$url/";
    }
    final response = await _apiServices.putApi(data, "$url$quotId/");
    return response;
  }

  Future<dynamic> createCompanyApi(Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(data, AppUrl.company);
    return response;
  }

  Future<dynamic> getCompanyList()async{
    final response = await _apiServices.getApi(AppUrl.company);
    return response;
  }

  Future<dynamic> updateCompanyApi(int companyId, Map<String, dynamic> data) async {
    String url = AppUrl.company;
    if (!url.endsWith('/')) {
      url = "$url/";
    }
    final response = await _apiServices.patchApi(data, "$url$companyId/");
    return response;
  }

  Future<dynamic> createBankApi(Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(data, AppUrl.bank);
    return response;
  }

  Future<dynamic> getBankList()async{
    final response = await _apiServices.getApi(AppUrl.bank);
    return response;
  }

  Future<dynamic> updateBankApi(int bankId, Map<String, dynamic> data) async {
    String url = AppUrl.bank;
    if (!url.endsWith('/')) {
      url = "$url/";
    }
    final response = await _apiServices.patchApi(data, "$url$bankId/");
    return response;
  }
}
