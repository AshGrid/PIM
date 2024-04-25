import 'package:eduprime/constant/color.dart';
import 'package:flutter/material.dart';
import '../pages/Profile_Page.dart';
import '../utils/size_config.dart';

class ModifierProfile extends StatefulWidget {
  @override
  State<ModifierProfile> createState() => _ModifierProfileState();
}

class _ModifierProfileState extends State<ModifierProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDECF2),
        title: const Text("Informations"),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Profile())
            );
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            Text("Edit your Informations", style: headingStyle),
            const SizedBox(height: 15),
            Row(
              children: [
                Text(
                  "Your account is already verified",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption,
                ),
                const Icon(Icons.verified_user_rounded),
              ],
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.06),
            Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.person),
                      border: UnderlineInputBorder(),
                      labelText: "Full Name",
                      labelStyle: TextStyle(color: Colorprimary),
                    ),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 8) {
                        return "Too short !";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.email),
                      border: UnderlineInputBorder(),
                      labelText: "Your Email",
                      labelStyle: TextStyle(color: Colorprimary),
                    ),
                    validator: (value) {
                      RegExp regex = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                      if (value!.isEmpty || !regex.hasMatch(value)) {
                        return "Invalid Email !";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 200),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colorprimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 125,
                        vertical: 13,
                      ),
                    ),
                    child: const Text(
                      'SAVE',
                    ),
                    onPressed: () {
                      // Implement save functionality
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
