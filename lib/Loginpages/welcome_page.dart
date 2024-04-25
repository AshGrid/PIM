import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import '../utils/delayedAnimation.dart';
import 'login_page.dart';

const Color Colorprimary = Color.fromRGBO(105, 156, 244,1);
const Color Colorseconde  = Color.fromRGBO(44, 54, 88, 1);

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(

      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 100,
            horizontal: 30,
          ),
          child: Column(
            children: [
              DelayedAnimation(
                delay: 1000,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 50,
                    bottom: 20,
                  ),
                  child: const Text("EduPrime.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colorprimary
                      )),
                ),

              ),
              DelayedAnimation(
                delay: 1500,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              DelayedAnimation(
                delay: 1000,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 80,
                    bottom: 20,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Welcome to EduPrime.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colorprimary,
                        ),
                      ),
                      Text(
                        "One lesson at a time with EduPrime.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,

                          color: Color.fromRGBO(211, 211, 211, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              DelayedAnimation(
                delay: 1000,
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colorprimary,
                        foregroundColor: Colors.white, // text color
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.all(13)),
                    child: const Text('GET STARTED'),
                    onPressed: ()  { {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              DelayedAnimation(
                delay: 1000,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 50,
                    bottom: 20,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey, // Set the color of the divider
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: const Text(
                              "Sign in with",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colorprimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/facebookicon.png',
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(width: 15),
                          Image.asset(
                            'assets/images/appleicon.png',
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(width: 15),
                          Image.asset(
                            'assets/images/googleicon.png',
                            width: 30,
                            height: 30,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),


            ]),
        ),
      ),
    );
  }
}
