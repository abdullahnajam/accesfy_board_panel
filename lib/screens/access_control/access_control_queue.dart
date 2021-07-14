import 'package:accessify/models/generate_password.dart';
import 'package:accessify/responsive.dart';
import 'package:accessify/components/access_log.dart';
import 'package:accessify/components/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import '../../constants.dart';

class AccessControl extends StatefulWidget {
  GlobalKey<ScaffoldState> _scaffoldKey;

  AccessControl(this._scaffoldKey);

  @override
  _AccessControlState createState() => _AccessControlState();
}

class _AccessControlState extends State<AccessControl> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header("Access Control",widget._scaffoldKey),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      SizedBox(height: defaultPadding),
                      AccessLog(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),

              ],
            )
          ],
        ),
      ),
    );
  }
}
