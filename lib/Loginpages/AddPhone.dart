import 'package:eduprime/Loginpages/verifier_pagephone.dart';
import 'package:flutter/material.dart';

import '../constant/color.dart';

class AddPhone extends StatefulWidget {
  @override
  _AddPhoneState createState() => _AddPhoneState();
}

class _AddPhoneState extends State<AddPhone> {
  String _selectedCountry = 'United States (+1)'; // Default country

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Phone'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Country',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField(
                        value: _selectedCountry,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCountry = newValue as String;
                          });
                        },
                        items: <String>[
                          'United States (+1)',
                          'United Kingdom (+44)',
                          'Canada (+1)',
                          'Australia (+61)',
                          'Germany (+49)',
                          'Tunisia(+216)',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your phone number',
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity, // Make the button fill the width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colorprimary,
                  foregroundColor: Colors.white, // text color
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.all(13),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Verifierphone(),
                    ),
                  );
                },
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
