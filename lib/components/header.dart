import 'package:accessify/controllers/MenuController.dart';
import 'package:accessify/models/board_member_model.dart';
import 'package:accessify/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class Header extends StatelessWidget {
  String title;GlobalKey<ScaffoldState> _scaffoldKey;


  Header(this.title,this._scaffoldKey);
  Future<void> _showInfoDialog(BoardMemberModel model,BuildContext context) async {
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
            height: MediaQuery.of(context).size.height*0.5,
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
                          child: Text("Board Member Information",textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline5!.apply(color: secondaryColor),),
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
                          "${model.firstName} ${model.lastName}",
                          style: Theme.of(context).textTheme.headline6!.apply(color: Colors.black),
                        ),
                        Text(
                          model.email,
                          style: Theme.of(context).textTheme.bodyText2!.apply(color: Colors.grey[600]),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.phone,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Phone",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.phone}",
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
                                Icon(Icons.home,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Neighbourhood",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.neighbourhoodName}",
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
                                Icon(Icons.app_registration,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Position",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.position}",
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
                                Icon(Icons.list_alt_sharp,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Status",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.status}",
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
                                Icon(Icons.assignment,color: Colors.grey[600],size: 20,),
                                Text(
                                  "   Comments",
                                  style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Text(
                              "${model.comment}",
                              style: Theme.of(context).textTheme.subtitle2!.apply(color: Colors.black),
                            ),
                          ],
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
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu,color: Colors.white,),
            onPressed: (){
              if (!_scaffoldKey.currentState!.isDrawerOpen) {
                _scaffoldKey.currentState!.openDrawer();
              }
            },
          ),
        if (!Responsive.isMobile(context))
          Text(
            title,
            style: Theme.of(context).textTheme.headline4!.apply(color: Colors.white),
          ),
        FutureBuilder<DocumentSnapshot>(
          future:  FirebaseFirestore.instance.collection('boardmember').doc(FirebaseAuth.instance.currentUser!.uid).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return Text("");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
              return InkWell(
                  onTap: (){
                    print("admin id ${snapshot.data!.reference.id}");
                    _showInfoDialog(BoardMemberModel.fromMap(data, snapshot.data!.reference.id), context);
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,

                        decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(data['neighbourLogo'])
                            )
                        ),
                      ),
                      SizedBox(width: defaultPadding,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${data['firstName']} ${data['lastName']}",
                            style: Theme.of(context).textTheme.headline6!.apply(color: Colors.white),
                          ),
                          Text(
                            data['neighbourhoodName'],
                            style: Theme.of(context).textTheme.bodyText1!.apply(color: Colors.white),
                          ),
                        ],
                      )

                    ],
                  )
              );
            }

            return Text("-");
          },
        )
      ],
    );
  }
}

