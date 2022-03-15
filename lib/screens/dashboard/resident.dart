import 'dart:html';

import 'package:accessify/models/board_member_model.dart';
import 'package:accessify/models/generate_password.dart';
import 'package:accessify/provider/UserDataProvider.dart';
import 'package:accessify/responsive.dart';
import 'package:accessify/components/dashboard/dashboard_sidebar.dart';
import 'package:accessify/components/header.dart';
import 'package:accessify/components/dashboard/resident_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import '../../constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase/firebase.dart' as fb;

class DashBoardScreen extends StatefulWidget {

  GlobalKey<ScaffoldState> _scaffoldKey;

  DashBoardScreen(this._scaffoldKey);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  var emailController=TextEditingController();
  var firstNameController=TextEditingController();
  var lastNameController=TextEditingController();
  var streetController=TextEditingController();
  var buildingController=TextEditingController();
  var floorController=TextEditingController();
  var apartmentUnitController=TextEditingController();
  var phoneController=TextEditingController();
  var cellPhoneController=TextEditingController();
  var addressController=TextEditingController();
  var commentController=TextEditingController();
  String? _classification;
  String neighbour="",neighbourId="";
  bool dataLoaded=false;


  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('boardmember')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

        BoardMemberModel model=BoardMemberModel.fromMap(data, documentSnapshot.reference.id);
        final provider = Provider.of<UserDataProvider>(context, listen: false);
        provider.setUserData(model);
        setState(() {
          neighbour=data['neighbourhoodName'];
          neighbourId=data['neighbourId'];
          dataLoaded=true;
        });

      }
    });
  }

  registerHomeOwner() async{
    final ProgressDialog pr = ProgressDialog(context: context);
    FirebaseApp app = await Firebase.initializeApp(name: 'Secondary', options: Firebase.app().options);
    try {
      pr.show(max: 100, msg: "Please wait");
      String password=generatePassword();
      await FirebaseAuth.instanceFor(app: app).createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: password
      ).then((value){
        FirebaseFirestore.instance.collection('homeowner').doc(value.user!.uid).set({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'street': streetController.text,
          'building': buildingController.text,
          'floor': floorController.text,
          'apartmentUnit': apartmentUnitController.text,
          'additionalAddress': addressController.text,
          'phone': phoneController.text,
          'cellPhone': cellPhoneController.text,
          'comment': commentController.text,
          'email': emailController.text,
          'password': password,
          'neighbourId':neighbourId,
          'neighbourhood':neighbour,
          'status':"Active",
          'classification':_classification==null?"No Classification":_classification
        }).then((value) {
          pr.close();
          Navigator.pop(context);
        }).onError((error, stackTrace){
          final snackBar = SnackBar(content: Text("Database Error"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        pr.close();
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        pr.close();
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
      pr.close();
    }
    pr.close();
    await app.delete();

  }


  Future<void> _showAddHomeOwnerDailog() async {
    final _formKey = GlobalKey<FormState>();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              insetAnimationDuration: const Duration(seconds: 1),
              insetAnimationCurve: Curves.fastOutSlowIn,
              elevation: 2,

              child: Container(
                padding: EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height*0.9,
                width: MediaQuery.of(context).size.width*0.5,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: Text("Add Home Owner",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: IconButton(
                                icon: Icon(Icons.close,color: Colors.grey,),
                                onPressed: ()=>Navigator.pop(context),
                              ),
                            ),
                          )
                        ],
                      ),

                      Expanded(
                        child: ListView(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "First Name",
                                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                          ),
                                          TextFormField(
                                            controller: firstNameController,
                                            style: TextStyle(color: Colors.black),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter some text';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(15),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                    color: primaryColor,
                                                    width: 0.5
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 0.5,
                                                ),
                                              ),
                                              hintText: "John",
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Last Name",
                                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                          ),
                                          TextFormField(
                                            controller: lastNameController,
                                            style: TextStyle(color: Colors.black),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter some text';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(15),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                    color: primaryColor,
                                                    width: 0.5
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 0.5,
                                                ),
                                              ),
                                              hintText: "Doe",
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                )
                              ],
                            ),
                            SizedBox(height: 10,),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller: emailController,
                                  style: TextStyle(color: Colors.black),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(15),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: primaryColor,
                                          width: 0.5
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 0.5,
                                      ),
                                    ),
                                    hintText: "xyz@mail.com",
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Phone",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller: phoneController,
                                  style: TextStyle(color: Colors.black),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(15),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: primaryColor,
                                          width: 0.5
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 0.5,
                                      ),
                                    ),
                                    hintText: "0XX XXXX XXX",
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mobile Phone",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller:cellPhoneController,
                                  style: TextStyle(color: Colors.black),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(15),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: primaryColor,
                                          width: 0.5
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 0.5,
                                      ),
                                    ),
                                    hintText: "0XXX XXXX XXX",
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Street No.",
                                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                          ),
                                          TextFormField(
                                            controller: streetController,
                                            style: TextStyle(color: Colors.black),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter some text';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(15),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                    color: primaryColor,
                                                    width: 0.5
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 0.5,
                                                ),
                                              ),
                                              hintText: "#",
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Building No.",
                                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                          ),
                                          TextFormField(
                                            controller:buildingController,
                                            style: TextStyle(color: Colors.black),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter some text';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(15),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                    color: primaryColor,
                                                    width: 0.5
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 0.5,
                                                ),
                                              ),
                                              hintText: "#",
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                )
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Floor No.",
                                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                          ),
                                          TextFormField(
                                            controller:floorController,
                                            style: TextStyle(color: Colors.black),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter some text';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(15),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                    color: primaryColor,
                                                    width: 0.5
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 0.5,
                                                ),
                                              ),
                                              hintText: "#",
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Apartment Unit",
                                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                          ),
                                          TextFormField(
                                            controller: apartmentUnitController,
                                            style: TextStyle(color: Colors.black),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter some text';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(15),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                    color: primaryColor,
                                                    width: 0.5
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 0.5,
                                                ),
                                              ),
                                              hintText: "#",
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                )
                              ],
                            ),
                            SizedBox(height: 10,),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Classification",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance.collection('classification').where("neighbourId",isEqualTo:neighbourId).snapshots(),
                                    builder: (context, snapshot){
                                      if (!snapshot.hasData)
                                        return const Center(child: const CircularProgressIndicator(),);
                                      var length = snapshot.data!.docs.length;
                                      //DocumentSnapshot ds = snapshot.data!.docs[length - 1];
                                      //Map<String, dynamic> data = ds.data() as Map<String, dynamic>;

                                      return new Container(
                                        padding: EdgeInsets.only(left: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(7.0),
                                          border: Border.all(
                                            color: primaryColor,
                                          ),
                                        ),
                                        child: new DropdownButton<String>(
                                          underline: Container(),
                                          isExpanded: true,
                                          style: const TextStyle(color: Colors.black),
                                          value: _classification,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _classification = newValue;
                                              print(_classification);
                                            });
                                          },
                                          items: snapshot.data!.docs.map((DocumentSnapshot document) {
                                            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                                            return DropdownMenuItem<String>(
                                                value: data['name'],
                                                child: Text(data['name'])
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Comment",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  minLines: 3,
                                  maxLines: 3,
                                  controller:commentController,
                                  style: TextStyle(color: Colors.black),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(15),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: primaryColor,
                                          width: 0.5
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 0.5,
                                      ),
                                    ),
                                    hintText: "",
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Additional Address Information",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  minLines: 3,
                                  maxLines: 3,
                                  controller:addressController,
                                  style: TextStyle(color: Colors.black),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(15),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                          color: primaryColor,
                                          width: 0.5
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 0.5,
                                      ),
                                    ),
                                    hintText: "",
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15,),
                            InkWell(
                              onTap: (){
                                if (_formKey.currentState!.validate()) {
                                  registerHomeOwner();
                                }
                              },
                              child: Container(
                                height: 50,
                                color: secondaryColor,
                                alignment: Alignment.center,
                                child: Text("Add Home Owner",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header("Dashboard",widget._scaffoldKey),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "",
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          ElevatedButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: defaultPadding * 1.5,
                                vertical:
                                defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                              ),
                            ),
                            onPressed: () {
                              _showAddHomeOwnerDailog();
                            },
                            icon: Icon(Icons.add),
                            label: Text("Add New"),
                          ),
                        ],
                      ),

                      SizedBox(height: defaultPadding),
                      dataLoaded?ResidentList():CircularProgressIndicator(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) dataLoaded?DashboardSidebar():Center(child: CircularProgressIndicator(),),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: dataLoaded?DashboardSidebar():Center(child: CircularProgressIndicator()),
                  ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
