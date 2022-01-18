import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../my_theme.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key key, this.show_back_button = false}) : super(key: key);

  bool show_back_button;

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Dummy Product Data Here
  List myProducts = List.generate(100, (index) {
    return {"id": index, "title": "Suha just uploaded new product!", "price": "12 min ago"};
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:buildAppBar(context),
        backgroundColor: MyTheme.gray,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width:  MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Clear All',style: TextStyle(color: MyTheme.dark_grey,fontSize: 16),)
                    ],
                  ),
                ),
               Expanded(child:  ListView.builder(
                 itemCount: myProducts.length,
                 physics: NeverScrollableScrollPhysics(),
                 itemBuilder: (BuildContext ctx, index) {
                   // Display the list item
                   return Card(
                     shape: RoundedRectangleBorder(
                       side: new BorderSide(color: MyTheme.white, width: 1.0),
                       borderRadius: BorderRadius.circular(10.0),
                     ),
                     margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                     child: ListTile(
                       leading: CircleAvatar(
                           backgroundColor: MyTheme.yellow,
                           child: Icon(Icons.notifications_none,color: Colors.white,)
                       ),
                       title: Text(myProducts[index]["title"]),
                       subtitle: Text("${myProducts[index]["price"].toString()}"),

                     ),
                   );
                 },
               ))
              ],
            ),
            // The ListView will be here
          ),
        )
    );
  }
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text('Notifications',
        // getAppBarTitle(),
        style: TextStyle(fontSize: 16, color: MyTheme.black),
      ),
      elevation: 5.0,
      titleSpacing: 0,
    );
  }
}