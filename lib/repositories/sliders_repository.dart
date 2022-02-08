import 'package:webixes/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:webixes/data_model/slider_response.dart';
import 'package:webixes/helpers/shared_value_helper.dart';
class SlidersRepository {
  Future<SliderResponse> getSliders() async {
    //https://citydeal.co.in/city/api/v2/sliders
    Uri url =  Uri.parse("${AppConfig.BASE_URL}/sliders");
  //  Uri url =  Uri.parse("https://citydeal.co.in/city/api/v2/sliders");
    final response =
        await http.get(url,
          headers: {
            "App-Language": app_language.$,
          },);
    print(response.body.toString());
    print("sliders");
    return sliderResponseFromJson(response.body);
  }
}
