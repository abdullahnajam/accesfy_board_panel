import 'package:cloud_firestore/cloud_firestore.dart';

class GuardModel{
  String id,firstName,lastName,photoId,companyName,phone,supervisor,email,password,status;

  GuardModel(this.id, this.firstName, this.lastName, this.photoId,
      this.companyName, this.phone, this.supervisor, this.email,this.password,this.status);

  GuardModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        firstName = map['firstName'],
        lastName = map['lastName'],
        photoId = map['photoId'],
        companyName = map['companyName'],
        phone = map['phone'],
        supervisor = map['supervisor'],
        password = map['password'],
        status = map['status'],
        email = map['email'];



  GuardModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}