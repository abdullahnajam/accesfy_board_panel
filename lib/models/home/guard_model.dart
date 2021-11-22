import 'package:cloud_firestore/cloud_firestore.dart';

class GuardModel{
  String id,firstName,lastName,photoId,companyName,phone,supervisor,email,password;

  GuardModel(this.id, this.firstName, this.lastName, this.photoId,
      this.companyName, this.phone, this.supervisor, this.email,this.password);

  GuardModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        firstName = map['firstName'],
        lastName = map['lastName'],
        photoId = map['photoId'],
        companyName = map['companyName'],
        phone = map['phone'],
        supervisor = map['supervisor'],
        password = map['password'],
        email = map['email'];



  GuardModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}