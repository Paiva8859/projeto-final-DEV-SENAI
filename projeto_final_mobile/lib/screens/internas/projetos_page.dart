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

  Future<void> _inscreverNoProjeto(Map<String, dynamic> projeto) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Se o usuário não estiver logado, exibe um erro
        _showErrorDialog('Você precisa estar logado para se inscrever!');
        return;
      }

      final criadorProjetoId = projeto['criador']; // ID do criador do projeto
      final projetoId = projeto['id']; // ID do projeto
      String nomeUsuario =
          user.displayName ?? 'Nome desconhecido'; // Nome do usuário

      // Remover ou substituir caracteres especiais que não são permitidos no Firestore
      nomeUsuario = nomeUsuario.replaceAll(RegExp(r'[./\[\]#?]'), '-');

      // Verifica se o usuário já está inscrito neste projeto
      DocumentSnapshot voluntarioSnapshot = await _firestore
          .collection('Usuarios')
          .doc(criadorProjetoId) // Caminho até o usuário criador do projeto
          .collection('Projetos')
          .doc(projetoId) // ID do projeto
          .collection('Voluntarios')
          .doc(nomeUsuario) // O nome do usuário será o ID do documento
          .get();

      if (voluntarioSnapshot.exists) {
        // Se já existir, avisa que o usuário já está inscrito
        _showErrorDialog('Você já está inscrito neste projeto!');
        return;
      }

      // Cria um novo documento para o voluntário na coleção 'Voluntarios' do projeto
      await _firestore
          .collection('Usuarios')
          .doc(criadorProjetoId) // ID do criador do projeto
          .collection('Projetos')
          .doc(projetoId) // ID do projeto
          .collection('Voluntarios')
          .doc(nomeUsuario) // O nome do usuário como o ID do documento
          .set({
        'nome': user.displayName ?? 'Nome desconhecido', // Nome do usuário
        'email': user.email, // Email do usuário
        'dataInscricao': FieldValue.serverTimestamp(), // Data da inscrição
      });

      // Mensagem de sucesso
      _showSuccessDialog('Você foi inscrito com sucesso no projeto!');
    } catch (e) {
      // Se ocorrer um erro, mostra um erro genérico
      _showErrorDialog('Erro ao se inscrever no projeto: $e');
    }
  }

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
    final TextEditingController _valorController = TextEditingController();

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
              TextField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor da Doação (R\$)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final valorDoacao =
                    double.tryParse(_valorController.text) ?? 0.0;

                if (valorDoacao <= 0) {
                  // Mostra um alerta se o valor for inválido
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Insira um valor válido para a doação.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Calcula as moedas
                final moedasRecebidas = (valorDoacao / 10).floor();

                // Mostra o diálogo de confirmação
                Navigator.pop(context); // Fecha o diálogo atual
                _showConfirmacaoDialog(projeto, valorDoacao, moedasRecebidas);
              },
              child: const Text('Enviar Doação'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmacaoDialog(
      Map<String, dynamic> projeto, double valorDoacao, int moedasRecebidas) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmação de Doação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Você está doando R\$${valorDoacao.toStringAsFixed(2)} '
                'para o projeto: ${projeto['nome']}.',
              ),
              const SizedBox(height: 10),
              Text(
                'Você receberá $moedasRecebidas ${moedasRecebidas == 1 ? 'moeda' : 'moedas'} '
                'em sua carteira.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para confirmar a doação e atualizar a carteira do usuário
                _confirmarDoacao(projeto, valorDoacao, moedasRecebidas);
                Navigator.pop(context); // Fecha o diálogo de confirmação
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarDoacao(Map<String, dynamic> projeto,
      double valorDoacao, int moedasRecebidas) async {
    try {
      // Obter o usuário autenticado
      User? user = _auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado. Faça login para doar.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Caminho do documento do projeto no Firestore
      final projetoRef = _firestore
          .collection('Usuarios')
          .doc(projeto['criador']) // Campo com o nome do criador do projeto
          .collection('Projetos')
          .doc(projeto['id']); // Campo com o ID do projeto

      // Caminho do documento do usuário no Firestore
      final userRef = _firestore.collection('Usuarios').doc(user.displayName);

      // Transação para processar a doação e verificar a vaquinha
      await _firestore.runTransaction((transaction) async {
        // Obter o documento do projeto (primeira leitura)
        final projetoSnapshot = await transaction.get(projetoRef);

        if (!projetoSnapshot.exists) {
          throw Exception('Projeto não encontrado.');
        }

        // Obter valores atuais do projeto
        final projetoData = projetoSnapshot.data();
        double arrecadado = projetoData?['arrecadado'] ?? 0.0;

        // Converter "localOuValor" para double (é armazenado como string)
        double objetivo =
            double.tryParse(projetoData?['localOuValor'] ?? '0') ?? 0.0;

        // Obter o documento do usuário (segunda leitura)
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception('Usuário não encontrado.');
        }

        // Atualizar a carteira do usuário (escrita)
        int carteiraAtual = userSnapshot.data()?['carteira'] ?? 0;
        int novaCarteira = carteiraAtual + moedasRecebidas;

        // Atualizar o valor arrecadado do projeto
        arrecadado += valorDoacao;

        // Verificar se a meta foi alcançada e, se sim, excluir o projeto
        if (arrecadado >= objetivo) {
          // Remover o projeto do Firestore
          transaction.delete(projetoRef);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Parabéns! O projeto ${projeto['nome']} atingiu a meta e foi finalizado.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Atualizar o campo "arrecadado" (escrita)
          transaction.update(projetoRef, {'arrecadado': arrecadado});
        }

        // Atualizar a carteira do usuário (escrita)
        transaction.update(userRef, {'carteira': novaCarteira});
      });

      // Exibir mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Doação de R\$${valorDoacao.toStringAsFixed(2)} confirmada! Você recebeu $moedasRecebidas moedas.'),
          backgroundColor: Colors.green,
        ),
      );

      // Registrar a doação no Firestore (opcional)
      await _firestore
          .collection('Usuarios')
          .doc(user.displayName)
          .collection('Doacoes')
          .add({
        'projeto': projeto['nome'],
        'valor': valorDoacao,
        'moedas': moedasRecebidas,
        'data': DateTime.now(),
      });
    } catch (e) {
      // Exibir mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar a doação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // Recarrega a lista de projetos
      await _fetchProjetosVerificados();
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
                // Define largura máxima para cards em telas maiores
                double maxWidth = 600;
                double width = constraints.maxWidth < maxWidth
                    ? constraints.maxWidth
                    : maxWidth;

                return Center(
                  child: Container(
                    width: width,
                    child: Stack(
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
                          children: [
                            Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16.0),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Quantidade de colunas
                                  crossAxisSpacing:
                                      10, // Espaçamento horizontal
                                  mainAxisSpacing: 10, // Espaçamento vertical
                                  childAspectRatio:
                                      0.8, // Proporção largura/altura
                                ),
                                itemCount: _projetosVerificados.length,
                                itemBuilder: (context, index) {
                                  final projeto = _projetosVerificados[index];
                                  final isVaquinha =
                                      projeto['vaquinha'] ?? false;
                                  final localOuValorLabel =
                                      isVaquinha ? 'Valor' : 'Local';
                                  final localOuValor =
                                      projeto['localOuValor'] ??
                                          'Não especificado';

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
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
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                              'Criador: ${projeto['criador']}'),
                                          const SizedBox(height: 6),
                                          Text(
                                              '$localOuValorLabel: $localOuValor'),
                                          const SizedBox(height: 6),
                                          const SizedBox(height: 6),
                                          Text(
                                              'Recompensa: ${projeto['recompensa']}'),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${projeto['descricao'] ?? 'Sem descrição'}',
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: projeto['isInscrito']
                                                ? null
                                                : () async {
                                                    if (isVaquinha) {
                                                      _showDoacaoDialog(
                                                          projeto);
                                                    } else {
                                                      await _inscreverNoProjeto(
                                                          projeto);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  projeto['isInscrito']
                                                      ? Colors.grey
                                                      : Colors.black,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Text(
                                              projeto['isInscrito']
                                                  ? 'Inscrito'
                                                  : (isVaquinha
                                                      ? 'Fazer uma Doação'
                                                      : 'Inscrever-se'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
          Navigator.pushNamed(context, '/cadastro-projetos');
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
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
