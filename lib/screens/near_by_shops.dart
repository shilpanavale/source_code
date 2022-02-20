
import 'package:location/location.dart';
import 'package:webixes/my_theme.dart';
import 'package:webixes/screens/seller_details.dart';
import 'package:flutter/material.dart';
import 'package:webixes/ui_elements/shop_square_card.dart';
import 'package:webixes/repositories/shop_repository.dart';
import 'package:webixes/helpers/shimmer_helper.dart';
import 'package:webixes/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class NearByShops extends StatefulWidget {
  NearByShops({
    Key key,
  }) : super(key: key);


  @override
  _NearByShopsState createState() => _NearByShopsState();
}

class _NearByShopsState extends State<NearByShops> {
 // Position _currentPosition;

  ScrollController _shopScrollController = ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScrollController _scrollController;




  //--------------------


  //----------------------------------------
  String _searchKey = "";
  List<dynamic> _shopList = [];
  bool _isShopInitial = true;
  int _shopPage = 1;
  int _totalShopData = 0;
  bool _showShopLoadingContainer = false;

  //----------------------------------------

  LocationData currentLocation;
  String address = "";

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _shopScrollController.dispose();
    super.dispose();
  }

  init() {
    _getLocation().then((value) {
      LocationData location = value;
      _getAddress(location?.latitude, location?.longitude)
          .then((value) {
        setState(() {
          currentLocation = location;
          print( "Location: ${currentLocation?.latitude}, ${currentLocation?.longitude}");
          address = value;
          fetchShopData();
        });
      });
    });
  }
  Future<LocationData> _getLocation() async {
    Location location = new Location();
    LocationData _locationData;

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }


    _locationData = await location.getLocation();

    return _locationData;
  }
  Future<String> _getAddress(double lat, double lang) async {
    if (lat == null || lang == null) return "";

    //GeoCode geoCode = GeoCode();
    //Address address =
    //await geoCode.reverseGeocoding(latitude: lat, longitude: lang);
    //return "${address.streetAddress}, ${address.city}, ${address.countryName}, ${address.postal}";
  return "";
  }
/*  _getCurrentLocation() {
    print("hi");
    Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high, forceAndroidLocationManager: true)
        .then((Position position) {
          print(position);
      setState(() {
        _currentPosition = position;
        print( "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}");
        fetchShopData();
      });


    }).catchError((e) {
      print(e);
    });
  }*/


  resetProductList() {
    setState(() {});
  }



  resetBrandList() {
    setState(() {});
  }

  fetchShopData() async {
    var shopResponse =
    await ShopRepository().getNearByShops(lat:currentLocation.latitude, lag:currentLocation.longitude,);
    _shopList.addAll(shopResponse.shops);
    _isShopInitial = false;
    _totalShopData = shopResponse.meta.total;
    _showShopLoadingContainer = false;
    //print("_shopPage:" + _shopPage.toString());
    //print("_totalShopData:" + _totalShopData.toString());
    setState(() {});
  }

  reset() {
    setState(() {});
  }

  resetShopList() {
    _shopList.clear();
    _isShopInitial = true;
    _totalShopData = 0;
    _shopPage = 1;
    _showShopLoadingContainer = false;
    setState(() {});
  }



  Future<void> _onShopListRefresh() async {
    reset();
    resetShopList();
    fetchShopData();
  }




  Container buildShopLoadingContainer() {
    return Container(
      height: _showShopLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalShopData == _shopList.length
            ? AppLocalizations.of(context).common_no_more_shops
            : AppLocalizations.of(context).common_loading_more_shops),
      ),
    );
  }

  //--------------------

  @override
  Widget build(BuildContext context) {
    /*print(_appBar.preferredSize.height.toString()+" Appbar height");
    print(kToolbarHeight.toString()+" kToolbarHeight height");
    print(MediaQuery.of(context).padding.top.toString() +" MediaQuery.of(context).padding.top");*/
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Stack(
            overflow: Overflow.visible, children: [
              buildShopList(),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: buildAppBar(context),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child:buildShopLoadingContainer())
        ]),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        automaticallyImplyLeading: false,
        actions: [
          new Container(),
        ],
        centerTitle: false,
        flexibleSpace: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
          child: Column(
            children: [buildTopAppbar(context)],
          ),
        )
    );
  }



  Row buildTopAppbar(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
        Widget>[
      IconButton(
        icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
        onPressed: () => Navigator.of(context).pop(),
      ),
      Container(
        width: MediaQuery.of(context).size.width * .6,
        child: Container(
          child:Text(
    '',
    style: TextStyle(fontSize: 16, color: MyTheme.black),
    ),
        ),
      ),
    ]);
  }





  Container buildShopList() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: buildShopScrollableList(),
          )
        ],
      ),
    );
  }

  buildShopScrollableList() {
    if (_isShopInitial && _shopList.length == 0) {
      return SingleChildScrollView(
          controller: _scrollController,
          child: ShimmerHelper()
              .buildSquareGridShimmer(scontroller: _scrollController));
    } else if (_shopList.length > 0) {
      return RefreshIndicator(
        color: Colors.white,
        backgroundColor: MyTheme.accent_color,
        onRefresh: _onShopListRefresh,
        child: SingleChildScrollView(
          controller: _shopScrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            children: [
              SizedBox(
                  height:
                  MediaQuery.of(context).viewPadding.top > 40 ? 180 : 135
                //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
              ),
              ListView.builder(
                // 2
                //addAutomaticKeepAlives: true,
                itemCount: _shopList.length,
                controller: _scrollController,

                padding: EdgeInsets.all(8),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  // 3
                  return _shopList[index].logo!=null? Container(
                    height: 140,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return SellerDetails();
                            }));
                      },
                      child: ShopSquareCard(
                        id: _shopList[index].id,
                        image: _shopList[index].logo.replaceAll(",", ""),
                        name: _shopList[index].name,
                      ),
                    ),
                  ):Container();
                },
              )
            ],
          ),
        ),
      );
    } else if (_totalShopData == 0) {
      return Center(child: Text(AppLocalizations.of(context).common_no_shop_is_available));
    } else {
      return Container(); // should never be happening
    }
  }
}
