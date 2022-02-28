import 'package:webixes/my_theme.dart';
import 'package:webixes/screens/main.dart';
import 'package:webixes/ui_elements/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webixes/custom/input_decorations.dart';
import 'package:webixes/custom/intl_phone_input.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:webixes/screens/password_otp.dart';
import 'package:webixes/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:webixes/repositories/auth_repository.dart';
import 'package:webixes/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PasswordForget extends StatefulWidget {
  @override
  _PasswordForgetState createState() => _PasswordForgetState();
}

class _PasswordForgetState extends State<PasswordForget> {
  String _send_code_by = "email"; //phone or email
  String initialCountry = 'US';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'US');
  String _phone = "";

  //controllers
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressSendCode() async {
    var email = _emailController.text.toString();

    if (_send_code_by == 'email' && email == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).password_forget_screen_email_warning, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (_send_code_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).password_forget_screen_phone_warning, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    var passwordForgetResponse = await AuthRepository()
        .getPasswordForgetResponse(
            _send_code_by == 'email' ? email : _phone, _send_code_by);

    if (passwordForgetResponse.result == false) {
      ToastComponent.showDialog(passwordForgetResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      ToastComponent.showDialog(passwordForgetResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PasswordOtp(
          verify_by: _send_code_by,
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.soft_accent_color,
        body: SingleChildScrollView(
          child: Column(
           // alignment: Alignment.center,
            children: [
              SizedBox(height: 100,),
              Container(
                width: double.infinity,
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0, bottom: 15),
                      child: Container(
                        width: 200,
                        height: 75,
                        child: Image.asset('citydeal/img/core-img/logo-small.png'),
                      ),
                    ),
                    SizedBox(height: 20,),
                    /*Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        "Forget Password ?",
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ),*/
                    Container(
                      width: _screen_width * (3 / 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              _send_code_by == "email" ? AppLocalizations.of(context).login_screen_email : AppLocalizations.of(context).login_screen_phone,
                              style: TextStyle(
                                  color: MyTheme.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (_send_code_by == "email")
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    // height: 50,
                                    child: CustomWidgets.textField('Enter mobile number/email',isNumber: false,textController: _emailController,icon:Icons.person_outline),
                                  ),
                                /*  otp_addon_installed.$
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _send_code_by = "phone";
                                            });
                                          },
                                          child: Text(
                                            AppLocalizations.of(context).password_forget_screen_send_code_via_phone,
                                            style: TextStyle(
                                                color: MyTheme.accent_color,
                                                fontStyle: FontStyle.italic,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        )
                                      : Container()*/
                                ],
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                 /* Container(
                                    height: 36,
                                    child: CustomInternationalPhoneNumberInput(
                                      onInputChanged: (PhoneNumber number) {
                                        print(number.phoneNumber);
                                        setState(() {
                                          _phone = number.phoneNumber;
                                        });
                                      },
                                      onInputValidated: (bool value) {
                                        print(value);
                                      },
                                      selectorConfig: SelectorConfig(
                                        selectorType: PhoneInputSelectorType.DIALOG,
                                      ),
                                      ignoreBlank: false,
                                      autoValidateMode: AutovalidateMode.disabled,
                                      selectorTextStyle:
                                          TextStyle(color: MyTheme.font_grey),
                                      initialValue: phoneCode,
                                      textFieldController: _phoneNumberController,
                                      formatInput: true,
                                      keyboardType: TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                      inputDecoration: InputDecorations
                                          .buildInputDecoration_phone(
                                              hint_text: "01710 333 558"),
                                      onSaved: (PhoneNumber number) {
                                        print('On Saved: $number');
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _send_code_by = "email";
                                      });
                                    },
                                    child: Text(
                                      AppLocalizations.of(context).password_forget_screen_send_code_via_email,
                                      style: TextStyle(
                                          color: MyTheme.accent_color,
                                          fontStyle: FontStyle.italic,
                                          decoration: TextDecoration.underline),
                                    ),
                                  )*/
                                ],
                              ),
                            ),

                          Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: CustomButton(
                                onPressed: (){
                                  onPressSendCode();
                                },
                                title:  'Reset Password',
                                bgColor:  MyTheme.yellow,
                              )
                          ),
                         /* Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: MyTheme.textfield_grey, width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0))),
                              child: FlatButton(
                                minWidth: MediaQuery.of(context).size.width,
                                //height: 50,
                                color: MyTheme.accent_color,
                                shape: RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12.0))),
                                child: Text(
                                  "Send Code",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                onPressed: () {
                                  onPressSendCode();
                                },
                              ),
                            ),
                          ),*/
                        ],
                      ),
                    )
                  ],
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
