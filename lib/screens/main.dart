import 'package:webixes/app_config.dart';
import 'package:webixes/my_theme.dart';
import 'package:webixes/repositories/category_repository.dart';
import 'package:webixes/repositories/profile_repository.dart';
import 'package:webixes/screens/cart.dart';
import 'package:webixes/screens/category_list.dart';
import 'package:webixes/screens/home.dart';
import 'package:webixes/screens/profile.dart';
import 'package:webixes/screens/filter.dart';
import 'package:webixes/screens/qrcode_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:webixes/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'notification.dart';

class Main extends StatefulWidget {

  Main({Key key, go_back = true})
      : super(key: key);

  bool go_back;


  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {


  int _currentIndex = 0;
  int _cartCounter = 0;
  String _cartCounterString = "...";
  var _children = [
    Home(),

    Cart(has_bottomnav: true),
    Container(),
    NotificationPage(),
    Profile()
  ];

  void onTapped(int i) {
    setState(() {
      _currentIndex = i;
    });
  }

  void initState() {
    // TODO: implement initState
    //re appear statusbar in case it was not there in the previous page
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.initState();
    fetchCounters();
   // fetchFeaturedCategories();


  }
  fetchCounters() async {
    var profileCountersResponse =
    await ProfileRepository().getProfileCountersResponse();

    _cartCounter = profileCountersResponse.cart_item_count;
    print("_cartCounter-->$_cartCounter");


    //_cartCounterString = counterText(_cartCounter.toString(), default_length: 2);


    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return widget.go_back;
      },
      child: Directionality(
        textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          extendBody: true,
          body: _children[_currentIndex],
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          //specify the location of the FAB
          floatingActionButton: Visibility(
            visible: MediaQuery.of(context).viewInsets.bottom ==
                0.0, // if the kyeboard is open then hide, else show
            child: FloatingActionButton(
              backgroundColor: MyTheme.yellow,
              onPressed: () {},
              tooltip: "start FAB",
              child: Container(
                  margin: EdgeInsets.all(0.0),
                  child: IconButton(
                      icon: new Icon(Icons.qr_code_outlined),
                      tooltip: 'Action',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return QRViewExample();
                        }));
                      })),
              elevation: 0.0,
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                onTap: onTapped,
                currentIndex: _currentIndex,
                backgroundColor: Colors.white.withOpacity(0.8),
                fixedColor: Theme.of(context).accentColor,
                unselectedItemColor: Color.fromRGBO(153, 153, 153, 1),
                items: [
                  BottomNavigationBarItem(
                      icon: Image.asset(
                        "assets/home.png",
                        color: _currentIndex == 0
                            ? Theme.of(context).accentColor
                            : Color.fromRGBO(153, 153, 153, 1),
                        height: 20,
                      ),
                      label: AppLocalizations.of(context).main_screen_bottom_navigation_home),
                  /*new BottomNavigationBarItem(
                    label: 'CART',
                    icon: new Stack(

                        children: <Widget>[
                          Image.asset(
                            "assets/cart.png",
                            color: _currentIndex == 2
                                ? Theme.of(context).accentColor
                                : Color.fromRGBO(153, 153, 153, 1),
                            height: 20,
                          ),
                          Container(

                            width: 25,height: 25,// This is your Badge
                            child: Center(child: Text('41', style: TextStyle(fontSize:12,color: Colors.white))),
                            //padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(minHeight: 27, minWidth: 15),
                            decoration: BoxDecoration( // This controls the shadow
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    color: Colors.black.withAlpha(50))
                              ],
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.blue,  // This would be color of the Badge
                            ),
                          )
                        ]
                    ),
                  ),*/
                  BottomNavigationBarItem(
                    icon: new Stack(
                      children: <Widget>[
                        new Icon(Icons.shopping_cart_outlined,color: _currentIndex == 2
                            ? Theme.of(context).accentColor
                            : Color.fromRGBO(153, 153, 153, 1),),
                        new Positioned(
                          right: 0,
                          child: new Container(
                            padding: EdgeInsets.all(1),
                            decoration: new BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: new Text(
                              _cartCounter.toString(),
                              style: new TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                    label: 'CART',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.circle,
                      color: Colors.transparent,
                    ),
                    label: "",
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.notifications_none,
                        color: _currentIndex == 3
                            ? Theme.of(context).accentColor
                            : Color.fromRGBO(153, 153, 153, 1),
                        //height: 20,
                      ),
                      label: "NOTIFICATION"),
                  BottomNavigationBarItem(
                      icon: Image.asset(
                        "assets/profile.png",
                        color: _currentIndex == 4
                            ? Theme.of(context).accentColor
                            : Color.fromRGBO(153, 153, 153, 1),
                        height: 20,
                      ),
                      label: AppLocalizations.of(context).main_screen_bottom_navigation_profile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

