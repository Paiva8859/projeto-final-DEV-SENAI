import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjetosPage extends StatefulWidget {
  @override
  _ProjetosPageState createState() => _ProjetosPageState();
}

class _ProjetosPageState extends State<ProjetosPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _projetosVerificados = [];
  bool _loading = true;
  int _selectedIndex = 1; // Adicionando o índice selecionado

  @override
  void initState() {
    super.initState();
    _fetchProjetosVerificados();
  }

  Future<void> _fetchProjetosVerificados() async {
    try {
      QuerySnapshot usuariosSnapshot =
          await _firestore.collection('Usuarios').get();
      List<Map<String, dynamic>> tempProjetos = [];

      for (var usuarioDoc in usuariosSnapshot.docs) {
        QuerySnapshot projetosSnapshot = await usuarioDoc.reference
            .collection('Projetos')
            .where('verificado', isEqualTo: true)
            .get();

        for (var projetoDoc in projetosSnapshot.docs) {
          Map<String, dynamic> projetoData =
              projetoDoc.data() as Map<String, dynamic>;
          projetoData['criador'] = usuarioDoc.id;

          tempProjetos.add(projetoData);
        }
      }

      setState(() {
        _projetosVerificados = tempProjetos;
        _loading = false;
      });
    } catch (e) {
      print('Erro ao buscar projetos verificados: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Função chamada ao clicar no item da BottomNavigationBar
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
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Projetos',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_projetosVerificados.isEmpty)
            const Center(
              child: Text(
                'Nenhum projeto verificado encontrado.',
                style: TextStyle(fontSize: 18),
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ..._projetosVerificados.map((projeto) {
                    final isVaquinha = projeto['vaquinha'] ?? false;
                    final localOuValorLabel = isVaquinha ? 'Valor' : 'Local';
                    final localOuValor =
                        projeto['localOuValor'] ?? 'Não especificado';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              projeto['nome'] ?? 'Título do Projeto',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('Criador: ${projeto['criador']}'),
                            const SizedBox(height: 8),
                            Text('$localOuValorLabel: $localOuValor'),
                            const SizedBox(height: 8),
                            Text(
                              'Descrição: ${projeto['descricao'] ?? 'Sem descrição'}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                // Ação ao clicar
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                  isVaquinha ? 'Fazer uma Doação' : 'Inscrever-se'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/cadastro-projetos'); // Rota para a página de criação de projeto
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/imagem-de-fundo(cadastro-e-login).png', // Substitua pelo caminho correto da imagem
            height: 275,
            fit: BoxFit.cover,
          ),
          BottomNavigationBar(
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
        ],
      ),
    );
  }
}
