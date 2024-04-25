import 'package:eduprime/Loginpages/AddPhone.dart';
import 'package:flutter/material.dart';
import '../constant/color.dart';
import 'dart:convert';


class SingUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDECF2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFEDECF2),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "SignUp to EduPrime",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Explore the best courses online with thousands of classes in design , business,marketing,and many more",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey, // Set the color of the divider

                    ),
                  )

                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 40,
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(), backgroundColor: const Color(0xFF576dff),
                      padding: const EdgeInsets.all(13),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "connect with facebook",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        Image.asset(
                          'assets/images/facebookicon.png',
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(), backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.all(13),
                        textStyle: const TextStyle(
                          color: Colors.black,
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "connect with Google",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        Image.asset(
                          'assets/images/googleicon.png',
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            SinupForm(),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}

class SinupForm extends StatefulWidget {
  @override
  _SinupFormFormState createState() => _SinupFormFormState();
}

class _SinupFormFormState extends State<SinupForm> {
  var _obscureText = true;

  late String? _f_name;
  late String? _username;
  late String? _email;
  late String? _pwd;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.person),
                  border: UnderlineInputBorder(),
                  labelText: "Your name",
                  labelStyle: TextStyle(
                  ),
                ),
                onSaved: (String? value) {
                  _f_name = value;
                },
                validator: (String? value) {
                  if (value!.isEmpty || value.length < 5) {
                    return "Too short !";
                  } else {
                    return null;
                  }
                }),
            const SizedBox(height: 30),
            TextFormField(
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.email),
                border: UnderlineInputBorder(),
                labelText: "Your Email",
                labelStyle: TextStyle(
                  //color: color,
                ),
              ),
              onSaved: (String? value) {
                _email = value;
              },
              validator: (String? value) {
                RegExp regex = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                if (value!.isEmpty || !regex.hasMatch(value)) {
                  return "Invalid Email !";
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(height: 30),

            TextFormField(
              obscureText: _obscureText,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelStyle: const TextStyle(
                 // color: color,
                ),
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              onSaved: (String? value) {
                _pwd = value;
              },
              validator: (String? value) {
                if (value!.isEmpty || value.length < 5) {
                  return "Too Short !";
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(height: 35),
            TextFormField(
              obscureText: _obscureText,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelStyle: const TextStyle(
                 // color: color,
                ),
                labelText: 'ConfirmPassword',
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),SizedBox(
              width: double.infinity, // Make the button fill the width
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: Colorprimary,
                foregroundColor: Colors.white, // text color
                shape: const StadiumBorder(),
                padding: const EdgeInsets.all(13),
                ),
                          child: const Text(
                'CONTINUE',
              ),
              onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPhone(),
                        ),
                      );

              },
            ),)
          ],
        ),
      ),
    );
  }
}
