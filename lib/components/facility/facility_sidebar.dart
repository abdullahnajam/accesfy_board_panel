import 'dart:html';
import 'package:accessify/models/generate_password.dart';
import 'package:accessify/models/home/guard_model.dart';
import 'package:accessify/provider/UserDataProvider.dart';
import 'package:accessify/screens/navigators/incident_screen.dart';
import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:accessify/screens/navigators/reservation_screen.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../constants.dart';

class AccessoriesSidebar extends StatefulWidget {
  const AccessoriesSidebar({Key? key}) : super(key: key);

  @override
  _AccessoriesSidebarState createState() => _AccessoriesSidebarState();
}

class _AccessoriesSidebarState extends State<AccessoriesSidebar> {


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
            "Accessories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: defaultPadding),
          Container(
              margin: EdgeInsets.only(top: defaultPadding),
              padding: EdgeInsets.all(defaultPadding),
              child: Container(
                height: MediaQuery.of(context).size.height*0.7,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('accessories')
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
                            Text("No Accessories Added")

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
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(data['image']),
                                    backgroundColor: Colors.indigoAccent,
                                    foregroundColor: Colors.white,
                                  ),
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
                                        title: 'Delete Accessory',
                                        desc: 'Are you sure you want to delete this record?',
                                        btnCancelOnPress: () {
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ReservationScreen()));
                                        },
                                        btnOkOnPress: () {
                                          FirebaseFirestore.instance.collection('accessories').doc(document.reference.id).delete().then((value) =>
                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ReservationScreen())));
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
          ),
        ],
      ),
    );
  }
}


