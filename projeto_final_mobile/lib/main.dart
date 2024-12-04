import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:projeto_final_mobile/screens/cadastro_page.dart';
import 'package:projeto_final_mobile/screens/home_page.dart';
import 'package:projeto_final_mobile/screens/internas/cadastro_projetos_page.dart';
import 'package:projeto_final_mobile/screens/internas/editar_usuario_page.dart';
import 'package:projeto_final_mobile/screens/internas/projetos_page.dart';
import 'package:projeto_final_mobile/screens/internas/recompensas_page.dart';
import 'package:projeto_final_mobile/screens/internas/usuario_page.dart';
import 'package:projeto_final_mobile/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginPage(),
      '/cadastro': (context) => CadastroPage(),
      '/home': (context) => HomePage(),
      '/cadastro-projetos': (context) => ProjetoCadastroPage(),
      '/projetos': (context) => ProjetosPage(),
      '/usuario': (context) => UsuarioPage(),
      '/recompensas': (context) => RecompensasPage(),
       '/editarUsuario': (context) => EditarUsuarioPage(),
    },
  ));
}
