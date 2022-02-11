import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class CustomButton extends StatelessWidget{
  CustomButton({@required this.onPressed, this.title, this.bgColor});
  final GestureTapCallback onPressed;
  final String title;
  final Color bgColor;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 6.0,
      child: InkWell(
        splashColor: Colors.red,
        highlightColor: Colors.blue,
        onTap: onPressed,
        child: Container(
          //width: 220,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
               title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
class CustomWidgets {
  static Widget textField(String title,
      {bool isPassword = false,
        bool isNumber = false,
        int length,
        TextEditingController textController,
        int lines = 1,
        IconData icon}) {
    return Container(
     // margin: EdgeInsets.symmetric(vertical: 1),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            maxLines: lines,
            controller: textController,
            maxLength: length,
            inputFormatters: [
              LengthLimitingTextInputFormatter(length),
            ],
            obscureText: isPassword,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: title,
                helperStyle:TextStyle(
                  fontSize: 12,
                //color: MyTheme.black,
                fontWeight: FontWeight.w600),
                counterText: '',
                border: InputBorder.none,
                prefixIcon: Icon(icon,color: Colors.black,),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black54),
              ),
            ),
          ),
          //Divider(thickness: 2,color: Colors.black54,)
        ],
      ),
    );
  }
}

