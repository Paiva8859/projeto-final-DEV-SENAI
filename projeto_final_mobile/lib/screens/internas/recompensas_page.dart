import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecompensasPage extends StatefulWidget {
  @override
  _RecompensasPageState createState() => _RecompensasPageState();
}

class _RecompensasPageState extends State<RecompensasPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _loading = true;
  int _selectedIndex = 2; // Definir o índice da Recompensas como selecionado
  int _moedas = 0; // Quantidade de moedas do usuário

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchRecompensas();
      _fetchMoedas();
    }
  }

  Future<void> _fetchMoedas() async {
    try {
      if (_currentUser == null) return;

      String? nomeUsuario = _currentUser!.displayName;
      if (nomeUsuario == null || nomeUsuario.isEmpty) return;

      DocumentSnapshot usuarioSnapshot =
          await _firestore.collection('Usuarios').doc(nomeUsuario).get();

      setState(() {
        final data = usuarioSnapshot.data()
            as Map<String, dynamic>?; // Faz o cast para Map<String, dynamic>
        _moedas = data?['moedas'] ?? 0; // Retorna 0 se não existir
      });
    } catch (e) {
      print('Erro ao buscar moedas: $e');
    }
  }

  Future<void> _fetchMoedas() async {
    try {
      if (_currentUser == null) return;

      String? nomeUsuario = _currentUser!.displayName;
      if (nomeUsuario == null || nomeUsuario.isEmpty) return;

      DocumentSnapshot usuarioSnapshot =
          await _firestore.collection('Usuarios').doc(nomeUsuario).get();

      setState(() {
        final data = usuarioSnapshot.data() as Map<String, dynamic>?;
        _moedas = data?['carteira'] ?? 0;
        _loading = false;
      });
    } catch (e) {
      print('Erro ao buscar carteira: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

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
      appBar: AppBar(
        title: const Text(
          'Recompensas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/usuario');
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Carteira',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '$_moedas',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.orange,
                              size: 28,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _recompensas.length,
                      itemBuilder: (context, index) {
                        return _buildRecompensaCard(_recompensas[index]);
                      },
                    ),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
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
      ),
    );
  }
}
