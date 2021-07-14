import 'dart:html';
import 'package:accessify/components/reservation/reservation_sidebar.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:accessify/models/generate_password.dart';
import 'package:accessify/responsive.dart';
import 'package:accessify/components/access_log.dart';
import 'package:accessify/components/header.dart';
import 'package:accessify/components/reservation/reservation_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import '../../constants.dart';

class ShowReservations extends StatefulWidget {
  GlobalKey<ScaffoldState> _scaffoldKey;

  ShowReservations(this._scaffoldKey);

  @override
  _ShowReservationsState createState() => _ShowReservationsState();
}

class _ShowReservationsState extends State<ShowReservations> {
  var facilityController=TextEditingController();


  addFacility(String photo) async{
    print("rr");
    final ProgressDialog pr = ProgressDialog(context: context);
    pr.show(max: 100, msg: "Adding Facility");
    FirebaseFirestore.instance.collection('facility').add({
      'facilityName': facilityController.text,
      'image': photo,
    }).then((value) {
      pr.close();
      print("added");
      Navigator.pop(context);
    });
  }

  Future<void> _showAddFacilityDailog() async {
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
                              child: Text("Add Facility",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                              hintText: "central park",
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
                          addFacility(imageUrl);
                        },
                        child: Container(
                          height: 50,
                          color: secondaryColor,
                          alignment: Alignment.center,
                          child: Text("Add Facility",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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
            Header("Reservations",widget._scaffoldKey),
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
                              _showAddFacilityDailog();
                            },
                            icon: Icon(Icons.add),
                            label: Text("Add Facility"),
                          ),
                        ],
                      ),
                      SizedBox(height: defaultPadding),
                      ShowReservationList(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) ReservationSidebar(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: ReservationSidebar(),
                  ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
