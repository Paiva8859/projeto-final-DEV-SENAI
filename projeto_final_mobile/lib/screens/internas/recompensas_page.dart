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
  List<Map<String, dynamic>> _recompensas = [];
  bool _loading = true;

  // Função para buscar as recompensas coletadas pelo usuário
  Future<void> _fetchRecompensas() async {
    try {
      if (_currentUser == null) {
        return;
      }

      String? nomeUsuario = _currentUser!.displayName;

      if (nomeUsuario == null || nomeUsuario.isEmpty) {
        print("Nome de usuário não disponível.");
        return;
      }

      QuerySnapshot recompensasSnapshot = await _firestore
          .collection('Usuarios')
          .doc(nomeUsuario)
          .collection('RecompensasColetadas')
          .get();

      setState(() {
        _recompensas = recompensasSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _loading = false;
      });
    } catch (e) {
      print('Erro ao buscar recompensas: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  // Função para construir o card de recompensas
  Widget _buildRecompensaCard(Map<String, dynamic> recompensa) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recompensa['tituloRecompensa'] ?? 'Título não disponível',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              recompensa['descricaoRecompensa'] ?? 'Sem descrição',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Função de logout
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchRecompensas();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calcula o número de colunas baseado no tamanho da tela
    int crossAxisCount = 2; // Default for small screens
    if (MediaQuery.of(context).size.width > 600) {
      crossAxisCount = 3; // Tablets or larger screens
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_currentUser != null)
            TextButton(
              onPressed: () {},
              child: Text(
                _currentUser!.displayName ?? 'Usuário',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          TextButton(
            onPressed: () => _logout(context),
            child: Text('Logout', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recompensas Coletadas',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (_recompensas.isEmpty)
                    const Center(
                        child: Text('Nenhuma recompensa coletada ainda!')),

                  // Exibe as recompensas em um GridView responsivo
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.8, // Ajusta a proporção dos cards
                    ),
                    itemCount: _recompensas.length,
                    itemBuilder: (context, index) {
                      return _buildRecompensaCard(_recompensas[index]);
                    },
                  ),
                ],
              ),
            ),
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
