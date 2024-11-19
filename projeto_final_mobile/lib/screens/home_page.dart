import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para fazer logout
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(
        context, '/login'); // Redireciona para a página de login
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o usuário logado
    User? user = _auth.currentUser;

    return Scaffold(
      
      backgroundColor: Colors.white,
      // AppBar personalizada
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black),
        actions: [
          // Exibe o nome do usuário logado, se houver
          if (user != null)
            TextButton(
              onPressed: () {},
              child: Text(user.displayName ?? 'Usuário',
                  style: TextStyle(color: Colors.orange)),
            ),
          TextButton(
            onPressed: () => _logout(context),
            child: Text('Logout', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagem principal
              Image.asset(
                'assets/ilustracao.png',
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              // Texto motivacional
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'De ajuda em ajuda\n',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'o mundo se torna ',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    TextSpan(
                      text: 'melhor.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Texto abaixo da imagem
              Text(
                'Encontre Locais Próximos a você!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              // Mapa ou imagem do mapa
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange),
                ),
                child: Image.asset(
                  'assets/mapa.png',
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              // Espaço para inserir mais conteúdos
              Container(
                height: 50,
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    'Conteúdo adicional aqui',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Projetos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Recompensas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/projetos');
              break;
            case 2:
              Navigator.pushNamed(context, '/recompensas');
              break;
            case 3:
              Navigator.pushNamed(context, '/usuario');
              break;
          }
        },
      ),
    );
  }
}
