import 'dart:html';

import 'package:accessify/components/service_list_sidebar.dart';
import 'package:accessify/models/announcement/announcement_model.dart';
import 'package:accessify/models/generate_password.dart';
import 'package:accessify/models/home/homeowner.dart';
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

class Announcements extends StatefulWidget {
  GlobalKey<ScaffoldState> _scaffoldKey;

  Announcements(this._scaffoldKey);

  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {


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

  registerAnnouncement(AnnouncmentModel model) async{
    print("rr");
    final ProgressDialog pr = ProgressDialog(context: context);
    pr.show(max: 100, msg: "Adding");
    //audience,description,information,photo,expDate;bool neverExpire
    FirebaseFirestore.instance.collection('announcement').add({
      'audience': model.audience,
      'description': model.description,
      'information': model.information,
      'photo': model.photo,
      'expDate': model.expDate,
      'neverExpire': model.neverExpire,
      'neighbourId':neighbourId,
    }).then((value) {
      pr.close();
      print("added");
      Navigator.pop(context);
    });
  }

  Future<void> _showAddAnnoucementsDailog() async {
    String imageUrl="";
    fb.UploadTask? _uploadTask;
    Uri imageUri;
    bool imageUploading=false;
    bool? neverExpire=true;
    List<bool> audience=[false,false,false];


    var expDateController=TextEditingController();
    DateTime? picked;
    DateTime? selectedDate = DateTime.now();
    final f = new DateFormat('dd-MM-yyyy');
    expDateController.text=f.format(new DateTime.now());
    final _formKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (context) {

        var desController=TextEditingController();

        var informationController=TextEditingController();

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
                firstDate: DateTime(2000),
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
                              child: Text("Add Announcement",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                                  Image.asset("assets/images/placeholder.png",height: 100,width: 100,fit: BoxFit.cover,)
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
                                  AnnouncmentModel model=new AnnouncmentModel(
                                      "",
                                      audienceLiteral,
                                      desController.text,
                                      informationController.text,
                                      imageUrl,
                                      expDateController.text,
                                      neverExpire!
                                  );
                                  registerAnnouncement(model);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header("Announcements",widget._scaffoldKey),
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
                             _showAddAnnoucementsDailog();
                            },
                            icon: Icon(Icons.add),
                            label: Text("Create"),
                          ),
                        ],
                      ),
                      SizedBox(height: defaultPadding),
                      AnnouncementList(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) ServiceListSideBar(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding), if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: ServiceListSideBar(),
                  ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
