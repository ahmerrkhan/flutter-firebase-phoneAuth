import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class loginScreen extends StatefulWidget{
  @override
  _loginScreenState createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  String verificationID;
  bool showLoading = false;
  final GlobalKey<ScaffoldState> _scaffkey = GlobalKey();
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  FirebaseAuth _auth = FirebaseAuth.instance;

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading = false;
      });

      if(authCredential?.user != null){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>homeScreen()));
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });
      _scaffkey.currentState.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Container(
        child: showLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
                ? getMobileFormWidget(context)
                : getOtpFormWidget(context),
      ),
    );
  }

  getMobileFormWidget(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Enter Your Phone number",
          style: TextStyle(
              color: Colors.green[900],
              fontWeight: FontWeight.bold,
              fontSize: 20.0),
        ),
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: TextField(
            decoration: InputDecoration(
                hintText: "Enter phone number",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0))),
            controller: phoneController,
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          onPressed: () async {
            setState(() {
              showLoading = true;
            });

            await _auth.verifyPhoneNumber(
                phoneNumber: phoneController.text,
                verificationCompleted: (phoneAuthCredential) async {
                  setState(() {
                    showLoading = false;
                  });
                  // signInWithPhoneAuthCredential(phoneAuthCredential);
                },
                verificationFailed: (verificaionFailed) async {
                  setState(() {
                    showLoading = false;
                  });
                  _scaffkey.currentState.showSnackBar(
                      SnackBar(content: Text(verificaionFailed.message)));
                },
                codeSent: (verificationID, resendToken) async {
                  setState(() {
                    showLoading = false;
                    currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                    this.verificationID = verificationID;
                  });
                },
                codeAutoRetrievalTimeout: (verificationID) async {});
          },
          child: Text("Send"),
          color: Colors.green,
        ),
      ],
    );
  }

  getOtpFormWidget(context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Enter otp",
          ),
          controller: otpController,
        ),
        SizedBox(
          height: 15.0,
        ),
        FlatButton(
          onPressed: () async {
            PhoneAuthCredential phoneAuthCredential =
                PhoneAuthProvider.credential(
                    verificationId: verificationID, smsCode: otpController.text);
            signInWithPhoneAuthCredential(phoneAuthCredential);
          },
          child: Text("Verify"),
          color: Colors.green,
        ),
      ],
    );
  }
}
