import 'dart:html';
import 'package:accessify/models/generate_password.dart';
import 'package:accessify/models/home/guard_model.dart';
import 'package:accessify/models/inventory/supply_model.dart';
import 'package:accessify/models/single_item_model.dart';
import 'package:accessify/provider/UserDataProvider.dart';
import 'package:accessify/screens/navigators/inventory_screen.dart';
import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:accessify/screens/navigators/payment_screen.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../constants.dart';

class ConceptList extends StatefulWidget {
  const ConceptList({Key? key}) : super(key: key);

  @override
  _ConceptListState createState() => _ConceptListState();
}

class _ConceptListState extends State<ConceptList> {



  updateSupply(SupplyModel model,BuildContext context) async{
    final ProgressDialog pr = ProgressDialog(context: context);
    print("guard ${model.id}");
    pr.show(max: 100, msg: "Updating");
    //description,datePurchased,stock,location,assignedTo,condition,inventoryFrequency,lastInventoryDate
    FirebaseFirestore.instance.collection('inventory_supply').doc(model.id).update({
      'description': model.description,
      'datePurchased': model.datePurchased,
      'stock': model.stock,
      'location': model.location,
      'assignedTo': model.assignedTo,
      'guardId':model.guardId,
      'condition': model.condition,
      'inventoryFrequency': model.inventoryFrequency,
      'lastInventoryDate': model.lastInventoryDate,


    }).then((value) {
      pr.close();
      print("added");
      Navigator.pop(context);
    });
  }

  var _conceptController=TextEditingController();


  Future<void> _showAddConceptDialog() async {
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
                              child: Text("Add Concept",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                                  "Concept",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller: _conceptController,
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
                                final provider = Provider.of<UserDataProvider>(context, listen: false);

                                final ProgressDialog pr = ProgressDialog(context: context);
                                pr.show(max: 100, msg: "Adding");
                                FirebaseFirestore.instance.collection('concepts').add({
                                  'name': _conceptController.text,
                                  'neighbourId':provider.boardMemberModel!.neighbourId,
                                  'neighbourhood':provider.boardMemberModel!.neighbourhoodName,
                                }).then((value) {
                                  pr.close();
                                  Navigator.pop(context);
                                }).onError((error, stackTrace){
                                  pr.close();
                                });
                              },
                              child: Container(
                                height: 50,
                                color: secondaryColor,
                                alignment: Alignment.center,
                                child: Text("Add Payment Concept",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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

          SizedBox(height: defaultPadding),
          Row(
            children: [

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20,bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Concepts",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      InkWell(
                        onTap: (){
                          _showAddConceptDialog();
                        },
                        child: Text(
                          "Add Concept",
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
          SizedBox(height: defaultPadding),
          Container(
            margin: EdgeInsets.only(top: defaultPadding),
            padding: EdgeInsets.all(defaultPadding),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('concepts')
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
                        Text("No Concepts Added")

                      ],
                    ),
                  );

                }

                return new ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    SingleItemModel model=new SingleItemModel.fromMap(data,document.reference.id);
                    return new Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: InkWell(
                          child: Container(
                            child: ListTile(

                              title: Text("${model.name}",maxLines: 2,),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_forever,color: Colors.white,),
                                onPressed: (){
                                  AwesomeDialog(
                                    width: MediaQuery.of(context).size.width*0.3,
                                    context: context,
                                    dialogBackgroundColor: secondaryColor,
                                    dialogType: DialogType.QUESTION,
                                    animType: AnimType.BOTTOMSLIDE,
                                    title: 'Delete Concept',
                                    desc: 'Are you sure you want to delete this record?',
                                    btnCancelOnPress: () {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => PaymentScreen()));
                                    },
                                    btnOkOnPress: () {
                                      FirebaseFirestore.instance.collection('concepts').doc(document.reference.id).delete().then((value) =>
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => PaymentScreen())));
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
    );
  }
}


