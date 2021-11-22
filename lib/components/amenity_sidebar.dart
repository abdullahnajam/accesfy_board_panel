import 'dart:html';
import 'package:accessify/models/generate_password.dart';
import 'package:accessify/models/home/guard_model.dart';
import 'package:accessify/models/inventory/supply_model.dart';
import 'package:accessify/screens/navigators/access_screen.dart';
import 'package:accessify/screens/navigators/inventory_screen.dart';
import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:intl/intl.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../constants.dart';

class AmenitySideBar extends StatefulWidget {
  const AmenitySideBar({Key? key}) : super(key: key);

  @override
  _AmenitySideBarState createState() => _AmenitySideBarState();
}

class _AmenitySideBarState extends State<AmenitySideBar> {
  String? neighbourId;
  bool isLoading=false;

  getUserData()async{
    User user=FirebaseAuth.instance.currentUser!;
    FirebaseFirestore.instance
        .collection('boardmember')
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        neighbourId=data['neighbourId'];
        setState(() {
          isLoading=true;
        });
      }
    });

  }


  @override
  void initState() {
    getUserData();
  }
  var _nameController=TextEditingController();
  Future<void> _showAddClassificationDailog() async {
    final _formKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (context) {
        var nameController=TextEditingController();
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
                height: MediaQuery.of(context).size.height*0.33,
                width: MediaQuery.of(context).size.width*0.4,
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
                              child: Text("Add Amenity",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Amenity",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller: _nameController,
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
                                print("rr");
                                final ProgressDialog pr = ProgressDialog(context: context);
                                pr.show(max: 100, msg: "Adding");
                                FirebaseFirestore.instance.collection('amenities').add({
                                  'name': _nameController,
                                }).then((value) {
                                  pr.close();
                                  Navigator.pop(context);
                                  AwesomeDialog(
                                    context: context,
                                    width: MediaQuery.of(context).size.width*0.3,
                                    dialogType: DialogType.SUCCES,
                                    animType: AnimType.TOPSLIDE,
                                    title: 'Success',
                                    dialogBackgroundColor: secondaryColor,
                                    desc: 'Amenity Successfully Added',
                                    btnOkOnPress: () {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AccessScreen()));
                                    },
                                  )..show();
                                }).onError((error, stackTrace){

                                });
                              },
                              child: Container(
                                height: 50,
                                color: secondaryColor,
                                alignment: Alignment.center,
                                child: Text("Add",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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
    return isLoading?Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Amenities",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          InkWell(
            onTap: (){
              _showAddClassificationDailog();
            },
            child: Text(
              "Add Amenity",
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Colors.white70),
            ),
          ),
          SizedBox(height: defaultPadding),
          Container(
            margin: EdgeInsets.only(top: defaultPadding),
            padding: EdgeInsets.all(defaultPadding),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('amenities').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        Image.asset("assets/images/wrong.png",width: 150,height: 150,),
                        Text("Something Went Wrong")

                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.size==0){
                  return Center(
                    child: Column(
                      children: [
                        Text("No Amenities Added")

                      ],
                    ),
                  );

                }

                return new ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                    return new Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: InkWell(
                          child: Container(
                            child: ListTile(
                              title: Text(data['name']),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_forever,color: Colors.white,),
                                onPressed: (){
                                  AwesomeDialog(
                                    dialogBackgroundColor: secondaryColor,
                                    width: MediaQuery.of(context).size.width*0.3,
                                    context: context,
                                    dialogType: DialogType.QUESTION,
                                    animType: AnimType.BOTTOMSLIDE,
                                    title: 'Delete Amenity',
                                    desc: 'Are you sure you want to delete this record?',
                                    btnCancelOnPress: () {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AccessScreen()));
                                    },
                                    btnOkOnPress: () {
                                      FirebaseFirestore.instance.collection('amenities').doc(document.reference.id).delete().then((value) =>
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AccessScreen())));
                                    },
                                  )..show();
                                },
                              ),

                            ),
                          ),
                        )
                    );
                  }).toList(),
                );
              },
            ),
          ),
          SizedBox(height: defaultPadding),

        ],
      ),
    ):Center(child:CircularProgressIndicator());
  }
}


