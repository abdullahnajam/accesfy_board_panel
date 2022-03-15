import 'dart:html';
import 'package:accessify/models/generate_password.dart';
import 'package:accessify/models/home/guard_model.dart';
import 'package:accessify/models/inventory/supply_model.dart';
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

class InventorySidebar extends StatefulWidget {
  const InventorySidebar({Key? key}) : super(key: key);

  @override
  _InventorySidebarState createState() => _InventorySidebarState();
}

class _InventorySidebarState extends State<InventorySidebar> {
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

  var descriptionController=TextEditingController();
  var datePurchasedController=TextEditingController();
  var stockController=TextEditingController();
  var locationController=TextEditingController();
  var assignController=TextEditingController();
  var lastInventoryDateController=TextEditingController();
  String? condition;

  String? inventoryFrequency;
  DateTime? picked;
  DateTime? inventorypicked;
  String? _guardId;
  Future<void> _showEditSupplyDailog(SupplyModel model) async {
    condition=model.condition;
    inventoryFrequency=model.inventoryFrequency;
    lastInventoryDateController.text=model.lastInventoryDate;
    _guardId=model.guardId;

    _selectDate(BuildContext context) async {
      picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), // Refer step 1
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
      );
      if (picked != null && picked != DateTime.now())
        setState(() {
          final f = new DateFormat('dd-MM-yyyy');
          datePurchasedController.text=f.format(picked!).toString();

        });
    }
    _selectInventoryDate(BuildContext context) async {
      inventorypicked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), // Refer step 1
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
      );
      if (inventorypicked != null && inventorypicked != DateTime.now())
        setState(() {
          final f = new DateFormat('dd-MM-yyyy');
          lastInventoryDateController.text=f.format(inventorypicked!).toString();

        });
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final _formKey = GlobalKey<FormState>();
            descriptionController.text=model.description;
            datePurchasedController.text=model.datePurchased;
            stockController.text=model.stock;
            locationController.text=model.location;
            assignController.text=model.assignedTo;

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
                              child: Text("Edit Supply",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                                  "Description",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller: descriptionController,
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
                                  "Date Purchased",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  readOnly: true,
                                  onTap: ()=>_selectDate(context),
                                  controller:datePurchasedController,
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
                                  "Location",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller:locationController,
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
                                  "Stock",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller:stockController,
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
                                  "Condition",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7.0),
                                    border: Border.all(
                                        color: primaryColor,
                                        width: 0.5
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: condition,
                                    elevation: 16,
                                    isExpanded:true,
                                    style: const TextStyle(color: Colors.black),
                                    underline: Container(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        condition = newValue!;
                                      });
                                    },
                                    items: <String>['New', 'Plenty', 'Few', 'Empty','Damaged']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
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
                                  "Inventory Frequency",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7.0),
                                    border: Border.all(
                                        color: primaryColor,
                                        width: 0.5
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: inventoryFrequency,
                                    elevation: 16,
                                    isExpanded:true,
                                    style: const TextStyle(color: Colors.black),
                                    underline: Container(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        inventoryFrequency = newValue!;
                                      });
                                    },
                                    items: <String>['Weekly', 'Monthly', 'Quarterly', 'Annual']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
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
                                  "Assigned To",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  readOnly: true,
                                  onTap: (){
                                    print("show guards");
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context){
                                          return StatefulBuilder(
                                            builder: (context,setState){
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
                                                  width: MediaQuery.of(context).size.width*0.3,
                                                  child: StreamBuilder<QuerySnapshot>(
                                                    stream: FirebaseFirestore.instance.collection('guard').where("neighbourId",isEqualTo:neighbourId).snapshots(),
                                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                      if (snapshot.hasError) {
                                                        return Center(
                                                          child: Column(
                                                            children: [
                                                              Image.asset("assets/images/wrong.png",width: 150,height: 150,),
                                                              Text("Something Went Wrong",style: TextStyle(color: Colors.black))

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
                                                              Image.asset("assets/images/empty.png",width: 150,height: 150,),
                                                              Text("No Guards Added",style: TextStyle(color: Colors.black))

                                                            ],
                                                          ),
                                                        );

                                                      }

                                                      return new ListView(
                                                        shrinkWrap: true,
                                                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                                                          return new Padding(
                                                            padding: const EdgeInsets.only(top: 15.0),
                                                            child: ListTile(
                                                              onTap: (){
                                                                setState(() {
                                                                  assignController.text="${data['firstName']} ${data['lastName']}";
                                                                  _guardId=document.reference.id;
                                                                });
                                                                Navigator.pop(context);
                                                              },
                                                              title: Text("${data['firstName']} ${data['lastName']}",style: TextStyle(color: Colors.black),),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                    );

                                  },
                                  controller:assignController,
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
                                  "Last Inventory Date",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  readOnly: true,
                                  onTap: ()=>_selectInventoryDate(context),
                                  controller:lastInventoryDateController,
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
                                  print("${assignController.text} controller");
                                  print("guard $_guardId");
                                  final ProgressDialog pr = ProgressDialog(context: context);
                                  print("guard ${model.id}");
                                  pr.show(max: 100, msg: "Updating");
                                  //description,datePurchased,stock,location,assignedTo,condition,inventoryFrequency,lastInventoryDate
                                  FirebaseFirestore.instance.collection('inventory_supply').doc(model.id).update({
                                    'description': descriptionController.text,
                                    'datePurchased': datePurchasedController.text,
                                    'stock': stockController.text,
                                    'location': locationController.text,
                                    'assignedTo': assignController.text,
                                    'guardId': _guardId,
                                    'condition': condition,
                                    'inventoryFrequency': inventoryFrequency,
                                    'lastInventoryDate': lastInventoryDateController.text

                                  }).then((value) {
                                    pr.close();
                                    print("added");
                                    Navigator.pop(context);
                                  });
                                }
                              },
                              child: Container(
                                height: 50,
                                color: secondaryColor,
                                alignment: Alignment.center,
                                child: Text("Update Supply",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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
  Future<void> _showInfoSupplyDailog(SupplyModel model,BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
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
            height: MediaQuery.of(context).size.height*0.6,
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
                          child: Text("Supply Information",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                        Text(
                          "${model.description}",
                          style: Theme.of(context).textTheme.headline6!.apply(color: Colors.black),
                        ),

                        SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.timer,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Date Purchased",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.datePurchased}",
                              style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.black),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey[300],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.place,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Location",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.location}",
                              style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.black),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey[300],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.apps,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Stock",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.stock}",
                              style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.black),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey[300],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Assigned To",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.assignedTo}",
                              style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.black),
                            ),
                          ],
                        ),

                        Divider(color: Colors.grey[300],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.fact_check_outlined,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Condition",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.condition}",
                              style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.black),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey[300],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.add_road,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Inventory Frequency",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.inventoryFrequency}",
                              style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.black),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey[300],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.hourglass_bottom,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Last Inventory Date",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.lastInventoryDate}",
                              style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.black),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey[300],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Edit",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: (){
                                Navigator.pop(context);
                                _showEditSupplyDailog(model);
                              },
                              child: Container(
                                child: Text("Edit",style: TextStyle(color: primaryColor),),
                              ),
                            )
                          ],
                        ),
                        Divider(color: Colors.grey[300],),

                        


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
            "Supplies",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          Container(
            margin: EdgeInsets.only(top: defaultPadding),
            padding: EdgeInsets.all(defaultPadding),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('inventory_supply')
                  .where("neighbourId",isEqualTo:neighbourId).snapshots(),
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
                        Text("No Supplies Added")

                      ],
                    ),
                  );

                }

                return new ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    SupplyModel model=new SupplyModel(
                      document.reference.id,
                      data['description'],
                      data['datePurchased'],
                      data['stock'],
                      data['location'],
                      data['assignedTo'],
                        data['guardId'],
                        data['comment'],
                      data['condition'],
                      data['inventoryFrequency'],
                      data['lastInventoryDate']
                    );
                    return new Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: InkWell(
                          child: Container(
                            child: ListTile(
                              onTap: ()=>_showInfoSupplyDailog(model, context),
                              title: Text("${model.description}",maxLines: 2,),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_forever,color: Colors.white,),
                                onPressed: (){
                                  AwesomeDialog(
                                    width: MediaQuery.of(context).size.width*0.3,
                                    context: context,
                                    dialogBackgroundColor: secondaryColor,
                                    dialogType: DialogType.QUESTION,
                                    animType: AnimType.BOTTOMSLIDE,
                                    title: 'Delete Supply',
                                    desc: 'Are you sure you want to delete this record?',
                                    btnCancelOnPress: () {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => InventoryScreen()));
                                    },
                                    btnOkOnPress: () {
                                      FirebaseFirestore.instance.collection('inventory_supply').doc(document.reference.id).delete().then((value) =>
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => InventoryScreen())));
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


