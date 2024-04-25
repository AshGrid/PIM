import 'package:flutter/material.dart';
import 'package:mb_contact_form/mb_contact_form.dart';

class contact_us extends StatefulWidget {
  const contact_us({Key? key}) : super(key: key);

  @override
  State<contact_us> createState() => _contact_usState();
}

class _contact_usState extends State<contact_us> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Form"),
        elevation: 0,
      ),
      body: const MBContactForm(
        hasHeading: true,
        withIcons: true,
        destinationEmail: "EduPrime.contact@gmail.com",
      ),
    );
  }
}
