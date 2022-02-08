import 'package:webixes/app_config.dart';
import 'package:webixes/data_model/business_setting_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class BusinessSettingRepository{
  Future<List<BusinessSettingListResponse>> getBusinessSettingList()async{
    Uri url = Uri.parse("${AppConfig.BASE_URL}/business-settings");

   var businessSettings = [
      "facebook_login",
      "google_login",
      "twitter_login",
      "pickup_point"
    ];
  String params= businessSettings.join(',');
    var body = {
      //'keys':params
      "keys":params
    };
    print(body);

    var response = await http.post(url,body: body);
    return businessSettingListResponseFromJson(response.body);

  }
}