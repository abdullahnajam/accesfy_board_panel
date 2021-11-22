import 'package:accessify/models/home/homeowner.dart';
import 'package:accessify/models/payment_model.dart';

import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:accessify/screens/navigators/payment_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../../constants.dart';

class PaymentList extends StatefulWidget {
  const PaymentList({Key? key}) : super(key: key);

  @override
  _PaymentListState createState() => _PaymentListState();
}


class _PaymentListState extends State<PaymentList> {




  @override
  Widget build(BuildContext context) {
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
            "Payments",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('payment')
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  margin: EdgeInsets.all(30),
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data!.size==0){
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(80),
                  alignment: Alignment.center,
                  child: Text("No payments generated"),
                );
              }
              print("size ${snapshot.data!.size}");
              return new SizedBox(
                width: double.infinity,
                child: DataTable2(

                    showCheckboxColumn: false,
                  columnSpacing: defaultPadding,
                  minWidth: 600,
                  columns: [
                    DataColumn(
                      label: Text("User"),
                    ),
                    DataColumn(
                      label: Text("Concept"),
                    ),

                    DataColumn(
                      label: Text("Amount"),
                    ),

                    DataColumn(
                      label: Text("Date"),
                    ),
                    DataColumn(
                      label: Text("Expiration"),
                    ),
                    DataColumn(
                      label: Text("Status"),
                    ),
                    DataColumn(
                      label: Text("Actions"),
                    ),
                  ],
                  rows: _buildList(context, snapshot.data!.docs)

                ),
              );
            },
          ),


        ],
      ),
    );
  }
}
List<DataRow> _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
  return  snapshot.map((data) => _buildListItem(context, data)).toList();
}

var emailController=TextEditingController();
var firstNameController=TextEditingController();
var lastNameController=TextEditingController();
var streetController=TextEditingController();
var buildingController=TextEditingController();
var floorController=TextEditingController();
var apartmentUnitController=TextEditingController();
var phoneController=TextEditingController();
var cellPhoneController=TextEditingController();
var classificationController=TextEditingController();
var addressController=TextEditingController();
var commentController=TextEditingController();


updateHomeOwner(String id,String? classification,BuildContext context) async{
  final ProgressDialog pr = ProgressDialog(context: context);
  pr.show(max: 100, msg: "Loading");
  FirebaseFirestore.instance.collection('homeowner').doc(id).update({
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
    'classification':classification


  }).then((value) {
    pr.close();
    print("added");
    Navigator.pop(context);
  });
}

Future<void> _showInfoDialog(PaymentModel model,BuildContext context) async {
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
          height: MediaQuery.of(context).size.height*0.8,
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
                        child: Text("Payment Information",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                        "${model.concept}",
                        style: Theme.of(context).textTheme.headline6!.apply(color: Colors.black),
                      ),
                      Text(
                        model.name,
                        style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.grey[600]),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.05,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.place,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Address",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.address}",
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
                              Icon(Icons.calendar_today,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Date",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.month} - ${model.year}",
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
                              Icon(Icons.list_alt,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Invoice Number",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.invoiceNumber}",
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
                              Icon(Icons.monetization_on,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Amount",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.amount}",
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
                              Icon(Icons.timer_off,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Expiration Date",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.expiration}",
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
                              Icon(Icons.event,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Submission Date",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.submissionDate}",
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
                              Icon(Icons.image,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Proof",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          if(model.proofUrl=='none')
                          Text(
                            "${model.proofUrl}",
                            style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.black),
                          )
                          else
                            Image.network(model.proofUrl,height: 50,width: 50,)
                        ],
                      ),

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

Future<void> _showEditHomeOwnerDailog(HomeOwnerModel model,BuildContext context,String? _classification) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final _formKey = GlobalKey<FormState>();

          emailController.text=model.email;
          firstNameController.text=model.firstName;
          lastNameController.text=model.lastName;
          streetController.text=model.street;
          buildingController.text=model.building;
          floorController.text=model.floor;
          apartmentUnitController.text=model.apartmentUnit;
          phoneController.text=model.phone;
          cellPhoneController.text=model.cellPhone;
          addressController.text=model.additionalAddress;
          commentController.text=model.comment;

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
                            child: Text("Edit Home Owner",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                                  stream: FirebaseFirestore.instance.collection('classification').snapshots(),
                                  builder: (context, snapshot){
                                    if (!snapshot.hasData)
                                      return const Center(child: const CircularProgressIndicator(),);
                                    var length = snapshot.data!.docs.length;
                                    DocumentSnapshot ds = snapshot.data!.docs[length - 1];
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

                          SizedBox(height: 15,),
                          InkWell(
                            onTap: (){
                              print("tap");
                              updateHomeOwner(model.id,_classification,context);
                            },
                            child: Container(
                              height: 50,
                              color: secondaryColor,
                              alignment: Alignment.center,
                              child: Text("Update Home Owner",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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

Future<void> changeStatus(PaymentModel model,BuildContext context){
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
          width: MediaQuery.of(context).size.width*0.3,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Text("Change Status",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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

              ListTile(
                onTap: (){
                  FirebaseFirestore.instance.collection('payment').doc(model.id).update({
                    'status': "Pending",
                  }).then((value) => Navigator.pop(context));
                },
                title: Text("Pending",style: TextStyle(color: Colors.black),),
              ),
              ListTile(
                onTap: (){
                  FirebaseFirestore.instance.collection('payment').doc(model.id).update({
                    'status': "To Authorize",
                  }).then((value) => Navigator.pop(context));
                },
                title: Text("To Authorize",style: TextStyle(color: Colors.black)),
              ),
              ListTile(
                onTap: (){
                  FirebaseFirestore.instance.collection('payment').doc(model.id).update({
                    'status': "Authorized",
                  }).then((value) => Navigator.pop(context));
                },
                title: Text("Authorized",style: TextStyle(color: Colors.black)),
              ),
              SizedBox(height: 15,),
            ],
          ),
        ),
      );
    },
  );
}
DataRow _buildListItem(BuildContext context, DocumentSnapshot data) {
  final model = PaymentModel.fromSnapshot(data);
  return DataRow(
      onSelectChanged: (newValue) {
        print('row pressed');
        _showInfoDialog(model, context);

      },
      cells: [
    DataCell(Text("${model.name}")),
    DataCell(Text(model.concept)),
    DataCell(Text(model.amount.toString())),
        DataCell(Text("${model.month} ${model.year}")),
        DataCell(Text(model.expiration)),
        DataCell(Text(model.status),onTap: (){
          changeStatus(model, context);
        }),


    DataCell(Row(
      children: [
        /*Container(
          padding: EdgeInsets.all(10),
          child: IconButton(
            icon: Icon(Icons.edit,color: Colors.white,),
            onPressed: (){

            },
          ),
        ),*/
        Container(
          padding: EdgeInsets.all(10),
          child: IconButton(
            icon: Icon(Icons.delete_forever,color: Colors.white,),
            onPressed: (){
              AwesomeDialog(
                width: MediaQuery.of(context).size.width*0.3,
                context: context,
                dialogType: DialogType.QUESTION,
                animType: AnimType.BOTTOMSLIDE,
                dialogBackgroundColor: secondaryColor,
                title: 'Delete Payment',
                desc: 'Are you sure you want to delete this record?',
                btnCancelOnPress: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => PaymentScreen()));
                },
                btnOkOnPress: () {
                  FirebaseFirestore.instance.collection('payment').doc(model.id).delete().then((value) =>
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => PaymentScreen())));
                },
              )..show();
              
            },
          ),
        )

      ],
    )),
  ]);
}


