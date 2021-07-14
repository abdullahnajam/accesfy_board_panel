import 'package:accessify/models/access_control/access_control_model.dart';
import 'package:accessify/models/home/homeowner.dart';
import 'package:accessify/models/reservation/reservation_model.dart';
import 'package:accessify/screens/navigators/reservation_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants.dart';

class ShowReservationList extends StatefulWidget {
  const ShowReservationList({Key? key}) : super(key: key);

  @override
  _ShowReservationListState createState() => _ShowReservationListState();
}

class _ShowReservationListState extends State<ShowReservationList> {

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
            "Reservation",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reservation').snapshots(),
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
    );
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


DataRow _buildListItem(BuildContext context, DocumentSnapshot data) {
  final model = ReservationModel.fromSnapshot(data);

  return DataRow(cells: [

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


