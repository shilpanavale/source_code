import 'package:webixes/app_config.dart';
import 'package:webixes/data_model/shop_info_by_slug.dart';
import 'package:http/http.dart' as http;
import 'package:webixes/data_model/shop_response.dart';
import 'package:webixes/data_model/shop_details_response.dart';
import 'package:webixes/data_model/product_mini_response.dart';
import 'package:flutter/foundation.dart';
import 'package:webixes/helpers/shared_value_helper.dart';

class ShopRepository {
  Future<ShopResponse> getShops({name = "", page = 1}) async {
    Uri url =
        Uri.parse("${AppConfig.BASE_URL}/shops" + "?page=${page}&name=${name}");
   // Uri.parse("${AppConfig.BASE_URL}/shops" + "?page=${page}&lat=18.520430&lag=73.856743");
    print(url);
    final response = await http.get(url,
      headers: {
        "App-Language": app_language.$,
      },);
    return shopResponseFromJson(response.body);
  }

  Future<ShopResponse> getNearByShops({lat = 0,lag=0}) async {
    Uri url =
    //Uri.parse("${AppConfig.BASE_URL}/shops" + "?page=${page}&name=${name}");
    Uri.parse("${AppConfig.BASE_URL}/shops?lat=${lat}&lag=${lag}");
    print("Near by shop url-->$url");
    final response = await http.get(url,
      headers: {
        "App-Language": app_language.$,
      },);
    return shopResponseFromJson(response.body);
  }
  Future<ShopDetailsResponse> getShopInfo({@required id = 0}) async {

    Uri url =  Uri.parse("${AppConfig.BASE_URL}/shops/details/${id}");
    final response =
        await http.get(url,
          headers: {
            "App-Language": app_language.$,
          },);
    return shopDetailsResponseFromJson(response.body);
  }


  Future<ShopInfoBySlug> getShopInfobySlug({@required shopName = ""}) async {

    Uri url =  Uri.parse("${AppConfig.BASE_URL}/shops/slug/${shopName}");
    final response =
    await http.get(url,
      headers: {
        "App-Language": app_language.$,
      },);
    print(response.body);
    return shopDetailsInfoBySlugResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getTopFromThisSellerProducts({int id = 0}) async {

    Uri url =  Uri.parse("${AppConfig.BASE_URL}/shops/products/top/" + id.toString());
    final response = await http
        .get(url,
      headers: {
        "App-Language": app_language.$,
      },);
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getNewFromThisSellerProducts({int id = 0}) async {

    Uri url =  Uri.parse("${AppConfig.BASE_URL}/shops/products/new/" + id.toString());
    final response = await http
        .get(url,
      headers: {
        "App-Language": app_language.$,
      },);
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getfeaturedFromThisSellerProducts(
      {int id = 0}) async {

    Uri url =  Uri.parse("${AppConfig.BASE_URL}/shops/products/featured/" + id.toString());
    final response = await http
        .get(url,
      headers: {
        "App-Language": app_language.$,
      },);
    return productMiniResponseFromJson(response.body);
  }
}
