import 'package:eduprime/Loginpages/verifier_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constant/color.dart';

class Resset extends StatefulWidget {
  @override
  _ResetState createState() => _ResetState();
}

class _ResetState extends State<Resset> {
  int _selectedIndex = 0;
  String? _email;
  String? _phoneNumber;


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _email = null;
      _phoneNumber = null;
      _keyForm.currentState?.reset();

    });
  }

  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
          child: Column(
            children: [
              const Text(
                "Reset Password",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                  "Please choose the method to reset your password:"),
              const SizedBox(height: 20),
              BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.email),
                    label: 'Email',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.phone),
                    label: 'Phone Number',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.blue,
                onTap: _onItemTapped,
              ),
              const SizedBox(height: 20),
              Form(
                key: _keyForm,
                child: Column(
                  children: [
                    if (_selectedIndex == 0) ...{
                      // Email fragment
                      TextFormField(
                        initialValue: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: const Icon(Icons.email),
                          hintText: "Your Email",
                          labelStyle: TextStyle(
                            color: Colors.grey[400],
                          ),
                          border: const UnderlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.4),
                            ),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                        ),
                        onSaved: (String? value) {
                          _email = value;
                        },
                        validator: (String? value) {
                          RegExp regex = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                          if (value!.isEmpty || !regex.hasMatch(value)) {
                            return "Invalid Email!";
                          } else {
                            return null;
                          }
                        },
                      ),
                    } else ...{
                      // Phone number fragment
                      TextFormField(
                        initialValue: _phoneNumber,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: const Icon(Icons.phone),
                          hintText: "Your Phone Number",
                          labelStyle: TextStyle(
                            color: Colors.grey[400],
                          ),
                          border: const UnderlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.4),
                            ),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                        ),
                        onSaved: (String? value) {
                          _phoneNumber = value;
                        },
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return "Phone Number is required!";
                          } else if (value.length != 8) {
                            return "Phone Number must be 8 digits!";
                          } else {
                            return null;
                          }
                        },
                      ),
                    },
                  ],
                ),
              ),
              const SizedBox(height: 25),
          SizedBox(
            width: double.infinity, // Make the button fill the width
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colorprimary,
                foregroundColor: Colors.white, // text color
                shape: const StadiumBorder(),
                padding: const EdgeInsets.all(13),
              ),

                child: const Text(
                  'SEND',
                ),
                onPressed: () {
                  if (_keyForm.currentState!.validate()) {
                    _keyForm.currentState!.save();
                    if (_selectedIndex == 0) {
                      print('Email: $_email');
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Verification Code Sent'),
                            content: Text('A verification code has been sent to $_email.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Verifier(),
                                    ),
                                  );
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      print('Phone Number: $_phoneNumber');
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Verification Code Sent'),
                            content: Text('A verification code has been sent to $_phoneNumber.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Verifier(),
                                    ),
                                  );
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },

              ))
            ],
          ),
        ),
      ),
    );
  }
}
