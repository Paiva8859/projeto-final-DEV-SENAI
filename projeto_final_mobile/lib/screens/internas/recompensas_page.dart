import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecompensasPage extends StatefulWidget {
  @override
  _RecompensasPageState createState() => _RecompensasPageState();
}

class _RecompensasPageState extends State<RecompensasPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _loading = true;
  int _selectedIndex = 2; // Define o índice da Recompensas como selecionado
  int _moedas = 0; // Valor da carteira do usuário
  String? _recompensaSelecionada; // ID da recompensa selecionada

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchMoedas();
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

  void _selecionarRecompensa(String idRecompensa) {
    setState(() {
      _recompensaSelecionada = idRecompensa;
    });
  }

  Future<void> _comprarRecompensa() async {
    if (_recompensaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhuma recompensa selecionada.')),
      );
      return;
    }

    try {
      // Busca os detalhes da recompensa selecionada
      DocumentSnapshot recompensaSnapshot = await _firestore
          .collection('Recompensas')
          .doc(_recompensaSelecionada)
          .get();

      final recompensaData = recompensaSnapshot.data() as Map<String, dynamic>?;

      if (recompensaData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar a recompensa selecionada.')),
        );
        return;
      }

      int preco = recompensaData['preco'] ?? 0; // Preço da recompensa
      String titulo = recompensaData['titulo'] ?? 'Recompensa';

      // Verifica se o usuário tem moedas suficientes
      if (_moedas < preco) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Você não tem moedas suficientes para comprar "$titulo".'),
          ),
        );
        return;
      }

      // Subtraia o preço da recompensa das moedas do usuário
      String? nomeUsuario = _currentUser?.displayName;
      if (nomeUsuario == null || nomeUsuario.isEmpty) return;

      await _firestore.collection('Usuarios').doc(nomeUsuario).update({
        'carteira': _moedas - preco,
      });

      // Atualiza o estado local das moedas
      setState(() {
        _moedas -= preco;
      });

      // Exibe mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você comprou "$titulo" com sucesso!'),
        ),
      );

      // Limpa a seleção após a compra
      setState(() {
        _recompensaSelecionada = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao comprar recompensa: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _auth.signOut(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('Recompensas').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Nenhuma recompensa disponível.'),
                        );
                      }

                      final recompensas = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: recompensas.length,
                        itemBuilder: (context, index) {
                          final recompensa = recompensas[index];
                          final recompensaId = recompensa.id;
                          final data =
                              recompensa.data() as Map<String, dynamic>;
                          final selecionada =
                              _recompensaSelecionada == recompensaId;

                          return GestureDetector(
                            onTap: () => _selecionarRecompensa(recompensaId),
                            child: Card(
                              color: selecionada
                                  ? Colors.orange.shade100
                                  : Colors.white,
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['titulo'] ?? 'Título não disponível',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Descrição: ${data['descricao'] ?? ''}',
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Quantidade: ${data['quantidade'] ?? 0}',
                                    ),
                                    Text(
                                      'Data de início: ${data['dataInicio'] ?? ''}',
                                    ),
                                    Text(
                                      'Data de expiração: ${data['dataExpiracao'] ?? ''}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _comprarRecompensa,
                    child: const Text('Comprar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 24.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
