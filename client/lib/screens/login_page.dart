import 'package:flutter/material.dart';
import 'package:TaskHive/services/auth_service.dart';
import 'package:TaskHive/screens/admin_portal/admin_layout.dart';
import 'package:TaskHive/screens/teacher_portal/teacher_layout.dart';
import 'package:TaskHive/screens/student_portal/student_layout.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{

  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  bool _obscureText = true;

  void login() async{
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try{
      final roleId = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if(!mounted) return;

      if(roleId == 'Admin'){
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => AdminLayout(),
          ),
        );
      } else if(roleId == 'Teacher'){
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => const TeacherLayout(),
          ),
        );
      } else if(roleId == 'Student'){
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => const StudentLayout(),
          ),
        );
      }
    } catch(e){
      debugPrint('Login error: $e'); // Log error to console
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Failed: $e')));
    } finally{
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext 
  context){
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 20, 0, 38), Color.fromARGB(255,77,0,94)],
            begin: Alignment(0,0),
            end: Alignment(1.0, 2),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Image.asset('assets/images/Logo2_white.png', height: 120),
                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText:'Email or Username',
                      labelStyle: TextStyle(color: Colors.white,),
                      prefixIcon: Icon(Icons.email, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please enter your email';
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText:'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText? Icons.visibility: Icons.visibility_off, color: Colors.white),
                        onPressed: (){
                          setState((){
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    validator: (value){
                        if (value == null || value.isEmpty){
                          return 'Please enter your password.';
                        }
                        return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : login,
                      child: _loading? const CircularProgressIndicator(): const Text('Login'),
                    )
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Colors.white)),
                      GestureDetector(
                        onTap: (){

                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color.fromARGB(255, 213, 130, 255),
                            fontWeight: FontWeight.bold
                          )
                        )
                      ),
                    ],
                  ),
                ]
              ),
            ),
          ),

        ),
      ),
    );
  }
}