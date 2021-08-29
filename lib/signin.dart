import 'dart:ui';
import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import '../constants.dart';
import '../responsive.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}


class _SignInState extends State<SignIn> {

  var emailController=TextEditingController();
  var passwordController=TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double width=MediaQuery.of(context).size.width;
    double height=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: bgColor,
      body: Responsive.isMobile(context)?
      Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text("Sign in to Hammam Alsham",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900,color: Colors.white),),
              ),
              SizedBox(height: 20,),
              TextFormField(
                style: TextStyle(color: Colors.black),
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },

                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: secondaryColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: secondaryColor,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: secondaryColor,
                    ),
                  ),
                  filled: true,
                  //prefixIcon: Icon(Icons.email_outlined,color: Colors.black,size: 22,),
                  fillColor: Colors.white,
                  hintText: "Enter your email",
                  // If  you are using latest version of flutter then lable text and hint text shown like this
                  // if you r using flutter less then 1.20.* then maybe this is not working properly
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              SizedBox(height: 20,),
              TextFormField(
                style: TextStyle(color: Colors.black),
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: secondaryColor
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: secondaryColor
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: secondaryColor
                    ),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  hintText: "Enter your password",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              SizedBox(height: 20,),
              InkWell(
                onTap: ()async{
                  final ProgressDialog pr = ProgressDialog(context: context);
                  if (_formKey.currentState!.validate()) {
                    try {
                      print("email:${emailController.text.trim()}");
                      pr.show(max: 100, msg: "Please wait");
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text
                      ).then((value) {
                        pr.close();
                        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => MainScreen()));

                      }).onError((error, stackTrace){
                        pr.close();
                        print(emailController.text.trim());
                        print(error.toString());
                      });
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        pr.close();
                        print('No user found for that email.');
                      } else if (e.code == 'wrong-password') {
                        pr.close();
                        print('Wrong password provided for that user.');
                      }
                    }
                  }
                },
                child: Container(
                  color: primaryColor,
                  alignment: Alignment.center,
                  height: 50,
                  child: Text("SIGN IN",style: TextStyle(fontSize:20,color: Colors.white),),
                ),
              ),
              SizedBox(height: 20,),

            ],
          ),
        ),
      )
          :

      Container(
        height: height*0.5,
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.all(defaultPadding),
          color: Colors.white,
          width: width*0.28,
          height: height*0.2,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text("Sign in to Accesfy",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900,color: Colors.black),),
                ),
                SizedBox(height: 20,),
                TextFormField(
                  style: TextStyle(color: Colors.black),
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },

                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: secondaryColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: secondaryColor,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: secondaryColor,
                      ),
                    ),
                    //filled: true,
                    //prefixIcon: Icon(Icons.email_outlined,color: Colors.black,size: 22,),
                    //fillColor: Colors.grey[200],
                    hintText: "Enter your email",
                    // If  you are using latest version of flutter then lable text and hint text shown like this
                    // if you r using flutter less then 1.20.* then maybe this is not working properly
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
                SizedBox(height: 20,),
                TextFormField(
                  style: TextStyle(color: Colors.black),
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: secondaryColor
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: secondaryColor
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: secondaryColor
                      ),
                    ),

                    hintText: "Enter your password",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
                SizedBox(height: 20,),
                InkWell(
                  onTap: ()async{
                    final ProgressDialog pr = ProgressDialog(context: context);
                    if (_formKey.currentState!.validate()) {
                      try {
                        print("email:${emailController.text.trim()}");
                        pr.show(max: 100, msg: "Please wait");
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text
                        ).then((value) {
                          pr.close();
                          Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => MainScreen()));

                        }).onError((error, stackTrace){
                          pr.close();
                          print(emailController.text.trim());
                          print(error.toString());
                        });
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          pr.close();
                          print('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          pr.close();
                          print('Wrong password provided for that user.');
                        }
                      }
                    }
                  },
                  child: Container(
                    color: secondaryColor,
                    alignment: Alignment.center,
                    height: 50,
                    child: Text("SIGN IN",style: TextStyle(fontSize:20,color: Colors.white),),
                  ),
                ),
                SizedBox(height: 20,),

              ],
            ),
          ),
        ),
      )
    );
  }


}
