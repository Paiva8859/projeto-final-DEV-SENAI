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
  int _selectedIndex = 1; // Índice selecionado da BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _fetchProjetosVerificados();
  }

  Future<void> _fetchProjetosVerificados() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return; // Se o usuário não estiver logado, não continua

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
          projetoData['id'] = projetoDoc.id; // Adiciona o ID do projeto

          // Verifica se o usuário está inscrito no projeto
          DocumentSnapshot voluntarioSnapshot = await _firestore
              .collection('Usuarios')
              .doc(usuarioDoc.id)
              .collection('Projetos')
              .doc(projetoDoc.id)
              .collection('Voluntarios')
              .doc(user.email) // O email do usuário como ID do documento
              .get();

          // Adiciona a propriedade `isInscrito` ao projeto
          projetoData['isInscrito'] = voluntarioSnapshot.exists;

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

  // ARRUMAR
  // Future<void> _inscreverNoProjeto(Map<String, dynamic> projeto) async {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user == null) {
  //       // Se o usuário não estiver logado, exibe um erro
  //       _showErrorDialog('Você precisa estar logado para se inscrever!');
  //       return;
  //     }

  //     final criadorProjetoId = projeto['criador']; // ID do criador do projeto
  //     final projetoId = projeto['id']; // ID do projeto
  //     final uidUsuario = user.uid; // ID único do usuário logado

  //     // Verifica se o usuário já está inscrito neste projeto
  //     DocumentSnapshot voluntarioSnapshot = await _firestore
  //         .collection('Usuarios')
  //         .doc(criadorProjetoId) // Caminho até o usuário criador do projeto
  //         .collection('Projetos')
  //         .doc(projetoId) // ID do projeto
  //         .collection('Voluntarios')
  //         .doc(uidUsuario) // O ID do usuário será o ID do documento
  //         .get();

  //     if (voluntarioSnapshot.exists) {
  //       // Se já existir, avisa que o usuário já está inscrito
  //       _showErrorDialog('Você já está inscrito neste projeto!');
  //       return;
  //     }

  //     // Cria um novo documento para o voluntário na coleção 'Voluntarios' do projeto
  //     await _firestore
  //         .collection('Usuarios')
  //         .doc(criadorProjetoId) // ID do criador do projeto
  //         .collection('Projetos')
  //         .doc(projetoId) // ID do projeto
  //         .collection('Voluntarios')
  //         .doc(uidUsuario) // O ID do usuário como o ID do documento
  //         .set({
  //       'nome': user.displayName ?? 'Nome desconhecido', // Nome do usuário
  //       'email': user.email, // Email do usuário
  //       'dataInscricao': FieldValue.serverTimestamp(), // Data da inscrição
  //     });

  //     // Mensagem de sucesso
  //     _showSuccessDialog('Você foi inscrito com sucesso no projeto!');
  //   } catch (e) {
  //     // Se ocorrer um erro, mostra um erro genérico
  //     _showErrorDialog('Erro ao se inscrever no projeto: $e');
  //   }
  // }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDoacaoDialog(Map<String, dynamic> projeto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fazer uma Doação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Você está doando para o projeto: ${projeto['nome']}'),
              const SizedBox(height: 10),
              // Você pode adicionar um campo de valor de doação ou outra lógica aqui.
              ElevatedButton(
                onPressed: () {
                  // Lógica para fazer a doação
                  _confirmarDoacao(projeto);
                },
                child: const Text('Confirmar Doação'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o dialog
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarDoacao(Map<String, dynamic> projeto) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showErrorDialog('Você precisa estar logado para fazer uma doação!');
        return;
      }

      // Aqui você pode adicionar lógica para registrar a doação (ex: adicionar à coleção de doações)
      await _firestore
          .collection('Projetos')
          .doc(projeto['id'])
          .collection('Doacoes')
          .add({
        'usuarioId': user.uid,
        'valor':
            100, // Exemplo de valor fixo, pode ser ajustado conforme necessário
        'dataDoacao': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog('Doação realizada com sucesso!');
    } catch (e) {
      _showErrorDialog('Erro ao realizar a doação: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                // Define a largura máxima como 600 ou a largura da tela se for menor
                double maxWidth = 600;
                double width = constraints.maxWidth < maxWidth
                    ? constraints.maxWidth
                    : maxWidth;

                return Center(
                  // Centraliza o conteúdo
                  child: Container(
                    width: width, // Largura limitada
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
                        Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    ..._projetosVerificados.map((projeto) {
                                      final isVaquinha =
                                          projeto['vaquinha'] ?? false;
                                      final localOuValorLabel =
                                          isVaquinha ? 'Valor' : 'Local';
                                      final localOuValor =
                                          projeto['localOuValor'] ??
                                              'Não especificado';

                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        elevation: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                projeto['nome'] ??
                                                    'Título do Projeto',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                  'Criador: ${projeto['criador']}'),
                                              const SizedBox(height: 8),
                                              Text(
                                                  '$localOuValorLabel: $localOuValor'),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Descrição: ${projeto['descricao'] ?? 'Sem descrição'}',
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 12),
                                              ElevatedButton(
                                                onPressed: projeto['isInscrito']
                                                    ? null // Se já estiver inscrito, desabilita o botão
                                                    : () async {
                                                        if (isVaquinha) {
                                                          // Lógica para fazer uma doação
                                                          _showDoacaoDialog(
                                                              projeto);
                                                        } else {
                                                          // Lógica de inscrição no projeto
                                                          await _inscreverNoProjeto(
                                                              projeto);
                                                        }
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: projeto[
                                                          'isInscrito']
                                                      ? Colors
                                                          .grey // Cor diferente para indicar que já está inscrito
                                                      : Colors.black,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: Text(
                                                  projeto['isInscrito']
                                                      ? 'Inscrito' // Texto do botão muda para "Inscrito"
                                                      : (isVaquinha
                                                          ? 'Fazer uma Doação'
                                                          : 'Inscrever-se'),
                                                ),
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context,
              '/cadastro-projetos'); // Rota para a página de criação de projeto
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
