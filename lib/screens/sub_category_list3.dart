import 'package:flutter/material.dart';
import 'package:webixes/my_theme.dart';
import 'package:webixes/screens/product_details.dart';
import 'package:webixes/ui_sections/drawer.dart';
import 'package:webixes/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:webixes/screens/category_products.dart';
import 'package:webixes/repositories/category_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webixes/app_config.dart';
import 'package:webixes/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SubCategoryList3 extends StatefulWidget {
  SubCategoryList3(
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
  _SubCategoryList3State createState() => _SubCategoryList3State();
}

class _SubCategoryList3State extends State<SubCategoryList3> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          key: _scaffoldKey,
          drawer: MainDrawer(),
          backgroundColor: MyTheme.gray,
          appBar: buildAppBar(context),
          body: Stack(children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child:Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      color: Colors.white,
                      child:  buildHomeSearchBox(context),
                    ),
                  ),
                ),
                SliverList(
                    delegate: SliverChildListDelegate([
                      buildCategoryList(),
                      Container(
                        height: widget.is_base_category ? 60 : 90,
                      )
                    ]))
              ],
            ),

          ])),
    );
  }
  buildHomeSearchBox(BuildContext context) {
    return TextField(
      onTap: () {

      },
      autofocus: false,
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
             borderSide: BorderSide(color: MyTheme.medium_grey_50, width: 1.0),
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
      title: Text('Sub Category',
       // getAppBarTitle(),
        style: TextStyle(fontSize: 16, color: MyTheme.black),
      ),
      elevation: 5.0,
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
            //snapshot.hasData
            var categoryResponse = snapshot.data;
            print(categoryResponse.categories.length);
         //  return categoryResponse.categories.=null?Text("no"):Text("yes");
            if(categoryResponse.categories.length==0){

              return Center(child: Text("No Category found"),);
            }else{
              return SingleChildScrollView(
                child: ListView.builder(
                  itemCount: categoryResponse.categories.length,
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, bottom: 4.0, left: 16.0, right: 16.0),
                      child: buildCategoryItemCard(categoryResponse, index),
                    );
                  },
                ),
              );
            }

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

  InkWell buildCategoryItemCard(categoryResponse, index) {
    return categoryResponse.categories[index].banner!=null?InkWell(
      onTap: (){
        print("tap");
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetails(id: categoryResponse.categories[index].id,);
        }));
      },
      child: Container(
       // height: 90,
        child: Card(
          shape: RoundedRectangleBorder(
            side: new BorderSide(color: MyTheme.yellow, width: 1.0),
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 0.0,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: <Widget>[
            categoryResponse.categories[index].banner[0]!=null? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(0), right: Radius.zero),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.png',
                        image: AppConfig.BASE_PATH + categoryResponse.categories[index].banner[0].toString(),
                        fit: BoxFit.cover,
                      ))),
            ):Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(0), right: Radius.zero),
                      child:Image.asset("assets/placeholder.png")
                  )),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Container(
                  //height: 80,color: Colors.black,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 8, 0),
                    child: Text(
                      categoryResponse.categories[index].name,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
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
