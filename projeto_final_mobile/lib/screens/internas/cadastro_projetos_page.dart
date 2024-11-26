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

  String get _labelText => _isVaquinha ? 'Valor' : 'Local do projeto';

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _salvarProjeto() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      Map<String, dynamic> projetoData = {
        'nome': _nomeController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'localOuValor': _localOuValorController.text.trim(),
        'vaquinha': _isVaquinha,
        'verificado': false,
        'tipo': 'indefinido',
      };

      await _firestore
          .collection('Usuarios')
          .doc(user.displayName)
          .collection('Projetos')
          .add(projetoData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Projeto salvo com sucesso!')),
      );

      _nomeController.clear();
      _descricaoController.clear();
      _localOuValorController.clear();
      setState(() {
        _isVaquinha = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar o projeto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;


    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      appBar: AppBar(
        elevation: 5,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6F17), Color(0xFF302F2F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Cadastro de Projetos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/usuario'),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF302F2F),
                  child: Text(
                    user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do projeto',
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF302F2F),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descricaoController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Descrição do projeto',
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF302F2F),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  activeColor: const Color(0xFFF7A26D),
                  value: _isVaquinha,
                  onChanged: (bool? value) {
                    setState(() {
                      _isVaquinha = value ?? false;
                    });
                  },
                ),
                const Text(
                  'Vaquinha',
                  style: TextStyle(fontSize: 16, color: Color(0xFF302F2F)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _localOuValorController,
              decoration: InputDecoration(
                labelText: _labelText,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF302F2F),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              keyboardType:
                  _isVaquinha ? TextInputType.number : TextInputType.text,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7A26D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  onPressed: _salvarProjeto,
                  child: const Text('Salvar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEBEBEB),
                    foregroundColor: Color(0xFF302F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {
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
        currentIndex: 0,
        selectedItemColor: const Color(0xFFF7A26D),
        unselectedItemColor: const Color(0xFF302F2F),
        type: BottomNavigationBarType.fixed,
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
