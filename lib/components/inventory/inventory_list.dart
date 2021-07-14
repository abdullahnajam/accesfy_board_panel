import 'dart:html';
import 'dart:typed_data';

import 'package:accessify/models/home/homeowner.dart';
import 'package:accessify/models/inventory/asset_model.dart';
import 'package:accessify/screens/navigators/inventory_screen.dart';

import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../../../constants.dart';
import 'package:firebase/firebase.dart' as fb;
class InventoryList extends StatefulWidget {
  const InventoryList({Key? key}) : super(key: key);

  @override
  _InventoryListState createState() => _InventoryListState();
}


class _InventoryListState extends State<InventoryList> {

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
            "Inventory Assets",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('inventory_assets').snapshots(),
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
                  child: Text("No asset is added"),
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
                      label: Text("Serial #"),
                    ),
                    DataColumn(
                      label: Text("Description"),
                    ),

                    DataColumn(
                      label: Text("Maintenance Schedule"),
                    ),

                    DataColumn(
                      label: Text("Condition"),
                    ),
                    DataColumn(
                      label: Text("Last Scanned"),
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
    );
  }
}
List<DataRow> _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
  return  snapshot.map((data) => _buildListItem(context, data)).toList();
}

String imageUrl="";
fb.UploadTask? _uploadTask;
Uri? imageUri;
bool imageUploading=false;
var descriptionController=TextEditingController();
var serialController=TextEditingController();
var datePurchasedController=TextEditingController();
var maintenanceController=TextEditingController();
var warrantyController=TextEditingController();
var checkInOutController=TextEditingController();
var locationController=TextEditingController();
var assignedController=TextEditingController();
var lastScanDateController=TextEditingController();
String? _guardId;
String? condition;
String? inventoryFrequency;


Future<void> _showInfoHomeOwnerDailog(AssetModel model,BuildContext context) async {
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
                        child: Text("Asset Information",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                        "${model.description}",
                        maxLines: 2,
                        style: Theme.of(context).textTheme.headline6!.apply(color: Colors.black),
                      ),
                      Text(
                        model.serial,
                        style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.grey[600]),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shopping_cart_outlined,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Date Purchased",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.datePurchased}",
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
                              Icon(Icons.warning_amber_outlined,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Maintenance Schedule",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.maintenanceSchedule}",
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
                              Icon(Icons.place_outlined,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Location",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.location}",
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
                              Icon(Icons.assignment_outlined,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Warranty",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "Apartment ${model.warranty}",
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
                              Icon(Icons.logout,color: Colors.grey[600],size: 20,),
                              Text(
                                "   CheckIn\\Out",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.checkInOut}",
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
                              Icon(Icons.person,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Assigned To",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.assignedTo}",
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
                              Icon(Icons.category_outlined,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Condition",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.condition}",
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
                              Icon(Icons.add_road,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Inventory Frequency",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.inventoryFrequency}",
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
                              Icon(Icons.access_time,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Last Scan Date",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "${model.lastScanDate}",
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
                              Icon(Icons.category_outlined,color: Colors.grey[600],size: 20,),
                              Text(
                                "   Photo",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Image.network(model.photo,width: 75,height: 75,)
                        ],
                      ),
                      Divider(color: Colors.grey[300],),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.category_outlined,color: Colors.grey[600],size: 20,),
                              Text(
                                "   QR Image",
                                style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Image.network(model.qr_image,width: 75,height: 75,)
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.015,),
                      Text(
                        "Comments",
                        style: Theme.of(context).textTheme.bodyText1!.apply(color: Colors.black),
                      ),
                      Text(
                        model.comment,
                        style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.grey[600]),
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

Future<void> _showEditHomeOwnerDailog(AssetModel model,BuildContext context) async {
  descriptionController.text=model.description;
  serialController.text=model.serial;
  datePurchasedController.text=model.datePurchased;
  maintenanceController.text=model.maintenanceSchedule;
  warrantyController.text=model.warranty;
  checkInOutController.text=model.checkInOut;
  locationController.text=model.location;
  assignedController.text=model.assignedTo;
  lastScanDateController.text=model.lastScanDate;
  _guardId=model.assignedId;
  condition=model.condition;
  inventoryFrequency=model.inventoryFrequency;
  DateTime? picked;
  DateTime? inventorypicked;
  DateTime? maintenance;
  DateTime? checkInOut;

  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final _formKey = GlobalKey<FormState>();
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
          _selectDate(BuildContext context) async {
            picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), // Refer step 1
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
            );
            if (picked != null && picked != DateTime.now())
              setState(() {
                final f = new DateFormat('dd-MM-yyyy');
                datePurchasedController.text=f.format(picked!).toString();

              });
          }
          _selectInventoryDate(BuildContext context) async {
            inventorypicked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), // Refer step 1
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
            );
            if (inventorypicked != null && inventorypicked != DateTime.now())
              setState(() {
                final f = new DateFormat('dd-MM-yyyy');
                lastScanDateController.text=f.format(inventorypicked!).toString();

              });
          }
          _selectMaintenanceDate(BuildContext context) async {
            maintenance = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), // Refer step 1
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
            );
            if (maintenance != null && maintenance != DateTime.now())
              setState(() {
                final f = new DateFormat('dd-MM-yyyy');
                maintenanceController.text=f.format(maintenance!).toString();

              });
          }
          _selectCheckDate(BuildContext context) async {
            checkInOut = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), // Refer step 1
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
            );
            if (checkInOut != null && checkInOut != DateTime.now())
              setState(() {
                final f = new DateFormat('dd-MM-yyyy');
                checkInOutController.text=f.format(checkInOut!).toString();

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
              child:  Form(
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
                            child: Text("Update Asset",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                                "Serial",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                controller:serialController,
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
                                controller: descriptionController,
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
                                "Date Purchased",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                readOnly: true,
                                onTap: ()=>_selectDate(context),
                                controller:datePurchasedController,
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
                                "Location",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                controller:locationController,
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
                                "Warranty",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                controller:warrantyController,
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
                                "Condition",
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
                                  value: condition,
                                  elevation: 16,
                                  isExpanded:true,
                                  style: const TextStyle(color: Colors.black),
                                  underline: Container(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      condition = newValue!;
                                    });
                                  },
                                  items: <String>['New', 'Plenty', 'Few', 'Empty','Damaged']
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
                                "Inventory Frequency",
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
                                  value: inventoryFrequency,
                                  elevation: 16,
                                  isExpanded:true,
                                  style: const TextStyle(color: Colors.black),
                                  underline: Container(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      inventoryFrequency = newValue!;
                                    });
                                  },
                                  items: <String>['Weekly', 'Monthly', 'Quarterly', 'Annual']
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
                                "Assigned To",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                readOnly: true,
                                onTap: (){
                                  print("show guards");
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
                                                  stream: FirebaseFirestore.instance.collection('guard').snapshots(),
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
                                                                assignedController.text="${data['firstName']} ${data['lastName']}";
                                                                _guardId=document.reference.id;
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

                                },
                                controller:assignedController,
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
                                "Last Scan Date",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                readOnly: true,
                                onTap: ()=>_selectInventoryDate(context),
                                controller:lastScanDateController,
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
                                "Maintenance Schedule",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                readOnly: true,
                                onTap: ()=>_selectMaintenanceDate(context),
                                controller:maintenanceController,
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
                                "Check In\\Out",
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: secondaryColor),
                              ),
                              TextFormField(
                                readOnly: true,
                                onTap: ()=>_selectCheckDate(context),
                                controller:checkInOutController,
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
                                ):imageUrl=="im"?
                                Image.asset("assets/images/placeholder.png",height: 80,width: 80,fit: BoxFit.cover,)
                                    :Image.network(imageUrl,height: 80,width: 80,fit: BoxFit.cover,),
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
                                  child: Text("Add Photo ID",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
                                ),
                              )
                            ],
                          ),

                          SizedBox(height: 15,),
                          GestureDetector(
                            onTap: (){
                              print("ov");
                              if (_formKey.currentState!.validate()) {
                                final ProgressDialog pr = ProgressDialog(context: context);
                                pr.show(max: 100, msg: "Adding");
                                FirebaseFirestore.instance.collection('inventory_assets').doc(model.id).update({
                                  'serial': serialController.text,
                                  'description': descriptionController.text,
                                  'datePurchased': datePurchasedController.text,
                                  'warranty': warrantyController.text,
                                  'location': locationController.text,
                                  'assignedTo': assignedController.text,
                                  'maintenanceSchedule' : maintenanceController.text,
                                  'checkInOut' : checkInOutController.text,
                                  'photo' : imageUrl,
                                  'assignedId': _guardId,
                                  'condition': condition,
                                  'inventoryFrequency': inventoryFrequency,
                                  'lastScanDate': lastScanDateController.text,


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
                              child: Text("Update Asset",style: Theme.of(context).textTheme.button!.apply(color: Colors.white),),
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
  final model = AssetModel.fromSnapshot(data);
  return DataRow(
      onSelectChanged: (newValue) {
        print('row pressed');
        _showInfoHomeOwnerDailog(model, context);
      },
      cells: [
    DataCell(Text("${model.serial}")),
    DataCell(Text(model.description,maxLines: 2,)),
    DataCell(Text(model.maintenanceSchedule)),
        DataCell(Text(model.condition)),
        DataCell(Text(model.lastScanDate)),

    DataCell(Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          child: IconButton(
            icon: Icon(Icons.edit,color: Colors.white,),
            onPressed: (){
              _showEditHomeOwnerDailog(model, context);
            },
          ),
        ),
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
                title: 'Delete Asset',
                desc: 'Are you sure you want to delete this record?',
                btnCancelOnPress: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => InventoryScreen()));
                },
                btnOkOnPress: () {
                  FirebaseFirestore.instance.collection('inventory_assets').doc(model.id).delete().then((value) =>
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => InventoryScreen())));
                },
              )..show();
              
            },
          ),
        )

      ],
    )),
  ]);
}


