import 'dart:html';
import 'package:accessify/components/facility/facility_list.dart';
import 'package:accessify/components/facility/facility_sidebar.dart';
import 'package:accessify/components/reservation/reservation_sidebar.dart';
import 'package:accessify/provider/UserDataProvider.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:accessify/models/generate_password.dart';
import 'package:accessify/responsive.dart';
import 'package:accessify/components/access_log.dart';
import 'package:accessify/components/header.dart';
import 'package:accessify/components/reservation/reservation_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import '../../constants.dart';

class ShowFacilities extends StatefulWidget {
  GlobalKey<ScaffoldState> _scaffoldKey;

  ShowFacilities(this._scaffoldKey);

  @override
  _ShowFacilitiesState createState() => _ShowFacilitiesState();
}

class _ShowFacilitiesState extends State<ShowFacilities> {
  var facilityController=TextEditingController();
  var _statusController=TextEditingController();
  var _desController=TextEditingController();
  var _feeController=TextEditingController();
  var _capacityController=TextEditingController();
  var _observationController=TextEditingController();
  var _managerController=TextEditingController();
  var _maintenanceDateController=TextEditingController();
  String neighbour="",neighbourId="";
  String _managerType="Guard";
  String _maxUsage="1";
  List<CheckListModel> accessories=[];
  /*String id,facilityName,facilityId,status,description,fee,capacity,maxUsage,observation;
  List accessories;
  bool validationCheckList;
  String managedBy,managerId,managerName;
  String maintenanceDate;*/

  var _accessoryController=TextEditingController();




  Future<void> _showAddAccessoryDialog() async {
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
                              child: Text("Add Accessory",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                            "Name",
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                          ),
                          TextFormField(
                            controller: _accessoryController,
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
                          print("rr");
                          final ProgressDialog pr = ProgressDialog(context: context);
                          pr.show(max: 100, msg: "Adding Accessory");
                          FirebaseFirestore.instance.collection('accessories').add({
                            'name': _accessoryController.text,
                            'image': imageUrl,
                            'neighbourId':neighbourId,
                            'neighbourhood':neighbour,
                          }).then((value) {
                            pr.close();
                            print("added");
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          height: 50,
                          color: secondaryColor,
                          alignment: Alignment.center,
                          child: Text("Add Accessory",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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




  Future<void> _showAddFacilityDailog() async {
    DateTime? picked;
    String imageUrl="";
    bool? _validation=false;
    String _managerId="";
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
            /*uploadToFirebase(File imageFile) async {
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
            }*/
            _selectDate(BuildContext context) async {
              picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(), // Refer step 1
                firstDate: DateTime.now(),
                lastDate: DateTime(2025),
              );
              if (picked != null)
                setState(() {
                  final f = new DateFormat('dd-MM-yyyy');
                  _maintenanceDateController.text=f.format(picked!).toString();

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
                width: MediaQuery.of(context).size.width*0.5,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
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
                            "Description",
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                          ),
                          TextFormField(
                            controller: _desController,
                            maxLines: 3,
                            minLines: 3,
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
                            "Fee",
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                          ),
                          TextFormField(
                            controller: _feeController,
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
                            "Capacity",
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                          ),
                          TextFormField(
                            controller: _capacityController,
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
                            "Status",
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                          ),
                          TextFormField(
                            controller: _statusController,
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
                            "Max Usage (Hours)",
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.0),
                              border: Border.all(
                                  color: primaryColor,
                                  width: 0.5
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: _maxUsage,
                              elevation: 16,
                              isExpanded:true,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _maxUsage = newValue!;
                                });
                              },
                              items: <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17'
                                , '18', '19', '20', '21', '22', '23', '24']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
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
                            "Managed By",
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.0),
                              border: Border.all(
                                  color: primaryColor,
                                  width: 0.5
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: _managerType,
                              elevation: 16,
                              isExpanded:true,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _managerType = newValue!;
                                });
                              },
                              items: <String>['Guard', 'Board Member']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
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
                            "Manager",
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                          ),
                          TextFormField(
                            readOnly: true,
                            onTap: (){
                              if(_managerType=="Guard"){
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
                                                stream: FirebaseFirestore.instance.collection('guard')
                                                    .where("neighbourId",isEqualTo:neighbourId).snapshots(),
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
                                                          Text("No Guards Added",style: TextStyle(color: Colors.black))

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
                                                              _managerController.text="${data['firstName']} ${data['lastName']}";
                                                              _managerId=document.reference.id;
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
                              }
                              else{
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
                                                stream: FirebaseFirestore.instance.collection('boardmember')
                                                    .where("neighbourId",isEqualTo:neighbourId).snapshots(),
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
                                                          Text("No Member Added",style: TextStyle(color: Colors.black))

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
                                                              _managerController.text="${data['firstName']} ${data['lastName']}";
                                                              _managerId=document.reference.id;
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
                              }
                            },
                            controller: _managerController,
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
                            "Maintenance",
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                          ),
                          TextFormField(
                            onTap: (){
                              _selectDate(context);
                            },
                            readOnly: true,
                            controller: _maintenanceDateController,
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

                        title: const Text('Required Validation Checklist',style: TextStyle(color: Colors.black),),
                        value: _validation,
                        onChanged: (bool? value) {
                          setState(() {
                            _validation = value;
                          });
                        },
                        secondary: const Icon(Icons.fact_check_outlined,color: Colors.black,),
                      ),
                      SizedBox(height: 10,),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Observation",
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                          ),
                          TextFormField(
                            controller: _observationController,
                            maxLines: 3,
                            minLines: 3,
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
                      Container(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: accessories.length,
                          itemBuilder: (context,int i){
                            return Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: CheckboxListTile(
                                  title: Text(accessories[i].accessory,style: TextStyle(color: Colors.black),),
                                  value: accessories[i].check,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      accessories[i].check = value!;
                                    });
                                  },
                                )
                            );
                          },
                        ),
                      ),
                      /*SizedBox(height: 10,),
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
                      ),*/

                      SizedBox(height: 15,),
                      InkWell(
                        onTap: (){
                          print("rr");
                          /*String id,facilityName,facilityId,status,description,fee,capacity,maxUsage,observation;
  List accessories;
  bool validationCheckList;
  String managedBy,managerId,managerName;
  String maintenanceDate;
  String neighbourId,neighbourhood;*/

                          final ProgressDialog pr = ProgressDialog(context: context);
                          pr.show(max: 100, msg: "Adding Facility");
                          List accessoriesId=[];
                          for(int i=0;i<accessories.length;i++){
                            if(accessories[i].check)
                              accessoriesId.add(accessories[i].accessory);
                          }
                          String id="fid${facilityController.text[0]}${DateTime.now().millisecondsSinceEpoch}";
                          FirebaseFirestore.instance.collection('facility').doc(id).set({
                            'facilityName': facilityController.text,
                            'status': _statusController.text,
                            'description': _desController.text,
                            'fee': _feeController.text,
                            'capacity': _capacityController.text,
                            'observation': _observationController.text,
                            'managerName': _managerController.text,
                            'maintenanceDate': _maintenanceDateController.text,
                            'maxUsage': _maxUsage,
                            'accessories': accessoriesId,
                            'validationCheckList': _validation,
                            'managedBy': _managerType,
                            'managerId': _managerId,
                            'facilityId':id,
                            'neighbourId':neighbourId,
                            'neighbourhood':neighbour,
                          }).then((value) {
                            pr.close();
                            print("added");
                            Navigator.pop(context);
                          });
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
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header("Facilities",widget._scaffoldKey),
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
                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: defaultPadding * 1.5,
                                    vertical:
                                    defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                                  ),
                                ),
                                onPressed: () async{
                                  final ProgressDialog pr = ProgressDialog(context: context);
                                  pr.show(max: 100, msg: "Please wait");

                                  await FirebaseFirestore.instance
                                      .collection('accessories')
                                      .where("neighbourId",isEqualTo:provider.boardMemberModel!.neighbourId)
                                      .get()
                                      .then((QuerySnapshot querySnapshot) {
                                    querySnapshot.docs.forEach((doc) {
                                      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                                      setState(() {
                                        CheckListModel model=new CheckListModel(data["name"],false);
                                        accessories.add(model);
                                      });
                                    });
                                  });

                                  setState(() {
                                    neighbour=provider.boardMemberModel!.neighbourhoodName;
                                    neighbourId=provider.boardMemberModel!.neighbourId;

                                  });
                                  pr.close();
                                  _showAddFacilityDailog();
                                },
                                icon: Icon(Icons.add),
                                label: Text("Add Facility"),
                              ),
                              SizedBox(width: 10,),
                              ElevatedButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: defaultPadding * 1.5,
                                    vertical:
                                    defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                                  ),
                                ),
                                onPressed: () async{
                                  setState(() {
                                    neighbour=provider.boardMemberModel!.neighbourhoodName;
                                    neighbourId=provider.boardMemberModel!.neighbourId;

                                  });
                                  _showAddAccessoryDialog();
                                },
                                icon: Icon(Icons.add),
                                label: Text("Add Accessory"),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: defaultPadding),
                      FacilityList(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) AccessoriesSidebar(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: AccessoriesSidebar(),
                  ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
class CheckListModel{
  String accessory;bool check;

  CheckListModel(this.accessory, this.check);
}