import 'package:accessify/models/coupons_model.dart';
import 'package:accessify/models/home/homeowner.dart';
import 'package:accessify/models/incident/incident_model.dart';
import 'package:accessify/screens/navigators/incident_screen.dart';
import 'package:accessify/screens/navigators/marketplace_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../constants.dart';

class MarketPlaceList extends StatefulWidget {
  const MarketPlaceList({Key? key}) : super(key: key);

  @override
  _MarketPlaceListState createState() => _MarketPlaceListState();
}

class _MarketPlaceListState extends State<MarketPlaceList> {
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
            "Marketplace Coupons",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('coupons')
                .where("neighbourId",isEqualTo:neighbourId).snapshots(),
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
                  child: Text("No coupons found"),
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
                        label: Text("Title"),
                      ),
                      DataColumn(
                        label: Text("Description"),
                      ),
                      DataColumn(
                        label: Text("Price"),
                      ),
                      DataColumn(
                        label: Text("Classification"),
                      ),
                      DataColumn(
                        label: Text("Photo"),
                      ),
                      DataColumn(
                        label: Text("Phone"),
                      ),
                      DataColumn(
                        label: Text("Status"),
                      ),
                      DataColumn(
                        label: Text("Expiry Date"),
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


Future<void> _showApproveDialog(String docId,BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Incident/Complain/Suggestion'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Do you want to approve this coupon?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              FirebaseFirestore.instance.collection('coupons').doc(docId).update({
                'status': "Approved",
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
  final model = CouponsModel.fromSnapshot(data);
  return DataRow(cells: [
      DataCell(Text(model.title)),
    DataCell(Text(model.description,maxLines: 1,)),
    DataCell(Text(model.price)),
    DataCell(Text(model.classification)),
    DataCell(Image.network(model.image,width: 50,height: 50,)),
    DataCell(Text(model.phone)),
    model.status=="Pending"?DataCell(InkWell(
      onTap: (){
        print("tap");
        AwesomeDialog(
          context: context,
          width: MediaQuery.of(context).size.width*0.3,
          dialogType: DialogType.QUESTION,
          animType: AnimType.TOPSLIDE,
          title: 'Coupon Status',
          dialogBackgroundColor: secondaryColor,
          desc: 'Do you want this to approve this?',
          btnOkOnPress: () {
            FirebaseFirestore.instance.collection('coupons').doc(model.id).update({
              'status': "Approved",
            }).then((value) {
              print("added");
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => IncidentScreen()));
            });

          },
          btnCancelOnPress: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => IncidentScreen()));
          }
        )..show();
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: primaryColor)
        ),
        alignment: Alignment.center,
        child: Text("Approve",maxLines: 1,style: TextStyle(fontSize: 13,color: primaryColor),),
      ),
    )):DataCell(Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.green)
      ),
      padding: EdgeInsets.all(5),
      child: Text(model.status,style: TextStyle(color: Colors.lightGreenAccent),),
    )),
    DataCell(Text(model.expiration)),
    DataCell(IconButton(
      icon: Icon(Icons.delete_forever,color: Colors.white,),
      onPressed: (){
        AwesomeDialog(
          dialogBackgroundColor: secondaryColor,
          width: MediaQuery.of(context).size.width*0.3,
          context: context,
          dialogType: DialogType.QUESTION,
          animType: AnimType.BOTTOMSLIDE,
          title: 'Delete Coupon',
          desc: 'Are you sure you want to delete this coupon?',
          btnCancelOnPress: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MarketPlaceScreen()));
          },
          btnOkOnPress: () {
            FirebaseFirestore.instance.collection('coupons').doc(model.id).delete().then((value) =>
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MarketPlaceScreen())));
          },
        )..show();

      },
    ),),
  ]);
}

