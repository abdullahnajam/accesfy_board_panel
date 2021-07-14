import 'package:cloud_firestore/cloud_firestore.dart';

class AccessLogModel{
  String id,name,type,vehiclePlate,date;
  List images;

  AccessLogModel(this.id,this.name, this.type, this.vehiclePlate, this.date, this.images);

  AccessLogModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        name = map['name'],
        type = map['type'],
        vehiclePlate = map['vehiclePlate'],
        date = map['date'],
        images = map['images'];



  AccessLogModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}