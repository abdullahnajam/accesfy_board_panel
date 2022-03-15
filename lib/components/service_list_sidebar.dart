import 'dart:html';
import 'package:accessify/models/board_member_model.dart';
import 'package:accessify/models/generate_password.dart';
import 'package:accessify/models/home/guard_model.dart';
import 'package:accessify/provider/UserDataProvider.dart';
import 'package:accessify/screens/navigators/annoucement_screen.dart';
import 'package:accessify/screens/navigators/incident_screen.dart';
import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:accessify/screens/navigators/reservation_screen.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../constants.dart';

class ServiceListSideBar extends StatefulWidget {
  const ServiceListSideBar({Key? key}) : super(key: key);

  @override
  _ServiceListSideBarState createState() => _ServiceListSideBarState();
}

class _ServiceListSideBarState extends State<ServiceListSideBar> {

  var serviceController=TextEditingController();


  addService(String photo,BoardMemberModel model) async{
    print("rr");
    final ProgressDialog pr = ProgressDialog(context: context);
    pr.show(max: 100, msg: "Adding Service");
    FirebaseFirestore.instance.collection('services').add({
      'name': serviceController.text,
      'image': photo,
      'neighbourId':model.neighbourId,
      'neighbourhood':model.neighbourhoodName,
    }).then((value) {
      pr.close();
      print("added");
      Navigator.pop(context);
    });
  }

  Future<void> _showAddServiceDailog() async {
    String imageUrl="";
    fb.UploadTask? _uploadTask;
    Uri imageUri;
    bool imageUploading=false;
    final _formKey = GlobalKey<FormState>();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context,setState){
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
                //imageUrl= "https://firebasestorage.googleapis.com/v0/b/accesfy-882e6.appspot.com/o/bookingPics%2F1622649147001?alt=media&token=45a4483c-2f29-48ab-bcf1-813fd8fa304b";
                print(imageUrl);
              });

            }

            /// A "select file/folder" window will appear. User will have to choose a file.
            /// This file will be then read, and uploaded to firebase storage;
            uploadImage() async {
              // HTML input element
              FileUploadInputElement uploadInput = FileUploadInputElement();
              uploadInput.click();

              uploadInput.onChange.listen(
                    (changeEvent) {
                  final file = uploadInput.files!.first;
                  final reader = FileReader();
                  // The FileReader object lets web applications asynchronously read the
                  // contents of files (or raw data buffers) stored on the user's computer,
                  // using File or Blob objects to specify the file or data to read.
                  // Source: https://developer.mozilla.org/en-US/docs/Web/API/FileReader

                  reader.readAsDataUrl(file);
                  // The readAsDataURL method is used to read the contents of the specified Blob or File.
                  //  When the read operation is finished, the readyState becomes DONE, and the loadend is
                  // triggered. At that time, the result attribute contains the data as a data: URL representing
                  // the file's data as a base64 encoded string.
                  // Source: https://developer.mozilla.org/en-US/docs/Web/API/FileReader/readAsDataURL

                  reader.onLoadEnd.listen(
                    // After file finiesh reading and loading, it will be uploaded to firebase storage
                        (loadEndEvent) async {
                      uploadToFirebase(file);
                    },
                  );
                },
              );
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
                width: MediaQuery.of(context).size.width*0.5,
                padding: EdgeInsets.all(20),
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
                              child: Text("Add Service",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Service Name",
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                          ),
                          TextFormField(
                            controller: serviceController,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 100,
                            width: 150,
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
                            Image.asset("assets/images/placeholder.png",height: 100,width: 150,fit: BoxFit.cover,)
                                :Image.network(imageUrl,height: 100,width: 150,fit: BoxFit.cover,),
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
                              child: Text("Add Image",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 15,),
                      InkWell(
                        onTap: (){
                          print("tap");
                          final provider = Provider.of<UserDataProvider>(context, listen: false);
                          addService(imageUrl,provider.boardMemberModel!);
                        },
                        child: Container(
                          height: 50,
                          color: secondaryColor,
                          alignment: Alignment.center,
                          child: Text("Add Service",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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
            "Services List",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          InkWell(
            onTap: (){
              _showAddServiceDailog();
            },
            child: Text(
              "Add Services List",
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Colors.white70),
            ),
          ),
          SizedBox(height: defaultPadding),
          Container(
              margin: EdgeInsets.only(top: defaultPadding),
              padding: EdgeInsets.all(defaultPadding),
              child: Container(
                height: MediaQuery.of(context).size.height*0.2,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('services').where("neighbourId",isEqualTo:provider.boardMemberModel!.neighbourId).snapshots(),
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
                            Text("No Service Added")

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
                            child: InkWell(
                              child: Container(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(data['image']),
                                    backgroundColor: Colors.indigoAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  title: Text(data['name']),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete_forever,color: Colors.white,),
                                    onPressed: (){
                                      AwesomeDialog(
                                        dialogBackgroundColor: secondaryColor,
                                        width: MediaQuery.of(context).size.width*0.3,
                                        context: context,
                                        dialogType: DialogType.QUESTION,
                                        animType: AnimType.BOTTOMSLIDE,
                                        title: 'Delete Service',
                                        desc: 'Are you sure you want to delete this record?',
                                        btnCancelOnPress: () {
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AnnouncementScreen()));
                                        },
                                        btnOkOnPress: () {
                                          FirebaseFirestore.instance.collection('services').doc(document.reference.id).delete().then((value) =>
                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AnnouncementScreen())));
                                        },
                                      )..show();
                                    },
                                  ),

                                ),
                              ),
                            )
                        );
                      }).toList(),
                    );
                  },
                ),
              )
          ),
        ],
      ),
    );
  }
}


