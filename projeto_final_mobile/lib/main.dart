import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projeto_final_mobile/screens/cadastro_page.dart';
import 'package:projeto_final_mobile/screens/home_page.dart';
import 'package:projeto_final_mobile/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginPage(),
      '/cadastro': (context) => CadastroPage(),
      '/home': (context) => HomePage(),
    },
  ));
}