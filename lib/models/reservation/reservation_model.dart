import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel{
  String id,date,facilityName,facilityId,totalGuests,hourStart,hourEnd,userId,dateNoFormat,qr,status;

  ReservationModel(this.id, this.date, this.facilityName, this.facilityId,
      this.totalGuests, this.hourStart, this.hourEnd,this.userId,this.dateNoFormat,this.qr,this.status);

  ReservationModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        date = map['date'],
        facilityName = map['facilityName'],
        hourStart = map['hourStart'],
        status = map['status'],
        facilityId = map['facilityId'],
        hourEnd = map['hourEnd'],
        userId = map['userId'],
        dateNoFormat = map['dateNoFormat'],
        qr = map['qr'],
        totalGuests = map['totalGuests'];



  ReservationModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}