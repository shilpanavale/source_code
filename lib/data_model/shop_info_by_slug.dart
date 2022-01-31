import 'dart:convert';

/// data : [{"id":531,"name":"Hum Tum Shoppe","logo":"uploads/all/wWjNlVxPcAJhVxXnD28lkIPiWVkQDya0fle4cjsH.jpg"}]
/// success : true
/// status : 200

// To parse this JSON data, do
//
//     final shopDetailsResponse = shopDetailsResponseFromJson(jsonString);
// https://app.quicktype.io/
import 'dart:convert';

ShopInfoBySlug shopDetailsInfoBySlugResponseFromJson(String str) => ShopInfoBySlug.fromJson(json.decode(str));

String shopDetailsInfoBySlugToJson(ShopInfoBySlug data) => json.encode(data.toJson());

class ShopInfoBySlug {
  ShopInfoBySlug({
    this.data,
    this.success,
    this.status,
  });

  List<Data> data;
  bool success;
  int status;

  factory ShopInfoBySlug.fromJson(Map<String, dynamic> json) => ShopInfoBySlug(
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "success": success,
    "status": status,
  };
}

class Data {
  Data({
    this.id,
    this.name,
    this.logo,
  });

  int id;
  String name;
  String logo;


  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    logo: json["logo"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "logo": logo,
  };
}