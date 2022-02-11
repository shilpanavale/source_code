import 'package:flutter/material.dart';

class DialogBuilder {
  DialogBuilder(this.context);

  final BuildContext context;

  void showLoadingIndicator([String text]) {
    showDialog(
      context: context,
      //barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => true,
            child: LoadingIndicator()
        );
      },
    );
  }

  void hideOpenDialog() {
    Navigator.of(context).pop();
  }
}

class LoadingIndicator extends StatelessWidget{
  const LoadingIndicator({this.text = ''});

  final String text;

  @override
  Widget build(BuildContext context) {
    var displayedText = text;
    return  AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
    return Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.white,
        height: 55,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _getLoadingIndicator(),
              _getHeading(context),
              //_getText(displayedText)
            ]
        )
    );
  }

  Padding _getLoadingIndicator() {
    return
     Padding(
        child: SizedBox(
            child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F4697))
            ),
            width: 40,
            height: 40
        ),
        padding: EdgeInsets.only(bottom: 1)

    );
  }

  Widget _getHeading(context) {
    return const Padding(
        child: Text(
          'Please wait …',
          style: TextStyle(
              color: Colors.black,
              fontSize: 16
          ),
          textAlign: TextAlign.center,
        ),
        padding: EdgeInsets.only(bottom: 4)
    );
  }

  Text _getText(String displayedText) {
    return Text(
      displayedText,
      style: const TextStyle(
          color: Colors.black,
          fontSize: 14
      ),
      textAlign: TextAlign.center,
    );
  }
}