import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel{
  String id,date,facilityName,facilityId,totalGuests,hourStart,hourEnd,userId,dateNoFormat,qr,status;

  ReservationModel(this.id, this.date, this.facilityName, this.facilityId,
      this.totalGuests, this.hourStart, this.hourEnd,this.userId,this.dateNoFormat,this.qr,this.status);

  ReservationModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        date = map['date']??"none",
        facilityName = map['facilityName']??"none",
        hourStart = map['hourStart']??"none",
        status = map['status']??"none",
        facilityId = map['facilityId']??"none",
        hourEnd = map['hourEnd']??"none",
        userId = map['userId']??"none",
        dateNoFormat = map['dateNoFormat']??"none",
        qr = map['qr']??"none",
        totalGuests = map['totalGuests']??"none";



  ReservationModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}