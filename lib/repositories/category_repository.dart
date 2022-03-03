import 'package:webixes/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:webixes/data_model/category_response.dart';
import 'package:webixes/helpers/shared_value_helper.dart';

class CategoryRepository {

  Future<CategoryResponse> getCategories({parent_id = 0}) async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/categories?parent_id=${parent_id}");
    final response =
    await http.get(url,headers: {
      "App-Language": app_language.$,
    });
    print("${AppConfig.BASE_URL}/categories?parent_id=${parent_id}");
    print("cat res-->${response.body}");
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getFeturedCategories() async {
    //http://citydeal.co.in/api/v2/categories/featured
    Uri url = Uri.parse("${AppConfig.BASE_URL}/categories/featured");
   // Uri url = Uri.parse("http://citydeal.co.in/api/v2/categories/featured");
    final response =
        await http.get(url,headers: {
          "App-Language": app_language.$,
        });
    //print(response.body.toString());
    //print("--featured cat--");
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getTopCategories() async {

    Uri url = Uri.parse("${AppConfig.BASE_URL}/categories/top");
    final response =
    await http.get(url,headers: {
      "App-Language": app_language.$,
    });
    print("cat res-->${response.body}");
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getFilterPageCategories() async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/filter/categories");
    final response =
    await http.get(url,headers: {
      "App-Language": app_language.$,
    });
    return categoryResponseFromJson(response.body);
  }

}
