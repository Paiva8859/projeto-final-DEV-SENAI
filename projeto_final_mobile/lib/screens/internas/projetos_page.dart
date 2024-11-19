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
          // Adiciona o campo "criador" com o ID do usuário (identificador do usuário)
          Map<String, dynamic> projetoData =
              projetoDoc.data() as Map<String, dynamic>;
          projetoData['criador'] =
              usuarioDoc.id; // Adiciona o ID do usuário como "criador"

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

  // Método para logout
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      // AppBar personalizada
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        actions: [
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _projetosVerificados.isEmpty
              ? const Center(
                  child: Text('Nenhum projeto verificado encontrado.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    itemCount: _projetosVerificados.length,
                    itemBuilder: (context, index) {
                      final projeto = _projetosVerificados[index];
                      final isVaquinha = projeto['vaquinha'] ?? false;

                      // Determinar se deve exibir "Local" ou "Valor"
                      final localOuValorLabel = isVaquinha ? 'Valor' : 'Local';
                      final localOuValor =
                          projeto['localOuValor'] ?? 'Não especificado';

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
                                projeto['nome'] ?? 'Título do Projeto',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  'Criador: ${projeto['criador'] ?? 'Desconhecido'}'),
                              const SizedBox(height: 8),
                              Text('$localOuValorLabel: $localOuValor'),
                              const SizedBox(height: 8),
                              Text(
                                  'Descrição: ${projeto['descricao'] ?? 'Sem descrição'}'),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  // Lógica para inscrição ou doação
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(isVaquinha
                                    ? 'Fazer uma Doação'
                                    : 'Inscrever-se'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
