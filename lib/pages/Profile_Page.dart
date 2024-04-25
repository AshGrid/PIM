import 'package:eduprime/Loginpages/login_page.dart';
import 'package:eduprime/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Loginpages/home.dart';
import '../drawer_widgets/change-password.dart';
import '../drawer_widgets/contactus_page.dart';
import '../drawer_widgets/modifierProfile.dart';

class Profile extends StatelessWidget {
  const Profile();

  Future<String?> getUsernameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDECF2),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  BaseScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            FutureBuilder<String?>(
              future: getUsernameFromSharedPreferences(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while fetching data
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Show an error message if something went wrong
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Display the ProfilePic widget once the data is fetched
                  return ProfilePic(username: snapshot.data ?? "");
                }
              },
            ),
            const SizedBox(height: 20),

            ProfileMenu(
              text: "Personal information",
              icon: const Icon(Icons.verified_user),
              press: () {
                showModalBottomSheet(
                    context: context, builder: ((Builder) => ModifierProfile()));
              },
            ),
            ProfileMenu(
              text: "Password",
              icon: const Icon(Icons.password_sharp),
              press: () {
                showModalBottomSheet(
                    context: context, builder: ((Builder) => changepaswrd()));
              },
            ),
            ProfileMenu(
              text: "Contact Us",
              icon: const Icon(Icons.contact_page),
              press: () {
                showModalBottomSheet(
                    context: context, builder: ((Builder) => const contact_us()));
              },
            ),
            ProfileMenu(
              text: "Log Out",
              icon: const Icon(Icons.logout),
              press: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('userId');
                prefs.remove('f_name');
                prefs.remove('username');
                prefs.remove('email');

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
            // Other ProfileMenu items
          ],
        ),
      ),
      
    );
  }
}

class ProfilePic extends StatelessWidget {
  final String username;

  const ProfilePic({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstLetter = username.isNotEmpty ? username.substring(0, 1).toUpperCase() : "O";

    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: Colorprimary,
            child: Text(
              firstLetter,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,

            ),
          )
        ],
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.press,
  }) : super(key: key);

  final String text;
  final Icon icon;

  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color.fromARGB(255, 224, 230, 245),
        ),
        onPressed: press,
        child: Row(
          children: [
            icon,
            const SizedBox(width: 20),
            Expanded(child: Text(text)),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
