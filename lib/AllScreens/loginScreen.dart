import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/AllScreens/registrationScreen.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/widgets/progressDialog.dart';

import 'mainscreen.dart';


class LoginScreen extends StatelessWidget {

  static const String idScreen = "login";

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginAndAuthUser(BuildContext context) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext mContext) {
        return ProgressDialog(message: "Authenticating, please wait");
      }
    );

    final User firebaseUser = (await _firebaseAuth
        .signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim()
    ).catchError((err) {
      Navigator.pop(context);
      displayToast(context, "Error: " +err.toString());
    })).user;

    if(firebaseUser != null) {

      usersRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if(snap.value != null) {
          Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
          displayToast(context, "You're logged in Successfully");
        }
        else
          {
            Navigator.pop(context);
            _firebaseAuth.signOut();
            displayToast(context, "No record exists for this user. Create Account");
          }
      });

    }
    else {
      Navigator.pop(context);
      displayToast(context, "Login Error");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 35.0,),
            Image(
              image: AssetImage("images/logo.png"),
              height: 200.0,
              width: 200.0,
              alignment: Alignment.center,
            ),

            SizedBox(height: 1.0,),
            Text(
              "Login as Rider",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
            ),

            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: 1.0,),
                  TextField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0
                        )
                    ),
                    style: TextStyle(
                        fontSize: 14.0
                    ),
                  ),
                  
                  SizedBox(height: 1.0,),
                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0
                        )
                    ),
                    style: TextStyle(
                        fontSize: 14.0
                    ),
                  ),

                  SizedBox(height: 20.0,),
                  RaisedButton(
                    color: Colors.yellow,
                    textColor: Colors.white,
                    child: Container(
                      height: 50.0,
                      width: 200.0,
                      child: Center(
                        child: Text(
                          "Login",
                          style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0)
                    ),
                    onPressed: () {
                      if(!emailTextEditingController.text.contains("@")){
                        displayToast(context, "email address is not valid");
                      }
                      else if(passwordTextEditingController.text.isEmpty){
                        displayToast(context, "Password is mandatory");
                      }
                      else
                        {
                          loginAndAuthUser(context);
                        }
                    },
                  )
                ],
              ),
            ),
            
            FlatButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.idScreen, (route) => false);
              },
              child: Text(
                "Do not have an Account? Register here"
              ),
            ),
          ],
        ),
      ),
    );
  }
}
