import 'package:webixes/data_model/category_response.dart';
import 'package:webixes/repositories/product_repository.dart';
import 'package:webixes/screens/sub_category_list.dart';
import 'package:flutter/material.dart';
import 'package:webixes/my_theme.dart';
import 'package:webixes/ui_sections/drawer.dart';
import 'package:webixes/custom/toast_component.dart';
import 'package:flutter/widgets.dart';
import 'package:toast/toast.dart';
import 'package:webixes/screens/category_products.dart';
import 'package:webixes/repositories/category_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webixes/app_config.dart';
import 'package:webixes/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryList extends StatefulWidget {
  CategoryList(
      {Key key,
      this.parent_category_id = 0,
      this.parent_category_name = "",
      this.is_base_category = false,
      this.is_top_category = false})
      : super(key: key);

  final int parent_category_id;
  final String parent_category_name;
  final bool is_base_category;
  final bool is_top_category;

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController txtQuery=TextEditingController();
  List<Category> _searchResult = [];

  List<Category> _categoryDetails=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // In initState()
    getCategoryDetails();
  }
  getCategoryDetails() async {
    var future = widget.is_top_category
        ? CategoryRepository().getTopCategories()
        : CategoryRepository().getCategories(parent_id: widget.parent_category_id);
   //  var categoryResponse = await CategoryRepository().getCategories();
    future.then((value){

      _searchResult.addAll(value.categories);
      _categoryDetails.addAll(value.categories);
      print("_searchResult-->$_searchResult");
      print("_categoryDetails-->$_categoryDetails");
    });
  }
  @override
  Widget build(BuildContext context) {
     return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          key: _scaffoldKey,
          drawer: MainDrawer(),
          backgroundColor: MyTheme.gray,
          appBar: buildAppBar(context),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0,top:10,right: 20),
                  child: Container(
                    color: Colors.white,
                    child:  buildHomeSearchBox(context),
                  ),
                ),

                buildCategoryList()
              ],
            ),
          )),
    );
  }
  buildHomeSearchBox(BuildContext context) {
    return TextField(
      onTap: () {

      },
      autofocus: false,
      onChanged: (value) => onSearchTextChanged(value),
     // onChanged: onSearchTextChanged(value),
      decoration: InputDecoration(
          hintText: AppLocalizations.of(context).home_screen_search,
          hintStyle: TextStyle(fontSize: 12.0, color: MyTheme.dark_grey),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.medium_grey_50, width: 1.0),
            borderRadius: const BorderRadius.all(
              const Radius.circular(5.0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.dark_grey, width: 1.0),
            borderRadius: const BorderRadius.all(
              const Radius.circular(5.0),
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
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: widget.is_base_category
          ? GestureDetector(
              onTap: () {
                _scaffoldKey.currentState.openDrawer();
              },
              child: Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 0.0),
                  child: Container(
                    child: Image.asset(
                      'assets/hamburger.png',
                      height: 16,
                      color: MyTheme.dark_grey,
                    ),
                  ),
                ),
              ),
            )
          : Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
      title: Text('All category',
       // getAppBarTitle(),
        style: TextStyle(fontSize: 16, color: MyTheme.black),
      ),
      elevation: 3.0,
      titleSpacing: 0,
    );
  }

  String getAppBarTitle() {
    String name = widget.parent_category_name == ""
        ? (widget.is_top_category ? AppLocalizations.of(context).category_list_screen_top_categories : AppLocalizations.of(context).category_list_screen_categories)
        : widget.parent_category_name;

    return name;
  }

  buildCategoryList() {
    var future = widget.is_top_category
        ? CategoryRepository().getTopCategories()
        : CategoryRepository()
            .getCategories(parent_id: widget.parent_category_id);
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            //snapshot.hasError
            print("category list error");
            print(snapshot.error.toString());
            return Container(
              height: 10,
            );
          } else if (snapshot.hasData) {
            var categoryResponse = snapshot.data;

            return  GridView.builder(
              // 2
              //addAutomaticKeepAlives: true,
              itemCount: _searchResult.length,
             // controller: _scrollController,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3 / 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10
              ),
              padding: EdgeInsets.all(16),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // 3
                return _searchResult.isNotEmpty||_searchResult.length!=0?
                InkWell(
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return SubCategoryList(
                            parent_category_id:
                            _searchResult[index].id,
                            parent_category_name:
                            _searchResult[index].name,
                          );
                        }));
                  },
                  child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: new BorderSide(color: MyTheme.yellow, width: 0.5),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      elevation: 0.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10,),
                          _searchResult[index].banner!=null?Row(
                              mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            Container(
                                width: 80,
                                height: 80,
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder.png',
                                  image: AppConfig.BASE_PATH + _searchResult[index].banner[0],
                                  fit: BoxFit.cover,
                                )),

                          ]):Row(
                              mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            Container(
                                width: 80,
                                height: 80,
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder.png',
                                  image: AppConfig.BASE_PATH + _searchResult[index].banner[0],
                                  fit: BoxFit.cover,
                                )),

                          ]),
                          Container(
                            height: 60,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                                  child: Text(
                                    _searchResult[index].name,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: MyTheme.font_grey,
                                        fontSize: 13,
                                        height: 1.6,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                /* Padding(
                  padding: EdgeInsets.fromLTRB(32, 8, 8, 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (categoryResponse
                                  .categories[index].number_of_children >
                              0) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CategoryList(
                                parent_category_id:
                                    categoryResponse.categories[index].id,
                                parent_category_name:
                                    categoryResponse.categories[index].name,
                              );
                            }));
                          } else {
                            ToastComponent.showDialog(
                                AppLocalizations.of(context).category_list_screen_no_subcategories, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_LONG);
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context).category_list_screen_view_subcategories,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: categoryResponse
                                          .categories[index].number_of_children >
                                      0
                                  ? MyTheme.medium_grey
                                  : MyTheme.light_grey,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      Text(
                        " | ",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: MyTheme.medium_grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CategoryProducts(
                              category_id: categoryResponse.categories[index].id,
                              category_name:
                                  categoryResponse.categories[index].name,
                            );
                          }));
                        },
                        child: Text(
                          AppLocalizations.of(context).category_list_screen_view_products,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: MyTheme.medium_grey,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),*/
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                ): InkWell(
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return SubCategoryList(
                            parent_category_id:
                            categoryResponse[index].id,
                            parent_category_name:
                            categoryResponse[index].name,
                          );
                        }));
                  },
                  child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: new BorderSide(color: MyTheme.yellow, width: 0.5),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      elevation: 0.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10,),
                          categoryResponse[index].banner!=null?Row(
                              mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            Container(
                                width: 80,
                                height: 80,
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder.png',
                                  image: AppConfig.BASE_PATH + categoryResponse[index].banner[0],
                                  fit: BoxFit.cover,
                                )),

                          ]):Row(
                              mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            Container(
                                width: 80,
                                height: 80,
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder.png',
                                  image: AppConfig.BASE_PATH + categoryResponse[index].banner[0],
                                  fit: BoxFit.cover,
                                )),

                          ]),
                          Container(
                            height: 60,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                                  child: Text(
                                    categoryResponse[index].name,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: MyTheme.font_grey,
                                        fontSize: 13,
                                        height: 1.6,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                /* Padding(
                  padding: EdgeInsets.fromLTRB(32, 8, 8, 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (categoryResponse
                                  .categories[index].number_of_children >
                              0) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CategoryList(
                                parent_category_id:
                                    categoryResponse.categories[index].id,
                                parent_category_name:
                                    categoryResponse.categories[index].name,
                              );
                            }));
                          } else {
                            ToastComponent.showDialog(
                                AppLocalizations.of(context).category_list_screen_no_subcategories, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_LONG);
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context).category_list_screen_view_subcategories,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: categoryResponse
                                          .categories[index].number_of_children >
                                      0
                                  ? MyTheme.medium_grey
                                  : MyTheme.light_grey,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      Text(
                        " | ",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: MyTheme.medium_grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CategoryProducts(
                              category_id: categoryResponse.categories[index].id,
                              category_name:
                                  categoryResponse.categories[index].name,
                            );
                          }));
                        },
                        child: Text(
                          AppLocalizations.of(context).category_list_screen_view_products,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: MyTheme.medium_grey,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),*/
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                );
               /* return _searchResult.isNotEmpty||_searchResult.length!=0?
                buildCategoryItemCard(_searchResult, index):
                Container();*/
              },
            );
          } else {
            return SingleChildScrollView(
              child: ListView.builder(
                itemCount: 10,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 4.0, bottom: 4.0, left: 16.0, right: 16.0),
                    child: Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: MyTheme.shimmer_base,
                          highlightColor: MyTheme.shimmer_highlighted,
                          child: Container(
                            height: 60,
                            width: 60,
                            color: Colors.white,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 8.0),
                              child: Shimmer.fromColors(
                                baseColor: MyTheme.shimmer_base,
                                highlightColor: MyTheme.shimmer_highlighted,
                                child: Container(
                                  height: 20,
                                  width: MediaQuery.of(context).size.width * .7,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Shimmer.fromColors(
                                baseColor: MyTheme.shimmer_base,
                                highlightColor: MyTheme.shimmer_highlighted,
                                child: Container(
                                  height: 20,
                                  width: MediaQuery.of(context).size.width * .5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

        });
  }
  onSearchTextChanged(String text) async {
    print(text);
    List<Category> results = [];
  //  _searchResult.clear();
    if (text.isEmpty||text=="") {
      results = _categoryDetails;
      //_searchResult=_categoryDetails;
     // setState(() {});
     // return;
    }else {
      results= _categoryDetails
          .where((user) =>
          user.name.toLowerCase().contains(text.toLowerCase()))
          .toList();
      /*_categoryDetails.forEach((userDetail) {
        if (userDetail.name.toLowerCase().contains(text.toLowerCase()) ||
            userDetail.name.toUpperCase().contains(text.toUpperCase()))
          _searchResult.add(userDetail);
      });*/

     // setState(() {});
    }
    setState(() {
     _searchResult=results;
     print(_searchResult);
    });
  }

  InkWell buildCategoryItemCard(categoryResponse, index) {
    return _searchResult.isNotEmpty||_searchResult.length!=0?
    InkWell(
      onTap: (){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return SubCategoryList(
                parent_category_id:
                categoryResponse.categories[index].id,
                parent_category_name:
                categoryResponse.categories[index].name,
              );
            }));
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: new BorderSide(color: MyTheme.yellow, width: 0.5),
          borderRadius: BorderRadius.circular(5.0),
        ),
        elevation: 0.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10,),
            _searchResult[index].banner!=null?Row(
                mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Container(
                  width: 80,
                  height: 80,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: AppConfig.BASE_PATH + _searchResult[index].banner[index],
                    fit: BoxFit.cover,
                  )),

            ]):Row(
                mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Container(
                  width: 80,
                  height: 80,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: AppConfig.BASE_PATH + _searchResult[index].banner[index],
                    fit: BoxFit.cover,
                  )),

            ]),
            Container(
              height: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: Text(
                      _searchResult[index].name,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  /* Padding(
                  padding: EdgeInsets.fromLTRB(32, 8, 8, 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (categoryResponse
                                  .categories[index].number_of_children >
                              0) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CategoryList(
                                parent_category_id:
                                    categoryResponse.categories[index].id,
                                parent_category_name:
                                    categoryResponse.categories[index].name,
                              );
                            }));
                          } else {
                            ToastComponent.showDialog(
                                AppLocalizations.of(context).category_list_screen_no_subcategories, context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_LONG);
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context).category_list_screen_view_subcategories,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: categoryResponse
                                          .categories[index].number_of_children >
                                      0
                                  ? MyTheme.medium_grey
                                  : MyTheme.light_grey,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      Text(
                        " | ",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: MyTheme.medium_grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CategoryProducts(
                              category_id: categoryResponse.categories[index].id,
                              category_name:
                                  categoryResponse.categories[index].name,
                            );
                          }));
                        },
                        child: Text(
                          AppLocalizations.of(context).category_list_screen_view_products,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: MyTheme.medium_grey,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),*/
                ],
              ),
            ),
          ],
        )
      ),
    ):Container();
  }

  Container buildBottomContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),

      height: widget.is_base_category ? 0 : 80,
      //color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: (MediaQuery.of(context).size.width - 32),
                height: 40,
                child: FlatButton(
                  minWidth: MediaQuery.of(context).size.width,
                  //height: 50,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0))),
                  child: Text(
                    AppLocalizations.of(context).category_list_screen_all_products_of + " " + widget.parent_category_name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CategoryProducts(
                        category_id: widget.parent_category_id,
                        category_name: widget.parent_category_name,
                      );
                    }));
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
