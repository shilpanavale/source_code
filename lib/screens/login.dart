import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/screens/home.dart';
import 'package:active_ecommerce_flutter/ui_elements/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:active_ecommerce_flutter/screens/registration.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/screens/password_forget.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _login_by = "email"; //phone or email
  String initialCountry = 'US';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  String _phone = "";

  //controllers
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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

  onPressedLogin() async {
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();

    if (_login_by == 'email' && email == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).login_screen_email_warning, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).login_screen_phone_warning, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).login_screen_password_warning, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    var loginResponse = await AuthRepository()
        .getLoginResponse(_login_by == 'email' ? email : _phone, password);
    if (loginResponse.result == false) {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {

      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      AuthHelper().setUserData(loginResponse);
      // push notification starts
      if (OtherConfig.USE_PUSH_NOTIFICATION) {
        final FirebaseMessaging _fcm = FirebaseMessaging.instance;

        await _fcm.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        String fcmToken = await _fcm.getToken();

        if (fcmToken != null) {
          print("--fcm token--");
          print(fcmToken);
          if (is_logged_in.$ == true) {
            // update device token
            var deviceTokenUpdateResponse = await ProfileRepository()
                .getDeviceTokenUpdateResponse(fcmToken);
          }
        }
      }

      //push norification ends

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Main();
      }));
    }
  }

  onPressedFacebookLogin() async {
    final facebookLogin =await FacebookAuth.instance.login(loginBehavior: LoginBehavior.webOnly);
    if (facebookLogin.status == LoginStatus.success) {
      // get the user data
      // by default we get the userId, email,name and picture
      final userData = await FacebookAuth.instance.getUserData();
      var loginResponse = await AuthRepository().getSocialLoginResponse(
          userData['name'].toString(), userData['email'].toString(), userData['id'].toString());
      print("..........................${loginResponse.toString()}");
      if (loginResponse.result == false) {
        ToastComponent.showDialog(loginResponse.message, context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      } else {
        ToastComponent.showDialog(loginResponse.message, context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
        FacebookAuth.instance.logOut();
      }
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");

    } else {
      print("....Facebook auth Failed.........");
      print(facebookLogin.status);
      print(facebookLogin.message);
    }


    /*print(facebookLoginResult.accessToken);
    print(facebookLoginResult.accessToken.token);
    print(facebookLoginResult.accessToken.expires);
    print(facebookLoginResult.accessToken.permissions);
    print(facebookLoginResult.accessToken.userId);
    print(facebookLoginResult.accessToken.isValid());

    print(facebookLoginResult.errorMessage);
    print(facebookLoginResult.status);*/
/*
    final token = facebookLoginResult.accessToken.token;

    /// for profile details also use the below code
    Uri url = Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
    final graphResponse = await http.get(url);
    final profile = json.decode(graphResponse.body);
    //print(profile);
    /*from profile you will get the below params
    {
     "name": "Iiro Krankka",
     "first_name": "Iiro",
     "last_name": "Krankka",
     "email": "iiro.krankka\u0040gmail.com",
     "id": "<user id here>"
    }*/

    var loginResponse = await AuthRepository().getSocialLoginResponse(
        profile['name'], profile['email'], profile['id'].toString());

    if (loginResponse.result == false) {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      AuthHelper().setUserData(loginResponse);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Main();
      }));
    }*/
  }

  onPressedGoogleLogin() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      // var v = await  GoogleSignIn().signOut();
      //print("googleUser.email ${googleUser.id}");

      var loginResponse = await AuthRepository().getSocialLoginResponse(
          googleUser.displayName, googleUser.email, googleUser.id);
      print(loginResponse);
      if (loginResponse.result == false) {
        ToastComponent.showDialog(loginResponse.message, context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      } else {
        ToastComponent.showDialog(loginResponse.message, context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
      }
      GoogleSignIn().disconnect();
    } on Exception catch (e) {
      print("error is ....... $e");
      // TODO
    }


    /*
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        // you can add extras if you require
      ],
    );
    print("acc.id............${}");

    _googleSignIn.signIn().then((GoogleSignInAccount acc) async {
      GoogleSignInAuthentication auth = await acc.authentication;
      print(acc.id);
      print(acc.email);
      print(acc.displayName);
      print(acc.photoUrl);

      acc.authentication.then((GoogleSignInAuthentication auth) async {
        print(auth.idToken);
        print(auth.accessToken);

        //---------------------------------------------------
        var loginResponse = await AuthRepository().getSocialLoginResponse(
            acc.displayName, acc.email, auth.accessToken);

        if (loginResponse.result == false) {
          ToastComponent.showDialog(loginResponse.message, context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
        } else {
          ToastComponent.showDialog(loginResponse.message, context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
          AuthHelper().setUserData(loginResponse);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Main();
          }));
        }

        //-----------------------------------
      });
    });*/
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.soft_accent_color,
        body: Stack(
          children: [
           /* Container(
              width: _screen_width * (3 / 4),
              //color: MyTheme.soft_accent_color,
              *//*child: Image.asset(
                  "assets/splash_login_registration_background_image.png"),*//*
            ),*/
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
                /*  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "${AppLocalizations.of(context).login_screen_login_to} " + AppConfig.app_name,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),*/
                  SizedBox(height: 20,),
                  Container(
                    width: _screen_width * (3 / 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            _login_by == "email" ? AppLocalizations.of(context).login_screen_email : AppLocalizations.of(context).login_screen_phone,
                            style: TextStyle(
                                color: MyTheme.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (_login_by == "email")
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
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
                                            _login_by = "phone";
                                          });
                                        },
                                        child: Text(
                                            AppLocalizations.of(context).login_screen_or_login_with_phone,
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
                                Container(
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
                                    textStyle:
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
                                      _login_by = "email";
                                    });
                                  },
                                  child: Text(
                                    AppLocalizations.of(context).login_screen_or_login_with_email,
                                    style: TextStyle(
                                        color: MyTheme.accent_color,
                                        fontStyle: FontStyle.italic,
                                        decoration: TextDecoration.underline),
                                  ),
                                )
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top:10.0,bottom: 4.0),
                          child: Text(
                            AppLocalizations.of(context).login_screen_password,
                            style: TextStyle(
                                color: MyTheme.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                //height: 50,
                                child: CustomWidgets.textField('Enter password',isPassword:true,isNumber: false,textController: _passwordController,icon:CupertinoIcons.padlock),
                              ),
                            ],
                          ),
                        ),
                       /* Padding(
                          padding: const EdgeInsets.only(top: 30.0),
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
                              color: MyTheme.golden,
                              shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0))),
                              child: Text(
                                AppLocalizations.of(context).login_screen_log_in,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {
                                onPressedLogin();
                              },
                            ),
                          ),
                        ),*/
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: CustomButton(
                            onPressed: (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return Main();
                                  }));
                            },
                          title:  AppLocalizations.of(context).login_screen_log_in,
                            bgColor:  MyTheme.yellow,
                          )
                        ),
                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return PasswordForget();
                                      }));
                                },
                                child: Text(
                                  AppLocalizations.of(context).login_screen_forgot_password,textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                      color: MyTheme.black,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5,),
                        Center(
                          child: GestureDetector(
                            onTap: () {

                            },
                            child: RichText(
                              textAlign: TextAlign.center,
                              softWrap: true,
                              text: new TextSpan(
                                style: new TextStyle(
                                  fontSize: 15.0,
                                ),
                                children: [
                                  new TextSpan(
                                      text: 'Didn\u0027t have an account?\t',
                                      style: new TextStyle(color: MyTheme.font_grey)),
                                  new TextSpan(
                                      text: AppLocalizations.of(context).login_screen_or_create_new_account,
                                      style: new TextStyle(color: MyTheme.black,fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {

                                        }),
                                ],
                              ),
                            ),
                          ),
                        ),
                       /* Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Center(
                              child: Text(
                                AppLocalizations.of(context).login_screen_or_create_new_account,
                            style: TextStyle(
                                color: MyTheme.medium_grey, fontSize: 12),
                          )),
                        ),*/
                       /* Padding(
                          padding: const EdgeInsets.only(top: 4.0),
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
                                AppLocalizations.of(context).login_screen_sign_up,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return Registration();
                                }));
                              },
                            ),
                          ),
                        ),*/
                       /* Visibility(
                          visible: allow_google_login.$ ||
                              allow_facebook_login.$,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Center(
                                child: Text(
                                  AppLocalizations.of(context).login_screen_login_with,
                              style: TextStyle(
                                  color: MyTheme.medium_grey, fontSize: 14),
                            )),
                          ),
                        ),*/

                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Center(
                            child: Container(
                              width: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Visibility(
                                    visible: allow_facebook_login.$,
                                    child: InkWell(
                                      onTap: () {
                                        onPressedFacebookLogin();
                                      },
                                      child: Container(
                                        color: Colors.white,
                                        width: 28,
                                        child: Image.asset(
                                            "citydeal/img/icons/facebook.png"),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Visibility(
                                    visible: allow_google_login.$,
                                    child: InkWell(
                                      onTap: () {
                                        onPressedGoogleLogin();
                                      },
                                      child: Container(
                                        width: 28,
                                        child:
                                            Image.asset("citydeal/img/icons/google-plus.png"),
                                      ),
                                    ),
                                  ),

                                  Visibility(
                                    visible: false,
                                    child: InkWell(
                                      onTap: () {
                                        // onPressedTwitterLogin();
                                      },
                                      child: Container(
                                        width: 28,
                                        child: Image.asset(
                                            "assets/twitter_logo.png"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                         Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Center(
                              child: Text('VIEW AS GUEST',
                            style: TextStyle(
                                color: MyTheme.dark_grey, fontSize: 14),
                          )),
                        ),
                      ],
                    ),
                  )
                ],
              )),
            )
          ],
        ),
      ),
    );
  }
}
