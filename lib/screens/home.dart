import 'package:active_ecommerce_flutter/data_model/category_response.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/wishlist_repository.dart';
import 'package:active_ecommerce_flutter/screens/filter.dart';
import 'package:active_ecommerce_flutter/screens/flash_deal_list.dart';
import 'package:active_ecommerce_flutter/screens/product_details.dart';
import 'package:active_ecommerce_flutter/screens/todays_deal_products.dart';
import 'package:active_ecommerce_flutter/screens/top_selling_products.dart';
import 'package:active_ecommerce_flutter/screens/category_products.dart';
import 'package:active_ecommerce_flutter/screens/category_list.dart';
import 'package:active_ecommerce_flutter/ui_elements/custom_button.dart';
import 'package:active_ecommerce_flutter/ui_sections/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:active_ecommerce_flutter/repositories/sliders_repository.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title, this.show_back_button = false, go_back = true})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  bool show_back_button;
  bool go_back;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin<Home>{

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _current_slider = 0;
  ScrollController _featuredProductScrollController;
  ScrollController _mainScrollController = ScrollController();
  TabController _tabController;
  AnimationController pirated_logo_controller;
  Animation pirated_logo_animation;
  var filteredItems;
  var carouselImageList = [];
  var _featuredCategoryList = [];
  var _featuredProductList = [];
  bool _isProductInitial = true;
  bool _isCategoryInitial = true;
  bool _isCarouselInitial = true;
  bool _isInWishList=false;
  int _totalProductData = 0;
  int _productPage = 1;
  bool _showProductLoadingContainer = false;
  //Future<List<Task>> _tasks;
  int _activeTabIndex=0;
  Future api; Future ap2;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppConfig.featuredCategoryList.toList();
    _tabController= TabController(vsync: this, length: AppConfig.featuredCategoryList.length);
    _tabController.addListener(_setActiveTabIndex);

    if (AppConfig.purchase_code == "") {
      initPiratedAnimation();
    }
    fetchAll();


    _mainScrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_mainScrollController.position.pixels ==
          _mainScrollController.position.maxScrollExtent) {
        setState(() {
          _productPage++;
          print(_tabController.index);
        });
        _showProductLoadingContainer = true;
        fetchFeaturedProducts(AppConfig.featuredCategoryList[_activeTabIndex].links.products);
      }
    });
  }

  void _setActiveTabIndex() {
    _activeTabIndex = _tabController.index;
    _featuredProductList.clear();
    fetchFeaturedProducts(AppConfig.featuredCategoryList[_activeTabIndex].links.products);
  }
  fetchAll() {
    // fetchCarouselImages();
    print("HOME PAGE list-->${AppConfig.featuredCategoryList.length}");
    fetchFeaturedCategories();
    fetchFeaturedProducts(AppConfig.featuredCategoryList[_activeTabIndex].links.products);
  }

  fetchCarouselImages() async {
    var carouselResponse = await SlidersRepository().getSliders();
    carouselResponse.sliders.forEach((slider) {
       carouselImageList.add(slider.photo);
    });

    _isCarouselInitial = false;
   // setState(() {});
  }

    fetchFeaturedCategories() async {
      var productResponse = await ProductRepository().getFeaturedProducts(
      page: _productPage,
    );
   // var categoryResponse = await CategoryRepository().getFeturedCategories();

     _featuredCategoryList.addAll(productResponse.products);
     _isCategoryInitial = false;
     setState(() {});
  }

  fetchFeaturedProducts(String apiUrl) async {
   var productResponse = await ProductRepository().getCategoryWiseProducts(apiUrl:apiUrl);
    /*var productResponse = await ProductRepository().getFeaturedProducts(
      page: _productPage,
    );*/

    _featuredProductList.addAll(productResponse.products);
    print("TOP Product --> ${_featuredProductList.length}");

    _isProductInitial = false;
    _totalProductData = productResponse.meta.total;
    _showProductLoadingContainer = false;
    setState(() {});
  }

  reset() {
    carouselImageList.clear();
    _featuredCategoryList.clear();
    _isCarouselInitial = true;
    _isCategoryInitial = true;

    setState(() {});

    resetProductList();
  }

  Future<void> _onRefresh() async {
    reset();
   // fetchAll();
  }

  resetProductList() {
    _featuredProductList.clear();
    _isProductInitial = true;
    _totalProductData = 0;
    _productPage = 1;
    _showProductLoadingContainer = false;
    setState(() {});
  }

  initPiratedAnimation() {
   /* pirated_logo_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));*/
    pirated_logo_animation = Tween(begin: 40.0, end: 60.0).animate(
        CurvedAnimation(
            curve: Curves.bounceOut, parent: pirated_logo_controller));

    pirated_logo_controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        pirated_logo_controller.repeat();
      }
    });

    pirated_logo_controller.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
    pirated_logo_controller?.dispose();
    _mainScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    //print(MediaQuery.of(context).viewPadding.top);

    return WillPopScope(
      onWillPop: () async {
        return widget.go_back;
      },
      child: Directionality(
    textDirection: app_language_rtl.$
    ? TextDirection.rtl
      : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey.shade200,
        appBar: buildAppBar(statusBarHeight, context),
        drawer: MainDrawer(),
        body: DefaultTabController(
          length: AppConfig.featuredCategoryList.length,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Container(
                    child: Stack(
                      children: [
                        TabBarView(
                          controller: _tabController,
                          children: AppConfig.featuredCategoryList.map((choice) {
                            print('Current Index: ${_tabController.index}');
                            return CustomScrollView(
                              shrinkWrap: true,
                              controller: _mainScrollController,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              slivers: <Widget>[
                                SliverList(
                                  delegate: SliverChildListDelegate(
                                      [
                                        AppConfig.purchase_code ==
                                            ""
                                            ? Padding(
                                          padding: const EdgeInsets
                                              .fromLTRB(
                                            8.0,
                                            16.0,
                                            8.0,
                                            0.0,
                                          ),
                                          child: Container(
                                            height: 140,
                                            color: Colors.black,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                    left: 20,
                                                    top: 0,
                                                    child: AnimatedBuilder(
                                                        animation:
                                                        pirated_logo_animation,
                                                        builder:
                                                            (
                                                            context,
                                                            child) {
                                                          return Image
                                                              .asset(
                                                            "assets/pirated_square.png",
                                                            height:
                                                            pirated_logo_animation
                                                                .value,
                                                            color:
                                                            Colors
                                                                .white,
                                                          );
                                                        })),
                                                Center(
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                        top: 24.0,
                                                        left: 24,
                                                        right: 24),
                                                    child: Text(
                                                      "This is a pirated app. Do not use this. It may have security issues.",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .white,
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                            : Container(),
                                        Padding(
                                          padding: const EdgeInsets
                                              .fromLTRB(
                                            8.0,
                                            16.0,
                                            8.0,
                                            0.0,
                                          ),
                                          child: buildHomeCarouselSlider(
                                              context,
                                              AppConfig.featuredCategoryList[_tabController.index].banner),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets
                                              .fromLTRB(
                                            8.0,
                                            16.0,
                                            8.0,
                                            0.0,
                                          ),
                                          child: buildHomeMenuRow(context),
                                        ),
                                      ]),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets
                                        .fromLTRB(
                                      0.0,
                                      16.0,
                                      0.0,
                                      0.0,
                                    ),
                                    child: Container(
                                      color: MyTheme
                                          .soft_accent_color1,
                                      height: 202,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets
                                                .all(8.0),
                                            child: Text(
                                              'Featured Product',
                                              // AppLocalizations.of(context).home_screen_featured_categories,
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: buildHomeFeaturedProduct(context))

                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                      padding: const EdgeInsets
                                          .fromLTRB(
                                        0.0,
                                        16.0,
                                        0.0,
                                        0.0,
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets
                                                .all(5),
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .transparent,
                                              borderRadius: BorderRadius
                                                  .circular(8),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                  'citydeal/img/bg-img/12.jpg',
                                                ),
                                              ),
                                            ),
                                            height: 151.0,
                                          ),
                                          Container(
                                            height: 151.0,
                                            margin: EdgeInsets
                                                .all(5),
                                            decoration: BoxDecoration(
                                                color: Colors
                                                    .white,
                                                borderRadius: BorderRadius
                                                    .circular(8),
                                                gradient: LinearGradient(
                                                    begin: FractionalOffset
                                                        .centerLeft,
                                                    end: FractionalOffset
                                                        .centerRight,
                                                    colors: [
                                                      Colors
                                                          .indigo,
                                                      Colors
                                                          .purple,
                                                      Colors
                                                          .yellow
                                                          .withOpacity(
                                                          0.6),
                                                      Colors
                                                          .yellow

                                                    ],
                                                    stops: [
                                                      0.2, 0.3,
                                                      1.0, 0.8
                                                    ])),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        "On Sale 50% Off!",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors
                                                                .white),)
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        "Suha is a multipurpose, creative &\n \t\t modern mobile template.",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors
                                                                .white),)
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      CustomButton(
                                                        onPressed: () {},
                                                        title: '\tSHOP TODAY\t',
                                                        bgColor: MyTheme
                                                            .yellow,)
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )

                                        ],
                                      )
                                  ),
                                ),
                                SliverList(
                                  delegate: SliverChildListDelegate(
                                      [
                                        SingleChildScrollView(
                                          child: Container(
                                            color: MyTheme
                                                .soft_accent_color1,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .fromLTRB(
                                                    4.0,
                                                    16.0,
                                                    8.0,
                                                    0.0,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .all(
                                                                8.0),
                                                            child: Text(
                                                              'Top Products',
                                                              // AppLocalizations.of(context).home_screen_featured_categories,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .all(
                                                                8.0),
                                                            child: Text(
                                                              'VIEW ALL',
                                                              // AppLocalizations.of(context).home_screen_featured_categories,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: MyTheme
                                                                      .dark_grey
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      buildHomeTopProducts(context)
                                                    ],
                                                  ),

                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                      ]),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                      padding: const EdgeInsets
                                          .fromLTRB(
                                        0.0,
                                        16.0,
                                        0.0,
                                        0.0,
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets
                                                .all(5),
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .transparent,
                                              borderRadius: BorderRadius
                                                  .circular(8),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                  'citydeal/img/bg-img/12.jpg',
                                                ),
                                              ),
                                            ),
                                            height: 151.0,
                                          ),
                                          Container(
                                            height: 151.0,
                                            margin: EdgeInsets
                                                .all(5),
                                            decoration: BoxDecoration(
                                                color: Colors
                                                    .white,
                                                borderRadius: BorderRadius
                                                    .circular(8),
                                                gradient: LinearGradient(
                                                    begin: FractionalOffset
                                                        .centerLeft,
                                                    end: FractionalOffset
                                                        .centerRight,
                                                    colors: [
                                                      Colors
                                                          .indigo,
                                                      Colors
                                                          .purple,
                                                      Colors
                                                          .yellow
                                                          .withOpacity(
                                                          0.6),
                                                      Colors
                                                          .yellow

                                                    ],
                                                    stops: [
                                                      0.2, 0.3,
                                                      1.0, 0.8
                                                    ])),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        "On Sale 50% Off!",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors
                                                                .white),)
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        "Suha is a multipurpose, creative &\n \t\t modern mobile template.",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors
                                                                .white),)
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      CustomButton(
                                                        onPressed: () {},
                                                        title: '\tSHOP TODAY\t',
                                                        bgColor: MyTheme
                                                            .yellow,)
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )

                                        ],
                                      )
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets
                                        .fromLTRB(
                                      0.0,
                                      16.0,
                                      0.0,
                                      0.0,
                                    ),
                                    child: Container(
                                      color: MyTheme
                                          .soft_accent_color1,
                                      height: 190,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets
                                                .all(8.0),
                                            child: Text(
                                              'Flash Sale',
                                              // AppLocalizations.of(context).home_screen_featured_categories,
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: buildHomeFeaturedProduct(
                                                  context))

                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                      padding: const EdgeInsets
                                          .fromLTRB(
                                        0.0,
                                        16.0,
                                        0.0,
                                        0.0,
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets
                                                .all(5),
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .transparent,
                                              borderRadius: BorderRadius
                                                  .circular(8),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                  'citydeal/img/bg-img/12.jpg',
                                                ),
                                              ),
                                            ),
                                            height: 151.0,
                                          ),
                                          Container(
                                            height: 151.0,
                                            margin: EdgeInsets
                                                .all(5),
                                            decoration: BoxDecoration(
                                                color: Colors
                                                    .white,
                                                borderRadius: BorderRadius
                                                    .circular(8),
                                                gradient: LinearGradient(
                                                    begin: FractionalOffset
                                                        .centerLeft,
                                                    end: FractionalOffset
                                                        .centerRight,
                                                    colors: [
                                                      Colors
                                                          .indigo,
                                                      Colors
                                                          .purple,
                                                      Colors
                                                          .yellow
                                                          .withOpacity(
                                                          0.6),
                                                      Colors
                                                          .yellow

                                                    ],
                                                    stops: [
                                                      0.2, 0.3,
                                                      1.0, 0.8
                                                    ])),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        "On Sale 50% Off!",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors
                                                                .white),)
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        "Suha is a multipurpose, creative &\n \t\t modern mobile template.",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors
                                                                .white),)
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      CustomButton(
                                                        onPressed: () {},
                                                        title: '\tSHOP TODAY\t',
                                                        bgColor: MyTheme
                                                            .yellow,)
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )

                                        ],
                                      )
                                  ),
                                ),
                                SliverList(
                                  delegate: SliverChildListDelegate(
                                      [
                                        SingleChildScrollView(
                                          child: Container(
                                            color: MyTheme
                                                .soft_accent_color1,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .fromLTRB(
                                                    4.0,
                                                    16.0,
                                                    8.0,
                                                    0.0,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .all(
                                                                8.0),
                                                            child: Text(
                                                              'Seasson Special',
                                                              // AppLocalizations.of(context).home_screen_featured_categories,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .all(
                                                                8.0),
                                                            child: Text(
                                                              'VIEW ALL',
                                                              // AppLocalizations.of(context).home_screen_featured_categories,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: MyTheme
                                                                      .dark_grey
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      buildSeasonSpecial(context)

                                                    ],
                                                  ),

                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                      ]),
                                ),
                              ],
                            );
                          }).toList(),

                        ),
                        Align(
                            alignment: Alignment.center,
                            child: buildProductLoadingContainer())
                      ],
                    )
                ),
              )
            ],
          ),
        ),
      ),
    )

    );
  }

  buildHomeTopProducts(context) {
    if ( _featuredProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _featuredProductScrollController));
    } else if (_featuredProductList.length > 0) {

       return   GridView.builder(
       // 2
       addAutomaticKeepAlives: true,
       itemCount: _featuredProductList.length,
       controller: _featuredProductScrollController,
       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: 2,
           crossAxisSpacing: 10,
           mainAxisSpacing: 10,
           childAspectRatio: 0.618),
       padding: EdgeInsets.all(8),
       physics: NeverScrollableScrollPhysics(),
       shrinkWrap: true,
       itemBuilder: (context, index) {
         return ProductCard(
             id: _featuredProductList[index].id,
             image: _featuredProductList[index].thumbnail_image.replaceAll(",", ""),
             name: _featuredProductList[index].name,
             main_price: _featuredProductList[index].main_price,
             stroked_price: _featuredProductList[index].stroked_price,
             has_discount: _featuredProductList[index].has_discount,
             wishListButton:false ,
         );
       },
     );

    } else if (_totalProductData == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context).common_no_product_is_available));
    } else {
      return Container(); // should never be happening
    }

  }

  buildHomeFeaturedProduct(context) {
    if (_isCategoryInitial && _featuredCategoryList.length == 0) {
      return  Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
        ],
      );
    } else if (_featuredCategoryList.length > 0) {
      //snapshot.hasData
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _featuredCategoryList.length,
          itemExtent: 120,
          shrinkWrap: true,
          itemBuilder: (context, index) {

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProductDetails(id: _featuredCategoryList[index].id,);
                  }));
                },
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    side: new BorderSide(color: MyTheme.light_grey, width: 1.0),
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  elevation: 0.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                            //width: 100,
                          //color: Colors.yellow,
                            height: 63,
                            child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(0),
                                    bottom: Radius.zero),
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder.png',
                                  image: AppConfig.BASE_PATH +
                                      _featuredCategoryList[index].thumbnail_image,
                                  fit: BoxFit.cover,
                                )
                                )),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Text(
                          _featuredCategoryList[index].main_price,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RatingBar(
                              itemSize: 15.0,
                              ignoreGestures: true,
                              initialRating: 5,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              ratingWidget: RatingWidget(
                                half:Icon(FontAwesome.star, color: Colors.grey) ,
                                full: Icon(FontAwesome.star, color: Colors.grey),
                                empty:
                                Icon(FontAwesome.star, color: Color.fromRGBO(224, 224, 225, 1)),
                              ),
                              itemPadding: EdgeInsets.only(right: 1.0),
                              onRatingUpdate: (rating) {
                                //print(rating);
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Container(
                          height: 30,
                          child: Text(
                            _featuredCategoryList[index].name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 11, color: MyTheme.font_grey),
                          ),
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            );
          });
    } else if (!_isCategoryInitial && _featuredCategoryList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_category_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  buildHomeMenuRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CategoryList(
                  is_top_category: true,
                );
              }));
            },
            child: Container(
              height: 70, width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: MyTheme.yellow, width: 1),
              ),
              //width: MediaQuery.of(context).size.width / 5 - 4,
              child: Column(
                children: [
                  Container(
                      height: 47,
                      width: 47,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: MyTheme.white, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.suit_heart,
                          color: MyTheme.accent_color,
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 5),
                    child: Text(
                      'All Category',
                      // AppLocalizations.of(context).home_screen_top_categories,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(132, 132, 132, 1),
                          fontWeight: FontWeight.w300),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 5,),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Filter(
                  selected_filter: "sellers",
                );
              }));
            },
            child: Container(
              height: 70, width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: MyTheme.yellow, width: 1),
              ),
              // height: 100,
              //width: MediaQuery.of(context).size.width / 5 - 4,
              child: Column(
                children: [
                  Container(
                      height: 47,
                      width: 47,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: MyTheme.white, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.rectangle_on_rectangle_angled,
                          color: MyTheme.yellow,
                        ),
                        //child: Image.asset("assets/brands.png"),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Text('Search by Shop',
                          //AppLocalizations.of(context).home_screen_brands,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(132, 132, 132, 1),
                              fontWeight: FontWeight.w300))),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 5,),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TopSellingProducts();
              }));
            },
            child: Container(
              height: 70, width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: MyTheme.yellow, width: 1),
              ),
              // height: 100,
              //width: MediaQuery.of(context).size.width / 5 - 4,
              child: Column(
                children: [
                  Container(
                      height: 47,
                      width: 47,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: MyTheme.white, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          CupertinoIcons.xmark_seal,
                          color: MyTheme.yellow,
                        ),
                        //child: Image.asset("assets/top_sellers.png"),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Text(
                          AppLocalizations.of(context).home_screen_top_sellers,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(132, 132, 132, 1),
                              fontWeight: FontWeight.w300))),
                ],
              ),
            ),
          ),
        ),
        /* GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TodaysDealProducts();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/todays_deal.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(AppLocalizations.of(context).home_screen_todays_deal,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FlashDealList();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/flash_deal.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(AppLocalizations.of(context).home_screen_flash_deal,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        )*/
      ],
    );
  }

  buildHomeCarouselSlider(context,List<dynamic> carouselImageList) {
    if (_isCarouselInitial && carouselImageList.length == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Shimmer.fromColors(
          baseColor: MyTheme.shimmer_base,
          highlightColor: MyTheme.shimmer_highlighted,
          child: Container(
            height: 120,
            width: double.infinity,
            color: Colors.white,
          ),
        ),
      );
    } else if (carouselImageList.length > 0) {
      return CarouselSlider(
        options: CarouselOptions(
          height: 170,
            aspectRatio: 2.07,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            //autoPlayInterval: Duration(seconds: 5),
            //autoPlayAnimationDuration: Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInCubic,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            /*onPageChanged: (index, reason) {
              setState(() {
                _current_slider = index;
              });
            }*/
            ),
        items: carouselImageList.map((i) {
          return carouselImageList!=null?
            Builder(
            builder: (BuildContext context) {
              return Stack(
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_rectangle.png',
                            image: AppConfig.BASE_PATH + i,
                            fit: BoxFit.fill,
                          )
                          )),
                  /*Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(carouselImageList.length,(index) {

                          //int index = carouselImageList.indexOf(carouselImageList[index].banner);

                          return Container(
                            width: 5.0,
                            height: 7.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _current_slider == index
                                  ? MyTheme.white
                                  : Color.fromRGBO(112, 112, 112, .3),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),*/
                ],
              );
            },
          )
          : Builder(
            builder: (BuildContext context) {
              return Stack(
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: Image.asset("assets/placeholder.png")
                      )),
                 /* Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(_tabController.index,(index) {

                          //int index = carouselImageList.indexOf(carouselImageList[index].banner);

                          return Container(
                            width: 5.0,
                            height: 7.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _current_slider == index
                                  ? MyTheme.white
                                  : Color.fromRGBO(112, 112, 112, .3),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),*/
                ],
              );
            },
          );
        }).toList(),
      );
    } else if (!_isCarouselInitial && carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  PreferredSizeWidget buildAppBar(double statusBarHeight, BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(100.0), // here the desired height
        child: AppBar(
          backgroundColor: MyTheme.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: false,
          leading: GestureDetector(
        onTap: () {
          _scaffoldKey.currentState.openDrawer();
        },
        child: widget.show_back_button
            ? Builder(
                builder: (context) => IconButton(
                    icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
                    onPressed: () {
                      if (!widget.go_back) {
                        return;
                      }
                      return Navigator.of(context).pop();
                    }),
              )
            : Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 0.0),
                  child: Container(
                    child: Image.asset(
                      'assets/hamburger.png',
                      height: 16,
                      //color: MyTheme.dark_grey,
                      color: MyTheme.dark_grey,
                    ),
                  ),
                ),
              ),
      ),
          title: Container(
            width: double.infinity,
            height: kToolbarHeight +
                statusBarHeight -
                (MediaQuery.of(context).viewPadding.top > 40 ? 16.0 : 16.0),
            //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
            child: Container(

              child: Padding(
                  padding: app_language_rtl.$
                      ? const EdgeInsets.only(top: 14.0, bottom: 14, left: 0)
                      : const EdgeInsets.only(top: 14.0, bottom: 14, right: 0),
                  // when notification bell will be shown , the right padding will cease to exist.
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return Filter();
                            }));
                      },
                      child: buildHomeSearchBox(context))),
            ),
          ),
          bottom:  TabBar(
              controller: _tabController,
            isScrollable: true,
            indicatorColor: MyTheme.black,
            tabs: AppConfig.featuredCategoryList.map((choice){
             return new Tab(text: choice.name);
          /*List<Widget>.generate(_featuredCategoryList.length, (int index){
          print(_featuredCategoryList[index].links.products);
          return new Tab(text: _featuredCategoryList[index].name);

          }),*/
          }).toList()

          ),
        )
    );
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      /*leading: GestureDetector(
        onTap: () {
          _scaffoldKey.currentState.openDrawer();
        },
        child: widget.show_back_button
            ? Builder(
                builder: (context) => IconButton(
                    icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
                    onPressed: () {
                      if (!widget.go_back) {
                        return;
                      }
                      return Navigator.of(context).pop();
                    }),
              )
            : Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 0.0),
                  child: Container(
                    child: Image.asset(
                      'assets/hamburger.png',
                      height: 16,
                      //color: MyTheme.dark_grey,
                      color: MyTheme.dark_grey,
                    ),
                  ),
                ),
              ),
      ),*/
      title: Container(
        height: kToolbarHeight +
            statusBarHeight -
            (MediaQuery.of(context).viewPadding.top > 40 ? 16.0 : 16.0),
        //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
        child: Container(
          child: Padding(
              padding: app_language_rtl.$
                  ? const EdgeInsets.only(top: 14.0, bottom: 14, left: 0)
                  : const EdgeInsets.only(top: 14.0, bottom: 14, right: 0),
              // when notification bell will be shown , the right padding will cease to exist.
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Filter();
                    }));
                  },
                  child: buildHomeSearchBox(context))),
        ),
      ),
      elevation: 3.0,
      titleSpacing: 0.0,
      actions: <Widget>[
        InkWell(
          onTap: () {
            //ToastComponent.showDialog(AppLocalizations.of(context).common_coming_soon, context, gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
          },
          child: Visibility(
            visible: true,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
              child: Container(
                width: 40,
                child: Image.asset(
                  'citydeal/img/gps.png',
                  height: 20,
                  color: MyTheme.black,
                ),
              ),
            ),
          ),
        ),
      ],


    );
  }

  buildHomeSearchBox(BuildContext context) {
    return TextField(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Filter();
        }));
      },
      autofocus: false,
      readOnly: true,
      decoration: InputDecoration(
          hintText: AppLocalizations.of(context).home_screen_search,
          hintStyle: TextStyle(fontSize: 12.0, color: MyTheme.dark_grey),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.medium_grey_50, width: 1.0),
            borderRadius: const BorderRadius.all(
              const Radius.circular(25.0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.dark_grey, width: 1.0),
            borderRadius: const BorderRadius.all(
              const Radius.circular(25.0),
            ),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.search,
              color: MyTheme.dark_grey,
              size: 20,
            ),
          ),
          contentPadding: EdgeInsets.all(0.0)),
    );
  }
  buildSeasonSpecial(context) {
    if (_isProductInitial && _featuredProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _featuredProductScrollController));
    } else if (_featuredProductList.length > 0) {
      //snapshot.hasData

      return  Container(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
            itemCount: _featuredCategoryList.length,
            itemExtent: 120,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return CategoryProducts(
                        category_id: _featuredCategoryList[index].id,
                        category_name: _featuredCategoryList[index].name,
                      );
                    }));
                  },
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      side: new BorderSide(color: MyTheme.light_grey, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    elevation: 0.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                         // width: 100,
                         child: Row(
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0,left: 10.0),
                                    child: Container(
                                      width: 120,
                                      //color: Colors.yellow,
                                        height: 63,
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(0),
                                                bottom: Radius.zero),
                                            child: FadeInImage.assetNetwork(
                                              placeholder: 'assets/placeholder.png',
                                              image: AppConfig.BASE_PATH +
                                                  _featuredCategoryList[index].thumbnail_image,
                                              fit: BoxFit.cover,
                                            )

                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 120,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                        Icon(CupertinoIcons.suit_heart,color: Colors.pink,),
                                          SizedBox(width: 25,),
                                          Icon(CupertinoIcons.refresh_thin,color: Colors.pink,)
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          //width: 160,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: Container(
                                     width: 140,
                                      child: Text(
                                        _featuredCategoryList[index].name,
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                            fontSize: 13, color: MyTheme.font_grey),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: MyTheme.yellow,
                                        child: Center(
                                          child: Icon(
                                            Icons.add,color: Colors.white,size: 16,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(8, 0, 8, 1),
                                        child: Container(
                                         // height: 22,
                                          child: Text(
                                            _featuredCategoryList[index].main_price,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontSize: 14, color: MyTheme.yellow),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: MyTheme.yellow,
                                        child: Center(
                                          child: Icon(
                                            Icons.add,color: Colors.white,size: 16,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(8, 0, 8, 4),
                                        child: Container(
                                         // height: 22,
                                          child: Text(
                                            '488(22)',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontSize: 14, color: MyTheme.dark_grey),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2,),
                                  Container(
                                    color: MyTheme.yellow,
                                    width: 80,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Icon(Icons.add_shopping_cart_sharp,color: Colors.white,size: 17,),
                                          Text("BUY NOW",style: TextStyle(fontSize:12,color: Colors.white),)
                                        ],
                                      ),
                                    ),
                                  )

                                ],
                              )

                            ],
                          ),
                        )


                      ],
                    ),
                  ),
                ),
              );
            }),
      );
    } else if (_totalProductData == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context).common_no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  Container buildProductLoadingContainer() {
    return Container(
      height: _showProductLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalProductData == _featuredProductList.length
            ? AppLocalizations.of(context).common_no_more_products
            : AppLocalizations.of(context).common_loading_more_products),
      ),
    );
  }
}

