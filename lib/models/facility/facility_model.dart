import 'package:cloud_firestore/cloud_firestore.dart';

class FacilityModel{
  String id,facilityName,facilityId,status,description,fee,capacity,maxUsage,observation;
  List accessories;
  bool validationCheckList;
  String managedBy,managerId,managerName;
  String maintenanceDate;
  String neighbourId,neighbourhood;


  FacilityModel(this.id, this.facilityName, this.facilityId, this.status,
      this.description, this.fee, this.capacity, this.maxUsage,
      this.observation, this.accessories, this.validationCheckList,
      this.managedBy, this.managerId, this.managerName, this.maintenanceDate,this.neighbourId,this.neighbourhood);

  FacilityModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        description = map['description']??"none",
        facilityName = map['facilityName']??"none",
        fee = map['fee']??"none",
        status = map['status']??"none",
        facilityId = map['facilityId']??"none",
        capacity = map['capacity']??"none",
        maxUsage = map['maxUsage']??"none",
        observation = map['observation']??"none",
        managerId = map['managerId']??"none",
        accessories = map['accessories']??"none",
        managerName = map['managerName']??"none",
        neighbourId = map['neighbourId']??"none",
        neighbourhood = map['neighbourhood']??"none",
        maintenanceDate = map['maintenanceDate']??"none",
        validationCheckList = map['validationCheckList']??false,
        managedBy = map['managedBy']??"none";



  FacilityModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}