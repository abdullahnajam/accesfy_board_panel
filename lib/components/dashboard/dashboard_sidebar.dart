import 'dart:html';
import 'package:accessify/models/generate_password.dart';
import 'package:accessify/models/home/guard_model.dart';
import 'package:accessify/provider/UserDataProvider.dart';
import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../constants.dart';

class DashboardSidebar extends StatefulWidget {
  const DashboardSidebar({Key? key}) : super(key: key);

  @override
  _DashboardSidebarState createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {

  addClassification(String name) async{
    print("rr");
    final ProgressDialog pr = ProgressDialog(context: context);
    pr.show(max: 100, msg: "Adding");
    FirebaseFirestore.instance.collection('classification').add({
      'name': name,
      'neighbourId':neighbourId,
      'neighbourhood':neighbour,
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
        desc: 'Classification Successfully Added',
        btnOkOnPress: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
        },
      )..show();
    }).onError((error, stackTrace){

    });
  }
  String neighbour="",neighbourId="";


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
        neighbour=data['neighbourhoodName'];
        neighbourId=data['neighbourId'];

      }
    });
  }





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
                height: MediaQuery.of(context).size.height*0.3,
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
                              child: Text("Add Classification",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                                  "Classification",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller: nameController,
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
                                    hintText: "Rent",
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15,),
                            InkWell(
                              onTap: (){
                                addClassification(nameController.text.trim());
                              },
                              child: Container(
                                height: 50,
                                color: secondaryColor,
                                alignment: Alignment.center,
                                child: Text("Add Classification",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dashboard Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          Container(
              margin: EdgeInsets.only(top: defaultPadding),
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
                borderRadius: const BorderRadius.all(
                  Radius.circular(defaultPadding),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Image.asset("assets/icons/dashboard.png",color: Colors.white,),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20,bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Classification",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              InkWell(
                                onTap: (){
                                  _showAddClassificationDailog();
                                },
                                child: Text(
                                  "Add Classification",
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .copyWith(color: Colors.white70),
                                ),
                              )


                            ],
                          ),
                        ),
                      ),

                      //Text(amountOfFiles)
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height*0.7,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('classification')
                          .where("neighbourId",isEqualTo:provider.boardMemberModel!.neighbourId).snapshots(),
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
                                Text("No Classifications Added")

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
                                            title: 'Delete Classification',
                                            desc: 'Are you sure you want to delete this record?',
                                            btnCancelOnPress: () {
                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
                                            },
                                            btnOkOnPress: () {
                                              FirebaseFirestore.instance.collection('classification').doc(document.reference.id).delete().then((value) =>
                                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen())));
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
                  )
                ],
              )
          ),
        ],
      ),
    );
  }
}


