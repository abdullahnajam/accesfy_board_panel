import 'package:cloud_firestore/cloud_firestore.dart';

class SingleItemModel{
  String id,neighbourId,neighbourhood,name;


  SingleItemModel(this.id, this.neighbourId, this.neighbourhood, this.name);

  SingleItemModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        neighbourId = map['neighbourId']??"none",
        neighbourhood = map['neighbourhood']??"none",
        name = map['name']??"none";



  SingleItemModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}