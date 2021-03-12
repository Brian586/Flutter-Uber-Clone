import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider_app/AllScreens/loginScreen.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/widgets/progressDialog.dart';

import 'mainscreen.dart';


class RegistrationScreen extends StatelessWidget {

  static const String idScreen = "register";

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  void registerNewUser(BuildContext context) async {

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext mContext) {
          return ProgressDialog(message: "Registering, please wait");
        }
    );

    final User firebaseUser = (await _firebaseAuth
        .createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim()
    ).catchError((err) {
      Navigator.pop(context);
      displayToast(context, "Error: " +err.toString());
    })).user;

    if(firebaseUser != null) {
      //save user info to db

      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };

      usersRef.child(firebaseUser.uid).set(userDataMap);

      displayToast(context, "Account created successfully");

      Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
    }
    else {
      Navigator.pop(context);
      displayToast(context, "New User Account has not been created");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.0,),
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
                    controller: nameTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: "Name",
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
                    controller: phoneTextEditingController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        labelText: "phone",
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
                          "Create Account",
                          style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0)
                    ),
                    onPressed: () {

                      if(nameTextEditingController.text.trim().length < 4)
                        {
                          displayToast(context, "name must be at least 3 characters");
                        }
                      else if(!emailTextEditingController.text.contains("@")){
                        displayToast(context, "email address is not valid");
                      }
                      else if(phoneTextEditingController.text.isEmpty){
                        displayToast(context, "phone number required");
                      }
                      else if(passwordTextEditingController.text.trim().length < 7){
                        displayToast(context, "Password must be at least 6 characters");
                      }
                      else{
                        registerNewUser(context);
                      }

                    },
                  )
                ],
              ),
            ),

            FlatButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
              },
              child: Text(
                  "Already have an Account? Login here"
              ),
            ),
          ],
        ),
      ),
    );
  }
}

displayToast(BuildContext context, String msg) {
  Fluttertoast.showToast(msg: msg);
}

