import 'package:accessify/constants.dart';
import 'package:accessify/screens/access_control/access_control_queue.dart';
import 'package:accessify/screens/dashboard/resident.dart';
import 'package:accessify/screens/navigators/access_screen.dart';
import 'package:accessify/screens/navigators/annoucement_screen.dart';
import 'package:accessify/screens/navigators/guard_screen.dart';
import 'package:accessify/screens/navigators/incident_screen.dart';
import 'package:accessify/screens/navigators/inventory_screen.dart';
import 'package:accessify/screens/navigators/main_screen.dart';
import 'package:accessify/screens/navigators/marketplace_screen.dart';
import 'package:accessify/screens/navigators/payment_screen.dart';
import 'package:accessify/screens/navigators/reservation_screen.dart';
import 'package:accessify/screens/navigators/survey_screen.dart';
import 'package:accessify/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(

      child: Container(
        color: bgColor,
        child:ListView(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future:  FirebaseFirestore.instance.collection('boardmember').doc(FirebaseAuth.instance.currentUser!.uid).get(),
              builder:
                  (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }

                if (snapshot.hasData && !snapshot.data!.exists) {
                  return DrawerHeader(
                    child: Image.asset("assets/images/logo.png"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                  return DrawerHeader(
                    child: Image.network(data['neighbourLogo']),
                  );
                }

                return DrawerHeader(
                  child: Image.asset("assets/images/logo.png"),
                );
              },
            ),
            DrawerListTile(
              title: "Residents",
              svgSrc: "assets/icons/dashboard.png",
              press: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen()));

              },
            ),

            DrawerListTile(
              title: "Guards",
              svgSrc: "assets/icons/guard.png",
              press: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => GuardScreen()));

              },
            ),            DrawerListTile(
              title: "Access Control",
              svgSrc: "assets/icons/access.png",
              press: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AccessScreen()));
              },
            ),
            DrawerListTile(
              title: "Payments",
              svgSrc: "assets/icons/payment.png",
              press: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => PaymentScreen()));

              },
            ),
            DrawerListTile(
              title: "Reservation",
              svgSrc: "assets/icons/reservation.png",
              press: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ReservationScreen()));
              },
            ),
            DrawerListTile(
              title: "Incident/Complain",
              svgSrc: "assets/icons/incident.png",
              press: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => IncidentScreen()));

              },
            ),
            DrawerListTile(
              title: "Announcements",
              svgSrc: "assets/icons/speaker.png",
              press: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AnnouncementScreen()));
              },
            ),
            DrawerListTile(
              title: "Survey",
              svgSrc: "assets/icons/survey.png",
              press: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => SurveyScreen()));
              },
            ),
            DrawerListTile(
              title: "Inventory",
              svgSrc: "assets/icons/inventory.png",
              press: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => InventoryScreen()));
              },
            ),
            DrawerListTile(
              title: "Market Place and Coupons",
              svgSrc: "assets/icons/market.png",
              press: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MarketPlaceScreen()));
              },
            ),
            DrawerListTile(
              title: "Logout",
              svgSrc: "assets/icons/logout.png",
              press: () async{
                await FirebaseAuth.instance.signOut().whenComplete((){
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (BuildContext context) => SignIn()));
                });
              },
            ),

          ],
        ),
      )
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: Image.asset(
        svgSrc,
        color: Colors.white54,
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
