import 'package:accessify/models/home/homeowner.dart';
import 'package:accessify/provider/UserDataProvider.dart';

import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../../constants.dart';
import '../../responsive.dart';

class ResidentList extends StatefulWidget {
  const ResidentList({Key? key}) : super(key: key);

  @override
  _ResidentListState createState() => _ResidentListState();
}


class _ResidentListState extends State<ResidentList> {

  


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
            "Home Owners",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('homeowner')
                .where("neighbourId",isEqualTo:provider.boardMemberModel!.neighbourId).snapshots(),
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
                  child: Text("No Home Owner is registered"),
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
                      label: Text("Name"),
                    ),
                    DataColumn(
                      label: Text("Email"),
                    ),

                    DataColumn(
                      label: Text("Phone"),
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

Future<void> _showInfoHomeOwnerDailog(HomeOwnerModel model,BuildContext context) async {
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
                        child: Text("Home Owner Information",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                        "${model.firstName} ${model.lastName}",
                        style: Theme.of(context).textTheme.headline6!.apply(color: Colors.black),
                      ),
                      Text(
                        model.email,
                        style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.grey[600]),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.streetview,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Street",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "Street ${model.street}",
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
                              Icon(Icons.apartment,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Building",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "Building ${model.building}",
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
                              Icon(Icons.elevator,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Floor",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "Floor ${model.street}",
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
                              Icon(Icons.home_work_outlined,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Apartment Unit",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "Apartment ${model.street}",
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
                              Icon(Icons.password,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Password",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.password}",
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
                              Icon(Icons.phone,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Phone",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.phone}",
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
                              Icon(Icons.phone_android,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Cell Phone",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.cellPhone}",
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
                              Icon(Icons.category_outlined,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Classification",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.classification}",
                            style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                      Text(
                        "Additional Address Information",
                        style: Theme.of(context).textTheme.bodyText1!.apply(color: Colors.black),
                      ),
                      Text(
                        model.additionalAddress,
                        style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.grey[600]),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.015,),
                      Text(
                        "Comments",
                        style: Theme.of(context).textTheme.bodyText1!.apply(color: Colors.black),
                      ),
                      Text(
                        model.comment,
                        style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.grey[600]),
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
  final provider = Provider.of<UserDataProvider>(context, listen: false);

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
                                  stream: FirebaseFirestore.instance.collection('classification').where("neighbourId",isEqualTo:provider.boardMemberModel!.neighbourId).snapshots(),
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

DataRow _buildListItem(BuildContext context, DocumentSnapshot data) {
  final model = HomeOwnerModel.fromSnapshot(data);
  var color=Colors.blue;
  if(model.status=="Active"){
    color=Colors.green;
  }
  else if(model.status=="Inactive"){
    color=Colors.red;
  }
  else{

  }
  return DataRow(
      onSelectChanged: (newValue) {
        print('row pressed');
        _showInfoHomeOwnerDailog(model, context);
      },
      cells: [
        DataCell(Text("${model.firstName} ${model.lastName}")),
        DataCell(Text(model.email)),
        DataCell(Text(model.phone)),
        DataCell(
          Container(
            alignment: Alignment.center,
            color: color,
            margin: EdgeInsets.only(bottom: 5,top: 5),
            child: Text(model.status),
          ),

          onTap: (){
            _showChangeStatusDialog(model, context);
          }
        ),
        DataCell(Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          child: IconButton(
            icon: Icon(Icons.edit,color: Colors.white,),
            onPressed: (){
              String? _classification=model.classification;
              _showEditHomeOwnerDailog(model, context,_classification);
            },
          ),
        ),

      ],
    )),
  ]);
}
Future<void> _showChangeStatusDialog(HomeOwnerModel model,BuildContext context) async {
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
              height: MediaQuery.of(context).size.height*0.3,
              width: MediaQuery.of(context).size.width*0.5,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: ListView(
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
                  SizedBox(height: 10,),
                  ListTile(
                    onTap: (){
                      var width;
                      if(Responsive.isMobile(context)){
                        width=MediaQuery.of(context).size.width*0.8;
                      }
                      else if(Responsive.isTablet(context)){
                        width=MediaQuery.of(context).size.width*0.6;
                      }
                      else if(Responsive.isDesktop(context)){
                        width=MediaQuery.of(context).size.width*0.3;
                      }
                      AwesomeDialog(
                        width: width,
                        context: context,
                        dialogType: DialogType.QUESTION,
                        animType: AnimType.BOTTOMSLIDE,
                        dialogBackgroundColor: secondaryColor,
                        title: 'Change Status',
                        desc: 'Are you sure you want to change status?',
                        btnCancelOnPress: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
                        },
                        btnOkOnPress: () {
                          FirebaseFirestore.instance.collection('homeowner').doc(model.id).update({
                            'status':"Active"
                          }).then((value) {
                            Navigator.pop(context);
                          }).onError((error, stackTrace) {
                            var width;
                            if(Responsive.isMobile(context)){
                              width=MediaQuery.of(context).size.width*0.8;
                            }
                            else if(Responsive.isTablet(context)){
                              width=MediaQuery.of(context).size.width*0.6;
                            }
                            else if(Responsive.isDesktop(context)){
                              width=MediaQuery.of(context).size.width*0.3;
                            }
                            AwesomeDialog(
                              width: width,
                              context: context,
                              dialogType: DialogType.ERROR,
                              animType: AnimType.BOTTOMSLIDE,
                              dialogBackgroundColor: secondaryColor,
                              title: 'Error : Unable to change status',
                              desc: '${error.toString()}',

                              btnOkOnPress: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen()));

                              },
                            )..show();
                          });
                        },
                      )..show();

                    },
                    title: Text("Active",style: TextStyle(color: Colors.black),),
                  ),
                  Divider(color: Colors.grey,),
                  ListTile(
                    onTap: (){
                      var width;
                      if(Responsive.isMobile(context)){
                        width=MediaQuery.of(context).size.width*0.8;
                      }
                      else if(Responsive.isTablet(context)){
                        width=MediaQuery.of(context).size.width*0.6;
                      }
                      else if(Responsive.isDesktop(context)){
                        width=MediaQuery.of(context).size.width*0.3;
                      }
                      AwesomeDialog(
                        width: width,
                        context: context,
                        dialogType: DialogType.QUESTION,
                        animType: AnimType.BOTTOMSLIDE,
                        dialogBackgroundColor: secondaryColor,
                        title: 'Change Status',
                        desc: 'Are you sure you want to change status?',
                        btnCancelOnPress: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
                        },
                        btnOkOnPress: () {
                          FirebaseFirestore.instance.collection('homeowner').doc(model.id).update({
                            'status':"Inactive"
                          }).then((value) {
                            Navigator.pop(context);
                          }).onError((error, stackTrace) {
                            var width;
                            if(Responsive.isMobile(context)){
                              width=MediaQuery.of(context).size.width*0.8;
                            }
                            else if(Responsive.isTablet(context)){
                              width=MediaQuery.of(context).size.width*0.6;
                            }
                            else if(Responsive.isDesktop(context)){
                              width=MediaQuery.of(context).size.width*0.3;
                            }
                            AwesomeDialog(
                              width: width,
                              context: context,
                              dialogType: DialogType.ERROR,
                              animType: AnimType.BOTTOMSLIDE,
                              dialogBackgroundColor: secondaryColor,
                              title: 'Error : Unable to change status',
                              desc: '${error.toString()}',

                              btnOkOnPress: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen()));

                              },
                            )..show();
                          });
                        },
                      )..show();

                    },
                    title: Text("Inactive",style: TextStyle(color: Colors.black),),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


