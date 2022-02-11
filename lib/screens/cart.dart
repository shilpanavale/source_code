import 'package:webixes/repositories/coupon_repository.dart';
import 'package:webixes/screens/shipping_info.dart';
import 'package:flutter/material.dart';
import 'package:webixes/my_theme.dart';
import 'package:webixes/ui_elements/custom_button.dart';
import 'package:webixes/ui_sections/drawer.dart';
import 'package:flutter/widgets.dart';
import 'package:webixes/repositories/cart_repository.dart';
import 'package:webixes/helpers/shared_value_helper.dart';
import 'package:webixes/helpers/shimmer_helper.dart';
import 'package:webixes/app_config.dart';
import 'package:webixes/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class Cart extends StatefulWidget {
  Cart({Key key, this.has_bottomnav}) : super(key: key);
  final bool has_bottomnav;

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _mainScrollController = ScrollController();
  TextEditingController _couponController = TextEditingController();
  var _shopList = [];
  bool _isInitial = true;
  var _cartTotal = 0.00;
  var _cartTotalString = ". . .";
  var _used_coupon_code = "";
  var _coupon_applied = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /*print("user data");
    print(is_logged_in.$);
    print(access_token.value);
    print(user_id.$);
    print(user_name.$);*/

    if (is_logged_in.$ == true) {
      fetchData();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  fetchData() async {

  var cartResponseList =
        await CartRepository().getCartResponseList(user_id.$);

    if (cartResponseList != null && cartResponseList.length > 0) {
      _shopList = cartResponseList;
      fetchSummary();
    }
    _isInitial = false;
    getSetCartTotal();
    setState(() {});
  }
  fetchSummary() async {
    var cartSummaryResponse = await CartRepository().getCartSummaryResponse();

    if (cartSummaryResponse != null) {
      _used_coupon_code = cartSummaryResponse.coupon_code;
      print(_used_coupon_code);
      _couponController.text = _used_coupon_code;
      _coupon_applied = cartSummaryResponse.coupon_applied;
      setState(() {});
    }
  }
  getSetCartTotal() {
    _cartTotal = 0.00;
    if (_shopList.length > 0) {
      _shopList.forEach((shop) {
        if (shop.cart_items.length > 0) {
          shop.cart_items.forEach((cart_item) {
            _cartTotal += (cart_item.price + cart_item.tax) * cart_item.quantity;
            _cartTotalString = "${cart_item.currency_symbol}${_cartTotal}";
          });
        }
      });
    }

    setState(() {});
  }

  partialTotalString(index) {
    var partialTotal = 0.00;
    var partialTotalString = "";
    if (_shopList[index].cart_items.length > 0) {
      _shopList[index].cart_items.forEach((cart_item) {
        partialTotal += (cart_item.price + cart_item.tax) * cart_item.quantity;
        partialTotalString = "${cart_item.currency_symbol}${partialTotal}";
      });
    }

    return partialTotalString;
  }

  onQuantityIncrease(seller_index, item_index) {
    if (_shopList[seller_index].cart_items[item_index].quantity <
        _shopList[seller_index].cart_items[item_index].upper_limit) {
      _shopList[seller_index].cart_items[item_index].quantity++;
      getSetCartTotal();
      setState(() {});
    } else {
      ToastComponent.showDialog(
          "${AppLocalizations.of(context).cart_screen_cannot_order_more_than} ${_shopList[seller_index].cart_items[item_index].upper_limit} ${AppLocalizations.of(context).cart_screen_items_of_this}",
          context,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    }
  }

  onQuantityDecrease(seller_index, item_index) {
    if (_shopList[seller_index].cart_items[item_index].quantity >
        _shopList[seller_index].cart_items[item_index].lower_limit) {
      _shopList[seller_index].cart_items[item_index].quantity--;
      getSetCartTotal();
      setState(() {});
    } else {
      ToastComponent.showDialog(
          "${AppLocalizations.of(context).cart_screen_cannot_order_more_than} ${_shopList[seller_index].cart_items[item_index].lower_limit} ${AppLocalizations.of(context).cart_screen_items_of_this}",
          context,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG);
    }
  }

  onPressDelete(cart_id) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.only(
                  top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
              content: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context).cart_screen_sure_remove_item,
                  maxLines: 3,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
                ),
              ),
              actions: [
                FlatButton(
                  child: Text(
                    AppLocalizations.of(context).cart_screen_cancel,
                    style: TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                FlatButton(
                  color: MyTheme.soft_accent_color,
                  child: Text(
                    AppLocalizations.of(context).cart_screen_confirm,
                    style: TextStyle(color: MyTheme.dark_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    confirmDelete(cart_id);
                  },
                ),
              ],
            ));
  }

  confirmDelete(cart_id) async {
    var cartDeleteResponse =
        await CartRepository().getCartDeleteResponse(cart_id);

    if (cartDeleteResponse.result == true) {
      ToastComponent.showDialog(cartDeleteResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);

      reset();
      fetchData();
    } else {
      ToastComponent.showDialog(cartDeleteResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    }
  }

  onPressUpdate() {
    process(mode: "update");
  }

  onPressProceedToShipping() {
    process(mode: "proceed_to_shipping");
  }

  process({mode}) async {
    var cart_ids = [];
    var cart_quantities = [];
    if (_shopList.length > 0) {
      _shopList.forEach((shop) {
        if (shop.cart_items.length > 0) {
          shop.cart_items.forEach((cart_item) {
            cart_ids.add(cart_item.id);
            cart_quantities.add(cart_item.quantity);
          });
        }
      });
    }

    if (cart_ids.length == 0) {
      ToastComponent.showDialog(AppLocalizations.of(context).cart_screen_cart_empty, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    var cart_ids_string = cart_ids.join(',').toString();
    var cart_quantities_string = cart_quantities.join(',').toString();

    print(cart_ids_string);
    print(cart_quantities_string);

    var cartProcessResponse = await CartRepository()
        .getCartProcessResponse(cart_ids_string, cart_quantities_string);

    if (cartProcessResponse.result == false) {
      ToastComponent.showDialog(cartProcessResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      ToastComponent.showDialog(cartProcessResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);

      if (mode == "update") {
        reset();
        fetchData();
      } else if (mode == "proceed_to_shipping") {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ShippingInfo();
        })).then((value) {
          onPopped(value);
        });
      }
    }
  }

  reset() {
    _shopList = [];
    _isInitial = true;
    _cartTotal = 0.00;
    _cartTotalString = ". . .";

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }

  onPopped(value) async {
    reset();
    fetchData();
  }
  onCouponApply() async {
    var coupon_code = _couponController.text.toString();
    if (coupon_code == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).checkout_screen_coupon_code_warning, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    var couponApplyResponse =
    await CouponRepository().getCouponApplyResponse(coupon_code);
    if (couponApplyResponse.result == false) {
      ToastComponent.showDialog(couponApplyResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }
    fetchSummary();
  }

  onCouponRemove() async {
    var couponRemoveResponse =
    await CouponRepository().getCouponRemoveResponse();

    if (couponRemoveResponse.result == false) {
      ToastComponent.showDialog(couponRemoveResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }
    fetchSummary();
  }
  @override
  Widget build(BuildContext context) {
    //print(widget.has_bottomnav);
    return Scaffold(
        key: _scaffoldKey,
        drawer: MainDrawer(),
        backgroundColor: MyTheme.soft_accent_color,
        appBar: buildAppBar(context),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 10.0,right: 10.0,top: 16.0),
                    child:Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: MyTheme.light_grey, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: buildCartSellerList(),)
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: buildBottomContainer(),
                )
              ],
            ),
          ),
        ));
  }

  Container buildBottomContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        /*border: Border(
                  top: BorderSide(color: MyTheme.light_grey,width: 1.0),
                )*/
      ),

      height: widget.has_bottomnav ? 250 : 120,
      //color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0,right: 16.0),
            child: Container(
              height: 108,
              color: Colors.white,
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: MyTheme.light_grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Have a coupon?",style: TextStyle(color: Colors.black,fontSize: 15),)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Enter your coupon code here & get awesome discounts!",style: TextStyle(color: Colors.grey,fontSize: 13),)
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 200,
                          height: 60,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                //  height: 50,
                                child:  Center(
                                  child: TextField(
                                    controller: _couponController,
                                    readOnly: _coupon_applied,
                                    autocorrect: true,
                                    decoration: InputDecoration(
                                      hintText: 'Coupon code',

                                      hintStyle: TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.white70,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                    ),),
                                ),
                              ),
                            ),
                          ),),
                        !_coupon_applied?Container(
                            width: 100,
                            height: 45,
                            child: Center(child: CustomButton(onPressed: (){
                              onCouponApply();
                            },title: "Apply",bgColor: MyTheme.yellow,))
                        ):Container(
                            width: 100,
                            height: 45,
                            child: Center(child: CustomButton(onPressed: (){
                              onCouponRemove();
                            },title: "Remove",bgColor: MyTheme.yellow,))
                        )

                      ],
                    )


                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0,right: 16.0),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("$_cartTotalString",
                          style: TextStyle(
                              color: MyTheme.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                      child: CustomButton(
                        onPressed: (){
                          onPressProceedToShipping();
                        },
                        title: " Checkout Now ",
                        bgColor: MyTheme.yellow,),
                    ),

                  ],
                ),
              ),
            ),
          ),
          /*Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: MyTheme.soft_accent_color),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      AppLocalizations.of(context).cart_screen_total_amount,
                      style:
                      TextStyle(color: MyTheme.font_grey, fontSize: 14),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("$_cartTotalString",
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                  height: 38,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                      Border.all(color: MyTheme.textfield_grey, width: 1),
                      borderRadius: app_language_rtl.$ ?
                      const BorderRadius.only(
                        topLeft: const Radius.circular(0.0),
                        bottomLeft: const Radius.circular(0.0),
                        topRight: const Radius.circular(8.0),
                        bottomRight: const Radius.circular(8.0),
                      ): const BorderRadius.only(
                        topLeft: const Radius.circular(8.0),
                        bottomLeft: const Radius.circular(8.0),
                        topRight: const Radius.circular(0.0),
                        bottomRight: const Radius.circular(0.0),
                      )),
                  child: FlatButton(
                    minWidth: MediaQuery.of(context).size.width,
                    //height: 50,
                    color: MyTheme.light_grey,
                    shape: app_language_rtl.$?
                    RoundedRectangleBorder(
                        borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(0.0),
                          bottomLeft: const Radius.circular(0.0),
                          topRight: const Radius.circular(8.0),
                          bottomRight: const Radius.circular(8.0),
                        ))
                        : RoundedRectangleBorder(
                        borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(8.0),
                          bottomLeft: const Radius.circular(8.0),
                          topRight: const Radius.circular(0.0),
                          bottomRight: const Radius.circular(0.0),
                        )),
                    child: Text(
                      AppLocalizations.of(context).cart_screen_update_cart,
                      style: TextStyle(
                          color: MyTheme.medium_grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      onPressUpdate();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 32) * (2 / 3),
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                      Border.all(color: MyTheme.textfield_grey, width: 1),
                      borderRadius:app_language_rtl.$ ?
                      const BorderRadius.only(
                        topLeft: const Radius.circular(8.0),
                        bottomLeft: const Radius.circular(8.0),
                        topRight: const Radius.circular(0.0),
                        bottomRight: const Radius.circular(0.0),
                      ): const BorderRadius.only(
                        topLeft: const Radius.circular(0.0),
                        bottomLeft: const Radius.circular(0.0),
                        topRight: const Radius.circular(8.0),
                        bottomRight: const Radius.circular(8.0),
                      )),
                  child: FlatButton(
                    minWidth: MediaQuery.of(context).size.width,
                    //height: 50,
                    color: MyTheme.accent_color,
                    shape: app_language_rtl.$ ?
                    RoundedRectangleBorder(
                        borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(8.0),
                          bottomLeft: const Radius.circular(8.0),
                          topRight: const Radius.circular(0.0),
                          bottomRight: const Radius.circular(0.0),
                        ))
                        : RoundedRectangleBorder(
                        borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(0.0),
                          bottomLeft: const Radius.circular(0.0),
                          topRight: const Radius.circular(8.0),
                          bottomRight: const Radius.circular(8.0),
                        )),
                    child: Text(
                      AppLocalizations.of(context).cart_screen_proceed_to_shipping,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      onPressProceedToShipping();
                    },
                  ),
                ),
              ),
            ],
          )*/

        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
backgroundColor: Colors.white,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {
          _scaffoldKey.currentState.openDrawer();
        },
        child: Builder(
          builder: (context) => Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 18.0, horizontal: 0.0),
            child: Container(
              child: Image.asset(
                'assets/hamburger.png',
                height: 16,
                color: MyTheme.dark_grey,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        "My Cart",
        style: TextStyle(fontSize: 16, color: MyTheme.black),
      ),
      elevation: 3.0,
      titleSpacing: 0,
    );
  }



  buildCartSellerList() {
    if (is_logged_in.$ == false) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
                AppLocalizations.of(context).cart_screen_please_log_in,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else if (_isInitial && _shopList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_shopList.length > 0) {
      return ListView.builder(
        itemCount: _shopList.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*Padding(
                padding: const EdgeInsets.only(bottom: 0.0, top: 16.0),
                child: Row(
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:8.0),
                      child: Text(
                        _shopList[index].name,
                        style: TextStyle(color: MyTheme.font_grey),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        partialTotalString(index),
                        style: TextStyle(
                            color: MyTheme.accent_color, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),*/
              buildCartSellerItemList(index),
              Padding(
                padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                child: Divider(color: Colors.grey,),
              ),

            ],
          );
        },
      );
    } else if (!_isInitial && _shopList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
                AppLocalizations.of(context).cart_screen_cart_empty,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  ListView buildCartSellerItemList(seller_index) {
    return ListView.builder(
      itemCount: _shopList[seller_index].cart_items.length,
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return buildCartSellerItemCard(seller_index, index);
      },
    );
  }

  buildCartSellerItemCard(seller_index, item_index) {

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: InkWell(
          onTap: (){
            onPressDelete(_shopList[seller_index]
                  .cart_items[item_index]
                  .id);

          },
          child: Container(
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.pink,
              child: Icon(Icons.clear,color: Colors.white,),
            ),
          ),
        ),
      ),
      Container(
          width: 70,
          height: 70,
          /*decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8)
          ),*/
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/placeholder.png',
                image: AppConfig.BASE_PATH +
                    _shopList[seller_index]
                        .cart_items[item_index]
                        .product_thumbnail_image.replaceAll(",",""),
                fit: BoxFit.fitWidth,
              ))),
      Expanded(
        child: Container(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shopList[seller_index]
                          .cart_items[item_index]
                          .product_name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.black,
                          fontSize: 13,
                         // height: 1.6,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _shopList[seller_index]
                          .cart_items[item_index]
                          .currency_symbol +
                          (_shopList[seller_index]
                              .cart_items[item_index]
                              .price *
                              _shopList[seller_index]
                                  .cart_items[item_index]
                                  .quantity)
                              .toString()+" X "+_shopList[seller_index]
                          .cart_items[item_index]
                          .quantity
                          .toString(),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.medium_grey,
                          fontSize: 13,
                         // height: 1.6,
                          fontWeight: FontWeight.bold),
                    ),

                   /* Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _shopList[seller_index]
                                    .cart_items[item_index]
                                    .currency_symbol +
                                (_shopList[seller_index]
                                            .cart_items[item_index]
                                            .price *
                                        _shopList[seller_index]
                                            .cart_items[item_index]
                                            .quantity)
                                    .toString(),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          child: SizedBox(
                            height: 28,
                            child: InkWell(
                              onTap: () {},
                              child: IconButton(
                                onPressed: () {
                                  onPressDelete(_shopList[seller_index]
                                      .cart_items[item_index]
                                      .id);
                                },
                                icon: Icon(
                                  Icons.delete_forever_outlined,
                                  color: MyTheme.medium_grey,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(width: 15,),
      Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 0.0,right: 8.0),
        child: Container(
          width: 40,height: 35,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8)
          ),
          child: Center(
            child: Text(
              _shopList[seller_index]
                  .cart_items[item_index]
                  .quantity
                  .toString(),
              style: TextStyle(color: MyTheme.medium_grey, fontSize: 16),
            ),
          ),
        ),
      ),

    ]);
  }
}

