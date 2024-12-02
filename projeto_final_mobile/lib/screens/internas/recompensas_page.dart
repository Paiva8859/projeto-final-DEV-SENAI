import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

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
  num _moedas = 0; // Variável para armazenar o valor das moedas
  List<Map<String, dynamic>> _recompensas =
      []; // Lista de recompensas disponíveis

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchMoedas();
      _fetchRecompensas();
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

  Future<void> _fetchRecompensas() async {
    try {
      // Filtra as recompensas para incluir apenas aquelas com 'verificado: true'
      QuerySnapshot recompensasSnapshot = await _firestore
          .collection('Recompensa')
          .where('verificado', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> recompensasList = [];
      for (var doc in recompensasSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Adiciona o ID do documento

        // Apenas processa as recompensas que possuem os dados necessários
        if (data['titulo'] != null &&
            data['preco'] is num &&
            data['quantidade'] is num &&
            data['descricao'] != null) {
          recompensasList.add(data);
          print(
              'Recompensa carregada: ${data['titulo']}'); // Log para verificar
        } else {
          print('Dados inválidos ou ausentes: $data');
        }
      }

      setState(() {
        _recompensas = recompensasList;
      });
    } catch (e) {
      print('Erro ao buscar recompensas: $e');
    }
  }

  Future<void> _comprarRecompensa(Map<String, dynamic> recompensa) async {
    if (recompensa['preco'] is num && _moedas >= recompensa['preco']) {
      try {
        String? nomeUsuario = _currentUser!.displayName;
        if (nomeUsuario == null || nomeUsuario.isEmpty) return;

        if (recompensa['quantidade'] is num && recompensa['quantidade'] > 0) {
          await _firestore.collection('Usuarios').doc(nomeUsuario).update({
            'carteira': _moedas - recompensa['preco'],
          });

          await _firestore
              .collection('Usuarios')
              .doc(nomeUsuario)
              .collection('RecompensasCompradas')
              .add({
            'recompensa': recompensa['titulo'],
            'data': Timestamp.now(),
          });

          DocumentSnapshot recompensasDoc = await _firestore
              .collection('Recompensa')
              .doc(recompensa['id'])
              .get();

          if (recompensasDoc.exists) {
            // Atualiza a quantidade
            if (recompensa['quantidade'] > 1) {
              await _firestore
                  .collection('Recompensa')
                  .doc(recompensa['id'])
                  .update({'quantidade': FieldValue.increment(-1)});
            } else {
              // Se a quantidade for 1, exclui a recompensa do banco
              await _firestore
                  .collection('Recompensa')
                  .doc(recompensa['id'])
                  .delete();
            }

            String chave = _gerarChaveUnica();
            await _enviarEmailComChave(
                chave, recompensa['titulo'], recompensa['descricao']);

            setState(() {
              _moedas -= recompensa['preco'];
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Recompensa comprada com sucesso! Verifique seu e-mail.')),
            );
          } else {
            print(
                'Recompensa não encontrada no Firestore: ${recompensa['id']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('A recompensa não está mais disponível.')),
            );
          }
        } else {
          print(
              'Quantidade inválida ou esgotada para a recompensa: ${recompensa['titulo']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quantidade inválida ou esgotada!')),
          );
        }
      } catch (e) {
        print('Erro ao comprar recompensa: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro ao processar a compra!')),
        );
      }
    } else {
      print(
          'Moedas insuficientes ou preço inválido para a recompensa: ${recompensa['titulo']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você não tem moedas suficientes!')),
      );
    }
    _fetchRecompensas();
  }

  String _gerarChaveUnica() {
    const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    String chave = '';
    for (int i = 0; i < 8; i++) {
      chave += charset[random.nextInt(charset.length)];
    }
    return chave;
  }

  Future<void> _enviarEmailComChave(
      String chave, String recompensa, String descricao) async {
    final String username = 'apikey';
    final String apiKey =
        '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';

    final smtpServer = SmtpServer(
      'smtp.sendgrid.net', // Servidor SMTP do SendGrid
      port: 587,
      username: username,
      password: apiKey,
    );

    // Criação do e-mail
    final message = Message()
      ..from = Address('voluntarialimeira@gmail.com', 'Voluntaria Limeira')
      ..recipients.add(_currentUser!.email ?? '') // Destinatário do e-mail
      ..subject = 'Chave de Recompensa'
      ..text = '''
Sua chave única para a recompensa "${recompensa}" é: ${chave}

Descrição da Recompensa: ${descricao}

De ajuda em ajuda o mundo se torna melhor!
''';

    try {
      // Enviar o e-mail
      final sendReport = await send(message, smtpServer);
      print('Email enviado: ${sendReport.toString()}');
    } catch (e) {
      print('Erro ao enviar e-mail: $e');
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
          : Stack(
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
                // Usando Expanded para garantir que o corpo ocupe o restante do espaço
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Carteira: ',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '$_moedas', // Exibe o valor das moedas
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
                            const SizedBox(height: 20),
                            Text(
                              'Recompensas Disponíveis:',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: _recompensas.length,
                              itemBuilder: (context, index) {
                                var recompensa = _recompensas[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(recompensa['titulo'] ??
                                        'Título da recompensa'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Preço: ${recompensa['preco']} moedas'),
                                        Text(
                                            'Descrição: ${recompensa['descricao']}'),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.shopping_cart),
                                      onPressed: () =>
                                          _comprarRecompensa(recompensa),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
