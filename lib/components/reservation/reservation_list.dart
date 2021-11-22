import 'package:accessify/models/access_control/access_control_model.dart';
import 'package:accessify/models/home/homeowner.dart';
import 'package:accessify/models/reservation/reservation_model.dart';
import 'package:accessify/screens/navigators/reservation_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants.dart';

class ShowReservationList extends StatefulWidget {
  const ShowReservationList({Key? key}) : super(key: key);

  @override
  _ShowReservationListState createState() => _ShowReservationListState();
}

class _ShowReservationListState extends State<ShowReservationList> {
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
            "Reservation",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reservation').where("neighbourId",isEqualTo:neighbourId).snapshots(),
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
                  child: Text("No Reservation Placed"),
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
                        label: Text("Date"),
                      ),
                      DataColumn(
                        label: Text("Facility"),
                      ),
                      DataColumn(
                        label: Text("Hours"),
                      ),
                      DataColumn(
                        label: Text("Guests"),
                      ),
                      DataColumn(
                        label: Text("Status"),
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

Future<void> _showApproveDialog(String docId,BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Reservation'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Do you want to approve this reservation.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              FirebaseFirestore.instance.collection('reservation').doc(docId).update({
                'status': "approved",
              }).then((value) {
                print("added");
                Navigator.pop(context);
              });
            },
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
Future<void> _showRejectedDialog(String docId,BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Reservation'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Do you want to reject this reservation.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              FirebaseFirestore.instance.collection('reservation').doc(docId).update({
                'status': "rejected",
              }).then((value) {
                print("added");
                Navigator.pop(context);
              });
            },
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showInfoDialog(ReservationModel model,BuildContext context) async {
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
                      FutureBuilder<DocumentSnapshot>(
                        future:  FirebaseFirestore.instance.collection('homeowner').doc(model.userId).get(),
                        builder:
                            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

                          if (snapshot.hasError) {
                            return Text("Something went wrong");
                          }

                          if (snapshot.hasData && !snapshot.data!.exists) {
                            return Text("");
                          }

                          if (snapshot.connectionState == ConnectionState.done) {
                            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                            return Text(
                              "${data['firstName']} ${data['lastName']}",
                              style: Theme.of(context).textTheme.headline6!.apply(color: Colors.black),
                            );
                          }

                          return Text("-");
                        },
                      ),
                      Text(
                        model.hourStart,
                        style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.grey[600]),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.05,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.apartment,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Facility",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.facilityName}",
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
                                "   Total Guests",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.totalGuests}",
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
                            "${model.date}",
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
                              Icon(Icons.qr_code,color: Colors.grey[600],size: 20,),
                              Text(
                                "   QR Code",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),

                            Image.network(model.qr,height: 50,width: 50,)
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
  final model = ReservationModel.fromSnapshot(data);

  return DataRow(
      onSelectChanged: (newValue) {
        print('row pressed');
        _showInfoDialog(model, context);

      },
      cells: [


    DataCell(Text(model.date)),
    DataCell(Text(model.facilityName)),
    DataCell(Text(model.hourStart)),
    DataCell(Text(model.totalGuests)),
    model.status=="pending"?DataCell(Row(
      children: [

        InkWell(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: primaryColor)
            ),
            padding: EdgeInsets.all(5),
            child: Text("Approve",style: TextStyle(color: primaryColor),),
          ),
          onTap: (){
            AwesomeDialog(
              dialogBackgroundColor: secondaryColor,
              context: context,
              width: MediaQuery.of(context).size.width*0.3,
              dialogType: DialogType.QUESTION,
              animType: AnimType.TOPSLIDE,
              title: 'Reservation Status',
              desc: 'Do you want to approve this request?',
              btnCancelOnPress: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ReservationScreen()));
              },
              btnOkOnPress: () {
                FirebaseFirestore.instance.collection('reservation').doc(model.id).update({
                  'status': "approved",
                }).then((value) {
                  print("added");
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ReservationScreen()));
                });

              },
            )..show();
            //_showApproveDialog(model.id,context);
          },
        ),
        SizedBox(width: 10,),
        InkWell(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: primaryColor)
            ),
            padding: EdgeInsets.all(5),
            child: Text("Reject",style: TextStyle(color: primaryColor),),
          ),
          onTap: (){
            AwesomeDialog(
              context: context,
              dialogBackgroundColor: secondaryColor,
              width: MediaQuery.of(context).size.width*0.3,
              dialogType: DialogType.QUESTION,
              animType: AnimType.TOPSLIDE,
              title: 'Reservation Status',
              desc: 'Do you want to reject this request?',
              btnCancelOnPress: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ReservationScreen()));
              },
              btnOkOnPress: () {
                FirebaseFirestore.instance.collection('reservation').doc(model.id).update({
                  'status': "rejected",
                }).then((value) {
                  print("added");
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ReservationScreen()));
                });

              },
            )..show();
            //_showRejectedDialog(model.id,context);
          },
        ),

      ],
    )):model.status=="approved"?
  DataCell(
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.green)
      ),
      padding: EdgeInsets.all(5),
      child: Text(model.status,style: TextStyle(color: Colors.lightGreenAccent),),
    )
  ):DataCell(
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.redAccent)
          ),
          child: Text(model.status,style: TextStyle(color: Colors.redAccent),),
        )
    ),
  ]);
}


