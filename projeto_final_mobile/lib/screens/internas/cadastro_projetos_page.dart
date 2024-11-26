import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjetoCadastroPage extends StatefulWidget {
  @override
  _ProjetoCadastroPageState createState() => _ProjetoCadastroPageState();
}

class _ProjetoCadastroPageState extends State<ProjetoCadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _localOuValorController = TextEditingController();
  bool _isVaquinha = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 1; // Definir o índice da Recompensas como selecionado

  // Método para alternar o rótulo do campo "Local do projeto / Valor"
  String get _labelText => _isVaquinha ? 'Valor' : 'Local do projeto';

  // Método para fazer logout
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Redireciona para a página de login
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

  // Método para salvar o projeto no Firestore com verificação de campos vazios
  Future<void> _salvarProjeto() async {
    try {
      // Verifica se os campos obrigatórios estão preenchidos
      if (_nomeController.text.trim().isEmpty ||
          _descricaoController.text.trim().isEmpty ||
          _localOuValorController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios!')),
        );
        return;
      }

      // Obtém o usuário logado
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Cria o mapa de dados do projeto
      Map<String, dynamic> projetoData = {
        'nome': _nomeController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'localOuValor': _localOuValorController.text.trim(),
        'vaquinha': _isVaquinha,
        'verificado': false,
        'tipo': 'indefinido',
      };

      // Salva o projeto na coleção do Firestore
      await _firestore
          .collection('Usuarios')
          .doc(user.displayName)
          .collection('Projetos')
          .add(projetoData);

      // Exibe mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Projeto salvo com sucesso!')),
      );

      // Limpa os campos após o envio
      _nomeController.clear();
      _descricaoController.clear();
      _localOuValorController.clear();
      setState(() {
        _isVaquinha = false;
      });
    } catch (e) {
      // Exibe mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar o projeto: $e')),
      );
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
      body: Stack(
        children: [
          // Imagem de fundo
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
          // Conteúdo da página
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Corpo da página (campos de entrada e botões)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Campo para o nome do projeto
                        TextField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome do projeto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Campo para a descrição do projeto
                        TextField(
                          controller: _descricaoController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Descrição do projeto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Checkbox "Vaquinha"
                        Row(
                          children: [
                            Checkbox(
                              value: _isVaquinha,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isVaquinha = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Vaquinha',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Campo "Local do projeto" ou "Valor"
                        TextField(
                          controller: _localOuValorController,
                          decoration: InputDecoration(
                            labelText: _labelText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          keyboardType:
                              _isVaquinha ? TextInputType.number : TextInputType.text,
                        ),
                        const SizedBox(height: 40),

                        // Botões de enviar e cancelar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                              ),
                              onPressed: _salvarProjeto,
                              child: const Text('Enviar'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                              ),
                              onPressed: () {
                                // Limpa os campos ao cancelar
                                _nomeController.clear();
                                _descricaoController.clear();
                                _localOuValorController.clear();
                                setState(() {
                                  _isVaquinha = false;
                                });
                              },
                              child: const Text('Cancelar'),
                            ),
                          ],
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
      // Bottom Navigation Bar
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