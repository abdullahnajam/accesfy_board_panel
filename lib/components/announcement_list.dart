import 'dart:html';

import 'package:accessify/models/announcement/announcement_model.dart';
import 'package:accessify/models/home/homeowner.dart';
import 'package:accessify/models/incident/incident_model.dart';
import 'package:accessify/screens/navigators/annoucement_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../constants.dart';

class AnnouncementList extends StatefulWidget {
  const AnnouncementList({Key? key}) : super(key: key);

  @override
  _AnnouncementListState createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
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
            "Announcements",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('announcement').where("neighbourId",isEqualTo:neighbourId).snapshots(),
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
                  child: Text("No announcements are made"),
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
                        label: Text("Audience"),
                      ),
                      DataColumn(
                        label: Text("Information"),
                      ),
                      DataColumn(
                        label: Text("Description"),
                      ),
                      DataColumn(
                        label: Text("Photo"),
                      ),
                      DataColumn(
                        label: Text("Expire Date"),
                      ),
                      DataColumn(
                        label: Text("Never Expire"),
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

updateAnnouncement(AnnouncmentModel model,BuildContext context) async{
  print("rr");
  final ProgressDialog pr = ProgressDialog(context: context);
  pr.show(max: 100, msg: "Updating");
  //audience,description,information,photo,expDate;bool neverExpire
  FirebaseFirestore.instance.collection('announcement').doc(model.id).update({
    'audience': model.audience,
    'description': model.description,
    'information': model.information,
    'photo': model.photo,
    'expDate': model.expDate,
    'neverExpire': model.neverExpire,
  }).then((value) {
    pr.close();
    print("added");
    Navigator.pop(context);
  });
}

Future<void> _showUpdateAnnoucementsDailog(AnnouncmentModel model,BuildContext context) async {
  String imageUrl="";
  fb.UploadTask? _uploadTask;
  Uri imageUri;
  bool? neverExpire=model.neverExpire;
  List<bool> audience=[false,false,false];
  if(model.audience=="Residents")
    audience[0]=true;
  if(model.audience=="Guard")
    audience[1]=true;
  if(model.audience=="Both")
    audience[1]=true;
  bool imageUploading=false;
  DateTime? picked;
  DateTime? selectedDate = DateTime.now();
  var expDateController=TextEditingController();
  expDateController.text=model.expDate;
  var desController=TextEditingController();
  desController.text=model.description;
  var informationController=TextEditingController();
  informationController.text=model.information;
  final _formKey = GlobalKey<FormState>();
  return showDialog(
    context: context,
    builder: (context) {



      return StatefulBuilder(
        builder: (context, setState) {

          uploadToFirebase(File imageFile) async {
            final filePath = 'images/${DateTime.now()}.png';
            print("put");
            setState((){
              imageUploading=true;
              _uploadTask = fb.storage().refFromURL('gs://accesfy-882e6.appspot.com').child(filePath).put(imageFile);
            });

            fb.UploadTaskSnapshot taskSnapshot = await _uploadTask!.future;
            imageUri = await taskSnapshot.ref.getDownloadURL();
            setState((){
              print("heer");
              imageUrl=imageUri.toString();
              imageUploading=false;
              print(imageUrl);
            });

          }
          uploadImage() async {
            // HTML input element
            FileUploadInputElement uploadInput = FileUploadInputElement();
            uploadInput.click();

            uploadInput.onChange.listen(
                  (changeEvent) {
                final file = uploadInput.files!.first;
                final reader = FileReader();
                reader.readAsDataUrl(file);
                reader.onLoadEnd.listen(
                      (loadEndEvent) async {
                    uploadToFirebase(file);
                  },
                );
              },
            );
          }
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
                expDateController.text=f.format(selectedDate!).toString();

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
                            child: Text("Update Announcement",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                                maxLines: 3,
                                minLines: 3,
                                controller: desController,
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
                                "Information",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                minLines: 3,
                                maxLines: 3,
                                controller: informationController,
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
                                "Audience",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap:(){
                                      setState(() {
                                        audience[0]=true;
                                        audience[1]=false;
                                        audience[2]=false;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: audience[0]?primaryColor:Colors.grey)
                                      ),
                                      padding: EdgeInsets.all(5),
                                      child: Text("Residents",style: TextStyle(color: audience[0]?primaryColor:Colors.grey),),
                                    ),
                                  ),
                                  InkWell(
                                    onTap:(){
                                      setState(() {
                                        audience[0]=false;
                                        audience[1]=true;
                                        audience[2]=false;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: audience[1]?primaryColor:Colors.grey)
                                      ),
                                      padding: EdgeInsets.all(5),
                                      child: Text("Guards",style: TextStyle(color: audience[1]?primaryColor:Colors.grey),),
                                    ),
                                  ),
                                  InkWell(
                                    onTap:(){
                                      setState(() {
                                        audience[0]=false;
                                        audience[1]=false;
                                        audience[2]=true;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: audience[2]?primaryColor:Colors.grey)
                                      ),
                                      padding: EdgeInsets.all(5),
                                      child: Text("Both",style: TextStyle(color: audience[2]?primaryColor:Colors.grey),),
                                    ),
                                  ),

                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 10,),
                          CheckboxListTile(

                            title: const Text('Never Expire',style: TextStyle(color: Colors.black),),
                            value: neverExpire,
                            onChanged: (bool? value) {
                              setState(() {
                                neverExpire = value;
                              });
                            },
                            secondary: const Icon(Icons.timer,color: Colors.black,),
                          ),

                          AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            height: neverExpire!?0:100,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10,),
                                Text(
                                  "Expiry Date",
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                                ),
                                TextFormField(
                                  readOnly: true,
                                  onTap: ()=>_selectDate(context),
                                  controller:expDateController,
                                  style: TextStyle(color: Colors.black),
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
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 200,
                                width: 250,
                                child: imageUploading?Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Uploading",style: TextStyle(color: primaryColor),),
                                      SizedBox(width: 10,),
                                      CircularProgressIndicator()
                                    ],),
                                ):imageUrl==""?
                                Image.network(model.photo,height: 100,width: 100,fit: BoxFit.cover,)
                                    :Image.network(imageUrl,height: 100,width: 100,fit: BoxFit.cover,),
                              ),

                              InkWell(
                                onTap: (){
                                  uploadImage();
                                },
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width*0.15,
                                  color: secondaryColor,
                                  alignment: Alignment.center,
                                  child: Text("Add Photo",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
                                ),
                              )
                            ],
                          ),

                          SizedBox(height: 15,),
                          InkWell(
                            onTap: (){
                              if (_formKey.currentState!.validate()) {
                                String audienceLiteral;
                                if(audience[0])
                                  audienceLiteral="Residents";
                                else if(audience[1])
                                  audienceLiteral="Guard";
                                else if(audience[2])
                                  audienceLiteral="Both";
                                else
                                  audienceLiteral="Both";
                                AnnouncmentModel newModel=new AnnouncmentModel(
                                    model.id,
                                    audienceLiteral,
                                    desController.text,
                                    informationController.text,
                                    imageUrl,
                                    expDateController.text,
                                    neverExpire!
                                );
                                updateAnnouncement(newModel,context);
                              }
                            },
                            child: Container(
                              height: 50,
                              color: secondaryColor,
                              alignment: Alignment.center,
                              child: Text("Add Announcement",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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
  final model = AnnouncmentModel.fromSnapshot(data);

  return DataRow(cells: [
    DataCell(Text(model.audience)),
    DataCell(Text(model.information)),
    DataCell(Text(model.description)),
    DataCell(Image.network(model.photo,width: 50,height: 50,)),
    DataCell(Text(model.expDate)),
    DataCell(Text(model.neverExpire.toString())),
    DataCell(Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          child: IconButton(
            icon: Icon(Icons.edit,color: Colors.white,),
            onPressed: (){
              _showUpdateAnnoucementsDailog(model,context);
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
                title: 'Delete Announcement',
                desc: 'Are you sure you want to delete this record?',
                btnCancelOnPress: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AnnouncementScreen()));
                },
                btnOkOnPress: () {
                  FirebaseFirestore.instance.collection('announcement').doc(model.id).delete().then((value) =>
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AnnouncementScreen())));
                },
              )..show();

            },
          ),
        )

      ],
    )),

  ]);
}

