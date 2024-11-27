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

  Future<void> _cancelarInscricao(Map<String, dynamic> projeto) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Verifica se o usuário está logado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Você precisa estar logado para cancelar a inscrição!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final criadorProjetoId = projeto['criador']; // ID do criador do projeto
      final nomeUsuario =
          user.displayName ?? 'Nome desconhecido'; // Nome do usuário
      final nomeUsuarioSanitizado =
          nomeUsuario.replaceAll(RegExp(r'[./\[\]#?]'), '-');

      // Inicializa projetoId com valor padrão, como uma string vazia
      String? projetoId;

      // 1. Listar projetos do criador
      final projetosSnapshot = await _firestore
          .collection('Usuarios')
          .doc(criadorProjetoId)
          .collection('Projetos')
          .get();

      // Verifique se algum projeto foi encontrado
      if (projetosSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum projeto encontrado para o criador!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 2. Buscar o ID do projeto a partir da lista
      for (var doc in projetosSnapshot.docs) {
        if (doc.data()['nome'] == projeto['nome']) {
          projetoId = doc.id; // ID do documento do projeto
          break;
        }
      }

      if (projetoId == null) {
        // Se não encontrar o projeto pelo nome
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projeto não encontrado!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 3. Verificar se o usuário está inscrito neste projeto
      DocumentSnapshot voluntarioSnapshot = await _firestore
          .collection('Usuarios')
          .doc(criadorProjetoId)
          .collection('Projetos')
          .doc(projetoId)
          .collection('Voluntarios')
          .doc(nomeUsuarioSanitizado)
          .get();

      if (!voluntarioSnapshot.exists) {
        // Se não existir, avisa que o usuário não está inscrito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você não está inscrito neste projeto!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 4. Remover o documento do voluntário na coleção 'Voluntarios' do projeto
      await _firestore
          .collection('Usuarios')
          .doc(criadorProjetoId)
          .collection('Projetos')
          .doc(projetoId)
          .collection('Voluntarios')
          .doc(nomeUsuarioSanitizado)
          .delete();

      // Mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você cancelou sua inscrição no projeto com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Recarrega a lista de projetos inscritos chamando _fetchUserData
      await _fetchUserData();
    } catch (e) {
      // Se ocorrer um erro, mostra um erro genérico com SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cancelar inscrição no projeto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _atualizarUsuariosParticipantes(
      List<String> usuariosParticipantes, Map<String, dynamic> projeto) async {
    final int recompensa = projeto['recompensa'] ?? 0;

    for (String usuarioId in usuariosParticipantes) {
      try {
        // Caminho do documento do usuário no Firestore
        DocumentReference usuarioRef = FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(usuarioId); // Nome do documento é o ID do usuário

        // Log para verificar qual usuário está sendo atualizado
        print('Atualizando usuário: $usuarioId');

        // Obter o documento do usuário
        DocumentSnapshot usuarioSnapshot = await usuarioRef.get();

        if (usuarioSnapshot.exists) {
          // Log para confirmar que o usuário foi encontrado no Firestore
          print('Usuário encontrado: $usuarioId');

          // Atualizar a pontuação do usuário na carteira
          int carteiraAtual = usuarioSnapshot.get('carteira') ?? 0;
          print('Pontuação atual na carteira de $usuarioId: $carteiraAtual');

          await usuarioRef.update({'carteira': carteiraAtual + recompensa});
          print('Pontuação atualizada para: ${carteiraAtual + recompensa}');
        } else {
          // Log se o usuário não for encontrado no Firestore
          print('Usuário $usuarioId não encontrado no Firestore');
        }
      } catch (e) {
        print('Erro ao atualizar o usuário $usuarioId: $e');
      }
    }
  }

  Future<void> _finalizarProjeto(Map<String, dynamic> projeto) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Você precisa estar logado para finalizar o projeto!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final criadorProjetoId = user.displayName;
      final nomeUsuario = user.displayName ?? 'Nome desconhecido';

      String? projetoId;

      // 1. Listar projetos do criador
      final projetosSnapshot = await _firestore
          .collection('Usuarios')
          .doc(criadorProjetoId)
          .collection('Projetos')
          .get();

      if (projetosSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum projeto encontrado para o criador!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 2. Buscar o ID do projeto
      for (var doc in projetosSnapshot.docs) {
        if (doc.data()['nome'] == projeto['nome']) {
          projetoId = doc.id;
          break;
        }
      }

      if (projetoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projeto não encontrado!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 3. Obter voluntários do projeto
      final voluntariosSnapshot = await _firestore
          .collection('Usuarios')
          .doc(nomeUsuario)
          .collection('Projetos')
          .doc(projetoId)
          .collection('Voluntarios')
          .get();

      List<String> voluntarios =
          voluntariosSnapshot.docs.map((doc) => doc.id).toList();

      if (voluntarios.isEmpty) {
        print("Nenhum voluntário encontrado para o projeto.");
        return;
      }

      // 4. Exibir diálogo para seleção de participantes
      final selectedVoluntarios = await showDialog<List<String>>(
        context: context,
        builder: (context) {
          final Map<String, bool> voluntariosSelecionados = {
            for (var voluntario in voluntarios) voluntario: false,
          };

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Selecione os participantes do projeto'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    children: voluntariosSelecionados.keys.map((voluntario) {
                      return CheckboxListTile(
                        title: Text(voluntario),
                        value: voluntariosSelecionados[voluntario],
                        onChanged: (bool? value) {
                          setState(() {
                            voluntariosSelecionados[voluntario] =
                                value ?? false;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(voluntariosSelecionados.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList());
                    },
                    child: const Text('Confirmar'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (selectedVoluntarios == null || selectedVoluntarios.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum participante foi selecionado!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 5. Atribuir pontos apenas aos participantes selecionados
      for (var voluntarioId in selectedVoluntarios) {
        final voluntarioRef =
            _firestore.collection('Usuarios').doc(voluntarioId);

        await _firestore.runTransaction((transaction) async {
          final voluntarioSnapshot = await transaction.get(voluntarioRef);

          if (!voluntarioSnapshot.exists) {
            throw Exception('Voluntário não encontrado.');
          }

          int carteira = voluntarioSnapshot.data()?['carteira'] ?? 0;

          final projetoData = await _firestore
              .collection('Usuarios')
              .doc(nomeUsuario)
              .collection('Projetos')
              .doc(projetoId)
              .get();

          int pontosRecompensa = projetoData.data()?['recompensa'] ?? 0;
          int novosPontos = carteira + pontosRecompensa;

          transaction.update(voluntarioRef, {'carteira': novosPontos});
          print(
              "Pontos atribuídos ao voluntário $voluntarioId: $pontosRecompensa");
        });
      }

      // 6. Remover o projeto
      await _firestore
          .collection('Usuarios')
          .doc(criadorProjetoId)
          .collection('Projetos')
          .doc(projetoId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você finalizou esse projeto!'),
          backgroundColor: Colors.green,
        ),
      );

      // Recarrega a lista de projetos
      await _fetchUserData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar projeto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Enviar email de verificação de email
  Future<void> _enviarEmailVerificacao() async {
    try {
      if (_currentUser != null && !_currentUser!.emailVerified) {
        await _currentUser!.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Para continuar com essa ação verifique seu Email. \nE-mail de verificação enviado. Verifique sua caixa de entrada.')),
        );
      }
    } catch (e) {
      print('Erro ao enviar e-mail de verificação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Para continuar com essa ação verifique seu Email. \nErro ao enviar e-mail de verificação.')),
      );
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

      // Remover ou substituir caracteres especiais que não são permitidos no Firestore
      nomeUsuario = nomeUsuario.replaceAll(RegExp(r'[./\[\]#?]'), '-');

      DocumentSnapshot userSnapshot =
          await _firestore.collection('Usuarios').doc(nomeUsuario).get();

      if (!userSnapshot.exists) {
        print("Usuário não encontrado.");
        return;
      }

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
              .any((voluntario) => voluntario.id == nomeUsuario)) {
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
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser
                      ?.reload(); // Recarregar dados do usuário
                  User? updatedUser = FirebaseAuth.instance.currentUser;

                  if (updatedUser != null && updatedUser.emailVerified) {
                    // Redirecionar para a página de edição se o e-mail agora estiver verificado
                    Navigator.pushNamed(context, '/editarUsuario');
                  } else {
                    _enviarEmailVerificacao();
                  }
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
              projeto['nome'] ?? 'Projeto sem nome',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('Criador: ${projeto['criador']}'),
            const SizedBox(height: 8),
            Text(
              'Local ou Valor: ${projeto['localOuValor'] ?? 'Não especificado'}',
            ),
            const SizedBox(height: 8),
            Text(
              'Descrição: ${projeto['descricao'] ?? 'Sem descrição'}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _cancelarInscricao(projeto);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cancelar Inscrição'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjetoCard(Map<String, dynamic> projeto) {
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
              projeto['nome'] ?? 'Projeto sem nome',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Local ou Valor: ${projeto['localOuValor'] ?? 'Não especificado'}',
            ),
            const SizedBox(height: 8),
            Text(
              'Descrição: ${projeto['descricao'] ?? 'Sem descrição'}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _finalizarProjeto(projeto);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Finalizar Projeto'),
            ),
          ],
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
        title: const Text(
          'Pagina do usuario',
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
