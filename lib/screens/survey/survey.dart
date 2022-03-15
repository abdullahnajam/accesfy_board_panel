import 'dart:html';

import 'package:accessify/components/survey/survey_list.dart';
import 'package:accessify/models/announcement/announcement_model.dart';
import 'package:accessify/models/generate_password.dart';
import 'package:accessify/models/survey/survey_model.dart';
import 'package:accessify/responsive.dart';
import 'package:accessify/components/announcement_list.dart';
import 'package:accessify/components/header.dart';
import 'package:accessify/components/dashboard/resident_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import '../../constants.dart';
import 'package:firebase/firebase.dart' as fb;

class Survey extends StatefulWidget {
  GlobalKey<ScaffoldState> _scaffoldKey;

  Survey(this._scaffoldKey);

  @override
  _SurveyState createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {

  String? neighbourId;

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
      }
    });

  }



  @override
  void initState() {
    getUserData();
  }




  Future<void> _showAddSurveyDialog() async {
    final _formKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (context) {

        var questionController=TextEditingController();
        int itemCount=2;
        List<TextEditingController> choiceController=[];
        bool? isAnswer=false;

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
                height: MediaQuery.of(context).size.height,
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
                              child: Text("Add Survey Question",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                                  "Question",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  maxLines: 3,
                                  minLines: 3,
                                  controller: questionController,
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

                              title: const Text('Text Answer Only',style: TextStyle(color: Colors.black),),
                              value: isAnswer,
                              onChanged: (bool? value) {
                                setState(() {
                                  isAnswer = value;
                                });
                              },
                              secondary: const Icon(Icons.timer,color: Colors.black,),
                            ),
                            SizedBox(height: defaultPadding,),

                            isAnswer!?Container():Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Options",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                ElevatedButton.icon(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: defaultPadding * 1.5,
                                      vertical:
                                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      choiceController.add(TextEditingController());
                                    });
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text("Add Options"),
                                ),
                              ],
                            ),
                            SizedBox(height: defaultPadding,),
                            isAnswer!?Container():Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7.0),
                                border: Border.all(color: primaryColor)
                              ),
                              padding: EdgeInsets.all(10),
                              height: MediaQuery.of(context).size.height*0.4,
                              child: ListView.builder(
                                
                                shrinkWrap: true,
                                //physics: NeverScrollableScrollPhysics(),
                                itemCount: choiceController.length,
                                itemBuilder: (context,index){
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child:Row(
                                      children: [
                                        Expanded(
                                          flex: 9,
                                          child: TextFormField(
                                            controller: choiceController[index],
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
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: IconButton(
                                            icon: Icon(Icons.close,color: Colors.grey,),
                                            onPressed: () {
                                              setState(() {
                                                choiceController.removeAt(index);
                                              });

                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),


                            SizedBox(height: 15,),
                            InkWell(
                              onTap: (){
                                if (_formKey.currentState!.validate()) {
                                  //this.question, this.status, this.choices, this.isMCQ, this.attempts
                                  final ProgressDialog pr = ProgressDialog(context: context);
                                  pr.show(max: 100, msg: "Adding");
                                  List<String> choices=[];
                                  for(int i=0;i<choiceController.length;i++){
                                    choices.add(choiceController[i].text);
                                  }
                                  //audience,description,information,photo,expDate;bool neverExpire
                                  FirebaseFirestore.instance.collection('survey').add({
                                    'question': questionController.text,
                                    'status': "New",
                                    'choices': choices,
                                    'isMCQ': !isAnswer!,
                                    'attempts': [],
                                    'neighbourId': neighbourId,
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
                                child: Text("Add Survey Question",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header("Survey",widget._scaffoldKey),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "",
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          ElevatedButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: defaultPadding * 1.5,
                                vertical:
                                defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                              ),
                            ),
                            onPressed: () {
                             _showAddSurveyDialog();
                            },
                            icon: Icon(Icons.add),
                            label: Text("Add Question"),
                          ),
                        ],
                      ),
                      SizedBox(height: defaultPadding),
                      SurveyList(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),

              ],
            )
          ],
        ),
      ),
    );
  }
}
