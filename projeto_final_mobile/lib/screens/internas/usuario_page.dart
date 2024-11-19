import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioPage extends StatefulWidget {
  @override
  _UsuarioPageState createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _missoes = [];
  List<Map<String, dynamic>> _inscricoes = [];
  List<Map<String, dynamic>> _projetos = []; // Lista para projetos
  bool _loading = true;

  // Função para construir o card de missões
  Widget _buildMissaoCard(Map<String, dynamic> missao) {
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
              missao['tituloMissao'] ?? 'Missão sem título',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              missao['descricaoMissao'] ?? 'Sem descrição',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Recompensa: ${missao['recompensa'] ?? 'Sem recompensa'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir o card de projetos
  Widget _buildProjetoCard(Map<String, dynamic> projeto) {
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
              projeto['nome'] ?? 'Projeto sem nome',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              projeto['descricao'] ?? 'Sem descrição',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Lógica para editar o projeto
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Editar Projeto'),
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir o card de inscrições
  Widget _buildInscricaoCard(Map<String, dynamic> inscricao) {
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
              inscricao['nome'] ?? 'Projeto sem título',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Criador: ${inscricao['criador'] ?? 'Desconhecido'}'),
            const SizedBox(height: 8),
            Text(
              'Descrição: ${inscricao['descricao'] ?? 'Sem descrição'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Cancelar inscrição
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  // Função para buscar os dados do usuário, missões, inscrições e projetos
  Future<void> _fetchUserData() async {
    try {
      if (_currentUser == null) {
        return;
      }

      String? nomeUsuario = _currentUser!.displayName;

      if (nomeUsuario == null || nomeUsuario.isEmpty) {
        print("Nome de usuário não disponível.");
        return;
      }

      DocumentSnapshot userSnapshot =
          await _firestore.collection('Usuarios').doc(nomeUsuario).get();

      if (!userSnapshot.exists) {
        print("Usuário não encontrado.");
        return;
      }

      QuerySnapshot missoesSnapshot =
          await _firestore.collection('Missoes').get();

      List<Map<String, dynamic>> tempInscricoes = [];
      QuerySnapshot usuariosSnapshot =
          await _firestore.collection('Usuarios').get();

      // Busca as inscrições do usuário nos projetos
      for (var usuarioDoc in usuariosSnapshot.docs) {
        QuerySnapshot projetosSnapshot =
            await usuarioDoc.reference.collection('Projetos').get();

        for (var projetoDoc in projetosSnapshot.docs) {
          QuerySnapshot voluntariosSnapshot =
              await projetoDoc.reference.collection('Voluntarios').get();

          if (voluntariosSnapshot.docs
              .any((voluntario) => voluntario.id == _currentUser!.email)) {
            Map<String, dynamic> projetoData =
                projetoDoc.data() as Map<String, dynamic>;
            projetoData['criador'] = usuarioDoc.id;
            tempInscricoes.add(projetoData);
          }
        }
      }

      // Busca os projetos criados pelo usuário
      QuerySnapshot projetosSnapshot = await _firestore
          .collection('Usuarios')
          .doc(nomeUsuario)
          .collection('Projetos')
          .get();
      List<Map<String, dynamic>> projetos = projetosSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        _userData = userSnapshot.data() as Map<String, dynamic>?;
        _missoes = missoesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _inscricoes = tempInscricoes;
        _projetos = projetos; // Atualiza a lista de projetos
        _loading = false;
      });
    } catch (e) {
      print('Erro ao buscar dados: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  // Função para construir a seção de informações do usuário
  Widget _buildUserInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userData?['nome'] ?? 'Nome de usuário',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Email: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_userData?['email'] ?? 'Não especificado'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('CPF: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_userData?['cpf'] ?? 'Não especificado'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Telefone: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_userData?['telefone'] ?? 'Não especificado'),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/editarUsuario');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Editar'),
              ),
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
      _fetchUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsividade: Ajustar a quantidade de colunas dependendo do tamanho da tela
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

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
                  Text(
                    'Bem-vindo(a), ${_userData?['nome'] ?? 'Usuário'}!',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  _buildUserInfoSection(),
                  const SizedBox(height: 16),
                  const Text('Missões',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _missoes.length,
                    itemBuilder: (context, index) {
                      return _buildMissaoCard(_missoes[index]);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Inscrições',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _inscricoes.length,
                    itemBuilder: (context, index) {
                      return _buildInscricaoCard(_inscricoes[index]);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Seus Projetos',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _projetos.length,
                    itemBuilder: (context, index) {
                      return _buildProjetoCard(_projetos[index]);
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
