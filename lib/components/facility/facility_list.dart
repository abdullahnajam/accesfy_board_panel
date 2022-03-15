import 'package:accessify/models/access_control/access_control_model.dart';
import 'package:accessify/models/facility/facility_model.dart';
import 'package:accessify/models/home/homeowner.dart';
import 'package:accessify/models/reservation/reservation_model.dart';
import 'package:accessify/screens/navigators/facility_screen.dart';
import 'package:accessify/screens/navigators/reservation_screen.dart';
import 'package:accessify/screens/reservation/facility.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import '../../../constants.dart';

class FacilityList extends StatefulWidget {
  const FacilityList({Key? key}) : super(key: key);

  @override
  _FacilityListState createState() => _FacilityListState();
}

class _FacilityListState extends State<FacilityList> {
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
            "Facilities",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('facility').where("neighbourId",isEqualTo:neighbourId).snapshots(),
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
                  child: Text("No Facilities"),
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
                        label: Text("Manager"),
                      ),
                      DataColumn(
                        label: Text("Capacity"),
                      ),
                      DataColumn(
                        label: Text("Fees"),
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
    ):Center(child: CircularProgressIndicator(),);
  }
}
List<DataRow> _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
  return  snapshot.map((data) => _buildListItem(context, data)).toList();
}
String neighbour="",neighbourId="";
var facilityController=TextEditingController();
var _statusController=TextEditingController();
var _desController=TextEditingController();
var _feeController=TextEditingController();
var _capacityController=TextEditingController();
var _observationController=TextEditingController();
var _managerController=TextEditingController();
var _maintenanceDateController=TextEditingController();

List<CheckListModel> accessories=[];
Future<void> _showUpdateDialog(FacilityModel model,BuildContext context) async {
  String _managerType=model.managedBy;
  String _maxUsage=model.maxUsage;
  String _managerId=model.managerId;
  bool? _validation=model.validationCheckList;
  DateTime? picked;
  DateTime? selectedDate = DateTime.now();

  facilityController.text=model.facilityName;
  _statusController.text=model.status;
  _desController.text=model.description;
  _feeController.text=model.fee;
  _capacityController.text=model.capacity;
  _observationController.text=model.observation;
  _managerController.text=model.managerName;
  _maintenanceDateController.text=model.maintenanceDate;
  final _formKey = GlobalKey<FormState>();
  return showDialog(
    context: context,
    builder: (context) {



      return StatefulBuilder(
        builder: (context, setState) {
          _selectDate(BuildContext context) async {
            picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), // Refer step 1
              firstDate: DateTime.now(),
              lastDate: DateTime(2025),
            );
            if (picked != null && picked != selectedDate)
              setState(() {
                selectedDate = picked;
                final f = new DateFormat('dd-MM-yyyy');
                _maintenanceDateController.text=f.format(selectedDate!).toString();

              });
          }

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
                            child: Text("Update",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                                "Facility Name",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                controller: facilityController,
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
                                "Description",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                controller: _desController,
                                maxLines: 3,
                                minLines: 3,
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
                                "Fee",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                controller: _feeController,
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
                                "Capacity",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                controller: _capacityController,
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
                                "Status",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                controller: _statusController,
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
                                "Max Usage (Hours)",
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
                                  value: _maxUsage,
                                  elevation: 16,
                                  isExpanded:true,
                                  style: const TextStyle(color: Colors.black),
                                  underline: Container(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _maxUsage = newValue!;
                                    });
                                  },
                                  items: <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17'
                                    , '18', '19', '20', '21', '22', '23', '24']
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
                                "Managed By",
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
                                  value: _managerType,
                                  elevation: 16,
                                  isExpanded:true,
                                  style: const TextStyle(color: Colors.black),
                                  underline: Container(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _managerType = newValue!;
                                    });
                                  },
                                  items: <String>['Guard', 'Board Member']
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
                                "Manager",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                readOnly: true,
                                onTap: (){
                                  if(_managerType=="Guard"){
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
                                                    stream: FirebaseFirestore.instance.collection('guard')
                                                        .where("neighbourId",isEqualTo:neighbourId).snapshots(),
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
                                                                  _managerController.text="${data['firstName']} ${data['lastName']}";
                                                                  _managerId=document.reference.id;
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
                                  }
                                  else{
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
                                                    stream: FirebaseFirestore.instance.collection('boardmember')
                                                        .where("neighbourId",isEqualTo:neighbourId).snapshots(),
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
                                                              Text("No Member Added",style: TextStyle(color: Colors.black))

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
                                                                  _managerController.text="${data['firstName']} ${data['lastName']}";
                                                                  _managerId=document.reference.id;
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
                                  }
                                },
                                controller: _managerController,
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
                                "Maintenance",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                onTap: (){
                                  _selectDate(context);
                                },
                                readOnly: true,
                                controller: _maintenanceDateController,
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

                          CheckboxListTile(

                            title: const Text('Required Validation Checklist',style: TextStyle(color: Colors.black),),
                            value: _validation,
                            onChanged: (bool? value) {
                              setState(() {
                                _validation = value;
                              });
                            },
                            secondary: const Icon(Icons.fact_check_outlined,color: Colors.black,),
                          ),
                          SizedBox(height: 10,),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Observation",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                controller: _observationController,
                                maxLines: 3,
                                minLines: 3,
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
                          Container(
                            height: 200,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: accessories.length,
                              itemBuilder: (context,int i){
                                return Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: CheckboxListTile(
                                      title: Text(accessories[i].accessory,style: TextStyle(color: Colors.black),),
                                      value: accessories[i].check,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          accessories[i].check = value!;
                                        });
                                      },
                                    )
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 15,),
                          InkWell(
                            onTap: (){
                              if (_formKey.currentState!.validate()) {
                                print("rr");
                                final ProgressDialog pr = ProgressDialog(context: context);
                                pr.show(max: 100, msg: "Updating");
                                List accessoriesId=[];
                                for(int i=0;i<accessories.length;i++){
                                  if(accessories[i].check)
                                    accessoriesId.add(accessories[i].accessory);
                                }
                                //audience,description,information,photo,expDate;bool neverExpire
                                FirebaseFirestore.instance.collection('facility').doc(model.id).update({
                                  'facilityName': facilityController.text,
                                  'status': _statusController.text,
                                  'description': _desController.text,
                                  'fee': _feeController.text,
                                  'capacity': _capacityController.text,
                                  'observation': _observationController.text,
                                  'managerName': _managerController.text,
                                  'maintenanceDate': _maintenanceDateController.text,
                                  'maxUsage': _maxUsage,
                                  'accessories': accessoriesId,
                                  'validationCheckList': _validation,
                                  'managedBy': _managerType,
                                  'managerId': _managerId,
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
                              child: Text("Update",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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
Future<void> _showInfoDialog(FacilityModel model,BuildContext context) async {
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
                        child: Text("Reservation Information",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                        model.facilityName,
                        style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.grey[600]),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.05,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.assignment,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Description",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.description}",
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
                              Icon(Icons.people,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Capacity",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.capacity}",
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
                                "   Fee",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.fee}",
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
                              Icon(Icons.timer,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Max usage time",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),

                          Text(
                            "${model.maxUsage}",
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
                                "   Manager",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),

                          Text(
                            "${model.managerName}",
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
                                "   Manager Type",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),

                          Text(
                            "${model.managedBy}",
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
                                "   Maintenance Date",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),

                          Text(
                            "${model.maintenanceDate}",
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
                                "   Observation",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),

                          Text(
                            "${model.observation}",
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
                                "   Required Validation Check List",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),

                          Text(
                            "${model.validationCheckList}",
                            style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.black),
                          ),
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
DataRow _buildListItem(BuildContext context, DocumentSnapshot data) {
  final model = FacilityModel.fromSnapshot(data);

  return DataRow(
      onSelectChanged: (newValue) {
        print('row pressed');
        _showInfoDialog(model, context);

      },
      cells: [



    DataCell(Text(model.facilityName)),
        DataCell(Text(model.managerName)),
    DataCell(Text(model.capacity)),
    DataCell(Text(model.fee)),
    DataCell(Text(model.status)),
        DataCell(Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: IconButton(
                icon: Icon(Icons.edit,color: Colors.white,),
                onPressed: (){

                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: IconButton(
                icon: Icon(Icons.delete_forever,color: Colors.white,),
                onPressed: (){
                  AwesomeDialog(
                    dialogBackgroundColor: secondaryColor,
                    width: MediaQuery.of(context).size.width*0.3,
                    context: context,
                    dialogType: DialogType.QUESTION,
                    animType: AnimType.BOTTOMSLIDE,
                    title: 'Delete Facility',
                    desc: 'Are you sure you want to delete this record?',
                    btnCancelOnPress: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => FacilityScreen()));
                    },
                    btnOkOnPress: () {
                      FirebaseFirestore.instance.collection('facility').doc(model.id).delete().then((value) =>
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => FacilityScreen())));
                    },
                  )..show();

                },
              ),
            )

          ],
        )),

  ]);
}


