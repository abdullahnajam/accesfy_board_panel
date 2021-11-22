import 'package:accessify/controllers/MenuController.dart';
import 'package:accessify/responsive.dart';
import 'package:accessify/screens/access_control/access_control_queue.dart';
import 'package:accessify/screens/dashboard/resident.dart';
import 'package:accessify/screens/guards/guards.dart';
import 'package:accessify/screens/payment/payment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'drawer/side_menu.dart';

class PaymentScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: context.read<MenuController>().scaffoldKey,
      drawer: SideMenu(),
      key: _scaffoldKey,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: Payment(_scaffoldKey),
            ),
          ],
        ),
      ),
    );
  }
}
