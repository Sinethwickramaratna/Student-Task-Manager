import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class GetStartedPage extends StatelessWidget{
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar:AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 0, 26),
        title: Image.asset(
          'assets/images/Logo2_white.png',
          width: 200,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
            'assets/Student transparent.json',
            width: 250,
            repeat: true
            ),
            Text(
              'Get Started and Manage Student Tasks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 55, 1, 65),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height:20),
            OutlinedButton(
              onPressed: () async{
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isFirstTime', false);

                WidgetsBinding.instance.addPostFrameCallback((_){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                });
              },
              child: const Text('Get Started!')
            ),
          ]
        ),
      ) 
    );
  }
}