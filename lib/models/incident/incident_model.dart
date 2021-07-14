import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentModel{
  String id,description,classification,time,title,type,photo,status;

  IncidentModel(this.id, this.description,this.classification, this.time, this.title,
      this.type, this.photo, this.status);

  IncidentModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        description = map['description'],
        classification = map['classification'],
        time = map['time'],
        title = map['title'],
        type = map['type'],
        photo = map['photo'],
        status = map['status'];



  IncidentModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}