import 'package:accessify/models/home/homeowner.dart';
import 'package:accessify/models/survey/survey_model.dart';

import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../../constants.dart';

class SurveyList extends StatefulWidget {
  const SurveyList({Key? key}) : super(key: key);

  @override
  _SurveyListState createState() => _SurveyListState();
}


class _SurveyListState extends State<SurveyList> {


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
            "Questionnaire",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('survey').where("neighbourId",isEqualTo:neighbourId).snapshots(),
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
                  child: Text("No Question Added"),
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
                      label: Text("Question"),
                    ),
                    DataColumn(
                      label: Text("Attempts"),
                    ),

                    DataColumn(
                      label: Text("Status"),
                    ),

                    DataColumn(
                      label: Text("Delete"),
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




Future<void> _showInfoQuestionDailog(SurveyModel model,BuildContext context) async {
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
          height: MediaQuery.of(context).size.height*0.5,
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
                        child: Text("Question Information",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                        "${model.question}",
                        style: Theme.of(context).textTheme.headline6!.apply(color: Colors.black),
                      ),
                      model.isMCQ ?
                          ListView.separated(
                            shrinkWrap: true,
                            itemCount: model.choices.length,
                            separatorBuilder: (context, index) {
                              return Divider();
                            },
                            itemBuilder: (context,index){
                              return Padding(
                                padding: EdgeInsets.all(2),
                                child: ListTile(
                                  leading: Text("${index+1} -"),
                                  title: Text(model.choices[index],style: TextStyle(color: Colors.black)),
                                ),
                              );
                            },
                          )
                          : Container(),
                      SizedBox(height: MediaQuery.of(context).size.height*0.05,),

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

Future<void> _showAttemptsDialog(SurveyModel model,BuildContext context) async {
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
          height: MediaQuery.of(context).size.height*0.7,
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
                        child: Text("Question Attempts Information",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('attempts')
                        .where("questionId",isEqualTo:model.id).snapshots(),
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
                              Text("No Answers",style: TextStyle(color: Colors.black),)

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
                              child: Column(
                                children: [
                                  Text(data['name'],style: TextStyle(color: Colors.black),),
                                  data['isMCQ']?
                                      Container(child: Text(data['choiceSelected'],style: TextStyle(color: Colors.black)),)
                                      :Container(child:Text(data['answer'],style: TextStyle(color: Colors.black)))
                                ],
                              )
                          );
                        }).toList(),
                      );
                    },
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


Future<void> changeStatus(SurveyModel model,BuildContext context){
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
                      child: Text("Change Question Status",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                  FirebaseFirestore.instance.collection('survey').doc(model.id).update({
                    'status': "New",
                  }).then((value) => Navigator.pop(context));
                },
                title: Text("New",style: TextStyle(color: Colors.black),),
              ),
              ListTile(
                onTap: (){
                  FirebaseFirestore.instance.collection('survey').doc(model.id).update({
                    'status': "In Progress",
                  }).then((value) => Navigator.pop(context));
                },
                title: Text("In Progress",style: TextStyle(color: Colors.black)),
              ),
              ListTile(
                onTap: (){
                  FirebaseFirestore.instance.collection('survey').doc(model.id).update({
                    'status': "Closed",
                  }).then((value) => Navigator.pop(context));
                },
                title: Text("Closed",style: TextStyle(color: Colors.black)),
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
  final model = SurveyModel.fromSnapshot(data);

  return DataRow(
      onSelectChanged: (newValue) {
        print('row pressed');
        _showInfoQuestionDailog(model, context);
      },
      cells: [
    DataCell(Text("${model.question}",maxLines: 1,)),
    DataCell(Text(model.attempts),onTap: (){_showAttemptsDialog(model,context);}),
    DataCell(
        Text("${model.status}"),
        onTap: (){
          changeStatus(model, context);
        }
    ),

    DataCell(
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
                title: 'Delete Question',
                desc: 'Are you sure you want to delete this record?',
                btnCancelOnPress: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
                },
                btnOkOnPress: () {
                  FirebaseFirestore.instance.collection('survey').doc(model.id).delete().then((value) =>
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen())));
                },
              )..show();

            },
          ),
        )
    ),
  ]);
}


