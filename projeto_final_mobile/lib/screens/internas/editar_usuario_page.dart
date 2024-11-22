import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarUsuarioPage extends StatefulWidget {
  @override
  _EditarUsuarioPageState createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  User? _currentUser;
  bool _loading = true;
  bool _emailVerificado = false;

  Future<void> _fetchUserData() async {
    try {
      _currentUser = _auth.currentUser;
      if (_currentUser == null) return;

      String? nomeUsuario = _currentUser!.displayName ?? "Usuário Desconhecido";

      DocumentSnapshot userSnapshot =
          await _firestore.collection('Usuarios').doc(nomeUsuario).get();

      if (userSnapshot.exists) {
        final data = userSnapshot.data() as Map<String, dynamic>;
        _nomeController.text = data['nome'] ?? '';
        _telefoneController.text = data['telefone'] ?? '';
        _emailController.text = data['email'] ?? '';
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  // Função para enviar o e-mail de verificação para o novo e-mail
  Future<void> _enviarEmailVerificacaoNovoEmail(String novoEmail) async {
    try {
      if (_currentUser != null) {
        // Envia um e-mail de verificação para o novo e-mail antes de atualizá-lo
        await _currentUser?.verifyBeforeUpdateEmail(novoEmail);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'E-mail de verificação enviado para $novoEmail. Verifique sua caixa de entrada antes de continuar.')),
        );

        // Monitorar o estado de verificação do e-mail
        _monitorarVerificacaoEmail();
      }
    } catch (e) {
      print('Erro ao enviar e-mail de verificação para o novo e-mail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erro ao enviar e-mail de verificação para o novo e-mail.')),
      );
    }
  }

  // Função para monitorar a verificação do e-mail
  void _monitorarVerificacaoEmail() {
    _auth.userChanges().listen((user) {
      if (user != null && user.emailVerified) {
        setState(() {
          _emailVerificado = true;
        });
        // Chama a função para finalizar a atualização após a verificação
        _finalizarAtualizacao();
      }
    });
  }

  // Finalizar a atualização após a verificação do e-mail
  void _finalizarAtualizacao() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dados atualizados com sucesso!')),
    );
    Navigator.pop(context);
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String? nomeUsuario = _currentUser?.displayName ?? "Usuário Desconhecido";

      // Atualizar dados no Firestore
      await _firestore.collection('Usuarios').doc(nomeUsuario).update({
        'nome': _nomeController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'email': _emailController.text.trim(),
      });

      // Verifique se o novo e-mail precisa ser atualizado
      String novoEmail = _emailController.text.trim();
      if (novoEmail != _currentUser?.email) {
        // Reautenticar o usuário antes de atualizar o e-mail
        await _reautenticarUsuario(context);

        // Enviar email de verificação para o novo e-mail
        await _enviarEmailVerificacaoNovoEmail(novoEmail);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dados atualizados com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Erro ao salvar alterações: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar alterações.')),
      );
    }
  }

  Future<void> _reautenticarUsuario(BuildContext context) async {
    // Solicita a senha do usuário para reautenticação
    String? senha = await _showPasswordDialog(context);

    if (senha != null && senha.isNotEmpty) {
      try {
        // Cria as credenciais do usuário com o e-mail e a senha fornecidos
        AuthCredential credential = EmailAuthProvider.credential(
          email: _currentUser!.email!,
          password: senha,
        );

        // Reautentica o usuário
        await _currentUser!.reauthenticateWithCredential(credential);
      } catch (e) {
        print('Erro na reautenticação: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na reautenticação.')),
        );
      }
    }
  }

  // Exibe um diálogo para o usuário inserir a senha para reautenticação
  Future<String?> _showPasswordDialog(BuildContext context) async {
    TextEditingController _passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reautenticação Necessária'),
          content: TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Digite sua senha',
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, _passwordController.text),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Editar Usuário'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _telefoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu telefone';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu e-mail';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Por favor, insira um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _salvarAlteracoes,
                      child: Text('Salvar Alterações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
