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
  int _selectedIndex = 3;

  User? _currentUser;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _missoes = [];
  List<Map<String, dynamic>> _projetos = [];
  List<Map<String, dynamic>> _projetosInscritos =
      []; // Lista para os projetos inscritos
  bool _loading = true;

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

  // Método para fazer logout
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(
        context, '/login'); // Redireciona para a página de login
  }

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

      // Carregando os projetos inscritos
      setState(() {
        _projetosInscritos = tempInscricoes;
      });

      // Carregando os projetos do usuário
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
        _projetos = projetos;
        _loading = false;
      });
    } catch (e) {
      print('Erro ao buscar dados: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildUserInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userData?['nome'] ?? 'Nome de usuário',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            const SizedBox(height: 12),
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
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Editar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjetoInscritoCard(Map<String, dynamic> projeto) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projeto['nome'] ?? 'Projeto sem nome',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
              const SizedBox(height: 8),
              Text(
                projeto['descricao'] ?? 'Sem descrição',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Acessar Projeto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissaoCard(Map<String, dynamic> missao) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                missao['tituloMissao'] ?? 'Missão sem título',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
              const SizedBox(height: 8),
              Text(
                missao['descricaoMissao'] ?? 'Sem descrição',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Recompensa: ${missao['recompensa'] ?? 'Sem recompensa'}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjetoCard(Map<String, dynamic> projeto) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projeto['nome'] ?? 'Projeto sem nome',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
              const SizedBox(height: 8),
              Text(
                projeto['descricao'] ?? 'Sem descrição',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Acessar Projeto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (user != null)
              Text(
                user.displayName ?? "Nome",
                style: const TextStyle(color: Colors.orange, fontSize: 16),
              ),
            TextButton(
              onPressed: () => _logout(context),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          'assets/imagem-de-fundo(cadastro-e-login).png', // Caminho da imagem
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 300,
                        ),
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUserInfoSection(),
                              const SizedBox(height: 20),
                              const Text(
                                'Missões disponíveis:',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              _missoes.isEmpty
                                  ? const Text(
                                      'Nenhuma missão disponível',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 16.0,
                                        mainAxisSpacing: 16.0,
                                      ),
                                      itemCount: _missoes.length,
                                      itemBuilder: (context, index) {
                                        return _buildMissaoCard(
                                            _missoes[index]);
                                      },
                                    ),
                              const SizedBox(height: 20),
                              const Text(
                                'Projetos Inscritos:',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              _projetosInscritos.isEmpty
                                  ? const Text(
                                      'Você ainda não se inscreveu em nenhum projeto',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 16.0,
                                        mainAxisSpacing: 16.0,
                                      ),
                                      itemCount: _projetosInscritos.length,
                                      itemBuilder: (context, index) {
                                        return _buildProjetoInscritoCard(
                                            _projetosInscritos[index]);
                                      },
                                    ),
                              const SizedBox(height: 20),
                              const Text(
                                'Seus Projetos:',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              _projetos.isEmpty
                                  ? const Text(
                                      'Você ainda não iniciou nenhum projeto',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 16.0,
                                        mainAxisSpacing: 16.0,
                                      ),
                                      itemCount: _projetos.length,
                                      itemBuilder: (context, index) {
                                        return _buildProjetoCard(
                                            _projetos[index]);
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Define o índice selecionado
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
        onTap: _onItemTapped, // Chama a função quando o item é clicado
      ),
    );
  }
}
