import 'package:accessify/models/home/homeowner.dart';
import 'package:accessify/models/payment_model.dart';
import 'package:accessify/provider/UserDataProvider.dart';

import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:accessify/screens/navigators/payment_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
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
            "Payments",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('payment')
                .where("neighbourId",isEqualTo:provider.boardMemberModel!.neighbourId)
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
  List<DataRow> _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return  snapshot.map((data) => _buildListItem(context, data)).toList();
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
              Container(
          padding: EdgeInsets.all(10),
          child: IconButton(
            icon: Icon(Icons.edit,color: Colors.white,),
            onPressed: (){
              _showEditPaymentDialog(context, model);
            },
          ),
        ),
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


  Future<void> _showEditPaymentDialog(BuildContext context,PaymentModel model) async {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    String userId=model.userId;
    DateTime? picked;
    int expirationInMilli=model.expirationInMilli;
    DateTime? selectedDate = DateTime.now();
    DateTime? monthDate = DateTime.now();
    var addressController=TextEditingController();
    var monthController=TextEditingController();
    var yearController=TextEditingController();
    var invoiceNumberController=TextEditingController();
    var conceptController=TextEditingController();
    var interestController=TextEditingController();
    var expirationController=TextEditingController();
    var nameController=TextEditingController();
    var amountController=TextEditingController();
    final _formKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (context) {


        return StatefulBuilder(

          builder: (context, setState) {
            addressController.text=model.address;
            monthController.text=model.month;
            invoiceNumberController.text=model.invoiceNumber;
            conceptController.text=model.concept;
            interestController.text=model.interest;
            expirationController.text=model.expiration;
            nameController.text=model.name;
            amountController.text=model.amount.toString();
            _selectDate(BuildContext context) async {
              picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(), // Refer step 1
                firstDate: DateTime(2000),
                lastDate: DateTime(2025),
              );
              if (picked != null && picked != selectedDate)
                setState(() {
                  selectedDate = picked;
                  final f = new DateFormat('dd-MM-yyyy');
                  expirationInMilli=selectedDate!.millisecondsSinceEpoch;
                  expirationController.text=f.format(selectedDate!).toString();

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
                              child: Text("Edit Payment",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                                  "Resident",
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
                                                    stream: FirebaseFirestore.instance.collection('homeowner').where("neighbourId",isEqualTo:provider.boardMemberModel!.neighbourId).snapshots(),
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
                                                              Text("No homeowner Added",style: TextStyle(color: Colors.black))

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
                                                                  nameController.text="${data['firstName']} ${data['lastName']}";
                                                                  userId=document.reference.id;
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
                                    hintText: "",
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Month",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  readOnly: true,
                                  onTap: (){
                                    showMonthPicker(
                                      context: context,
                                      firstDate:  DateTime.now().subtract(Duration(days: 0)),
                                      lastDate: DateTime(DateTime.now().year + 1, 9),
                                      initialDate: monthDate ?? DateTime.now(),
                                      locale: Locale("en"),
                                    ).then((date) {
                                      if (date != null) {
                                        setState(() {
                                          monthDate = date;
                                          monthController.text=DateFormat("MMMM, yyyy").format(monthDate!);
                                        });
                                      }
                                    });
                                  },
                                  controller: monthController,
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
                                  "Concept",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  readOnly: true,
                                  onTap: (){
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
                                                    stream: FirebaseFirestore.instance.collection('concepts').where("neighbourId",isEqualTo:provider.boardMemberModel!.neighbourId).snapshots(),
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
                                                              Text("No homeowner Added",style: TextStyle(color: Colors.black))

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
                                                                  conceptController.text="${data['name']}";
                                                                  userId=document.reference.id;
                                                                });
                                                                Navigator.pop(context);
                                                              },
                                                              title: Text("${data['name']}",style: TextStyle(color: Colors.black),),
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
                                  controller: conceptController,
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
                                  "Address",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  maxLines: 3,
                                  minLines: 3,
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
                            SizedBox(height: 10,),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Invoice Number",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller:invoiceNumberController,
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
                                  "Interest",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller:interestController,
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
                                  "Amount",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  controller:amountController,
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
                                  "Expiration Date",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  readOnly: true,
                                  onTap: ()=>_selectDate(context),
                                  controller:expirationController,
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
                                  final ProgressDialog pr = ProgressDialog(context: context);
                                  pr.show(max:100,msg: "Loading");
                                  FirebaseFirestore.instance.collection('payment').doc(model.id).update({
                                    'name': nameController.text,
                                    'address': addressController.text,
                                    'month': DateFormat("MMMM").format(monthDate!),
                                    'year': DateFormat("yyyy").format(monthDate!),
                                    'invoiceNumber': invoiceNumberController.text,
                                    'concept': conceptController.text,
                                    'interest': interestController.text,
                                    'expiration': expirationController.text,
                                    'userId': userId,
                                    'amount': int.parse(amountController.text),
                                    'expirationInMilli': expirationInMilli,
                                  }).then((value) {
                                    pr.close();
                                    Navigator.pop(context);
                                  }).onError((error, stackTrace){
                                    pr.close();
                                    final snackBar = SnackBar(content: Text("Database Error"));
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  });
                                }
                              },
                              child: Container(
                                height: 50,
                                color: secondaryColor,
                                alignment: Alignment.center,
                                child: Text("Edit Payment",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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
}



