import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0; // Índice da página atual

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Função chamada quando o usuário clica em um item da barra de navegação inferior
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (user != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/usuario');
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.orange.shade400,
                    child: Text(
                      user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Calcula a altura total disponível excluindo a barra de navegação inferior
            double availableHeight = constraints.maxHeight;

            return SizedBox(
              height: availableHeight,
              child: Stack(
                children: [
                  // Imagem de fundo na parte inferior da tela
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/imagem-de-fundo(cadastro-e-login).png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300,
                    ),
                  ),
                  // Conteúdo principal da página
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        'assets/imagem_de_fundo(paginas-internas).png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/imagem_familia.png',
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              text: 'De ajuda em ajuda\n',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: 'o mundo se torna ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal),
                                ),
                                TextSpan(
                                  text: 'melhor.',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Encontre Locais Próximos a você!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      'assets/mapa.png',
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: SizedBox(
                                  height: 120,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        top: 0,
                                        left: 40,
                                        child: Container(
                                          width: 43.84,
                                          height: 58.45,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/icone_gps.png'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 50,
                                        left: 10,
                                        child: Image.asset(
                                          'assets/imagem_celular.png',
                                          width: 113,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.orange, // Cor fixa para o ícone selecionado
          unselectedItemColor:
              Colors.black, // Cor para os ícones não selecionados
          showSelectedLabels: true,
          showUnselectedLabels: true,
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
          onTap: _onItemTapped,
        ));
  }
}