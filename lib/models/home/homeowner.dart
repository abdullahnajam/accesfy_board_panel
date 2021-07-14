import 'package:cloud_firestore/cloud_firestore.dart';

class HomeOwnerModel{
  String id,firstName,lastName,street,building,floor,apartmentUnit,additionalAddress,phone,cellPhone,email,comment,classification;


  HomeOwnerModel(
      this.id,
      this.firstName,
      this.lastName,
      this.street,
      this.building,
      this.floor,
      this.apartmentUnit,
      this.additionalAddress,
      this.phone,
      this.cellPhone,
      this.email,
      this.comment,
      this.classification);

  HomeOwnerModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        firstName = map['firstName'],
        lastName = map['lastName'],
        street = map['street'],
        building = map['building'],
        floor = map['floor'],
        apartmentUnit = map['apartmentUnit'],
        additionalAddress = map['additionalAddress'],
        phone = map['phone'],
        cellPhone = map['cellPhone'],
        comment = map['comment'],
        classification = map['classification'],
        email = map['email'];



  HomeOwnerModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}