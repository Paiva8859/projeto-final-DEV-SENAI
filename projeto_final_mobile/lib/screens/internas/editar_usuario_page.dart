import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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

  // Máscaras para CPF e telefone
  final maskFormatterTelefone = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

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

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    final String nome = _nomeController.text.trim();
    final String telefone = _telefoneController.text.trim();
    final String email = _emailController.text.trim();

    // Verificando se todos os campos estão preenchidos
    if (nome.isEmpty || telefone.isEmpty || email.isEmpty) {
      _showErrorDialog('Por favor, preencha todos os campos.');
      return;
    }

    // Verificando o formato do número de telefone
    final RegExp telefoneRegExp = RegExp(r'^\(\d{2}\) \d{5}-\d{4}$');
    if (!telefoneRegExp.hasMatch(telefone)) {
      _showErrorDialog('O número de telefone deve estar no formato (##) #####-####.');
      return;
    }

    // Verificando o formato do e-mail
    final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(email)) {
      _showErrorDialog('Por favor, insira um e-mail válido.');
      return;
    }

    try {
      String? nomeUsuario = _currentUser?.displayName ?? "Usuário Desconhecido";

      // Atualizar dados no Firestore
      await _firestore.collection('Usuarios').doc(nomeUsuario).update({
        'nome': nome,
        'telefone': telefone,
        'email': email,
      });

      // Verifique se o novo e-mail precisa ser atualizado
      if (email != _currentUser?.email) {
        await _reautenticarUsuario();
        await _enviarEmailVerificacaoNovoEmail(email);
      } else {
        _showSuccessDialog('Dados atualizados com sucesso!');
      }
    } catch (e) {
      print('Erro ao salvar alterações: $e');
      _showErrorDialog('Erro ao salvar alterações. Tente novamente.');
    }
  }

  // Função para reautenticar o usuário
  Future<void> _reautenticarUsuario() async {
    String? senha = await _showPasswordDialog();

    if (senha != null && senha.isNotEmpty) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: _currentUser!.email!,
          password: senha,
        );
        await _currentUser!.reauthenticateWithCredential(credential);
      } catch (e) {
        print('Erro na reautenticação: $e');
        _showErrorDialog('Erro na reautenticação. Tente novamente.');
      }
    }
  }

  // Função para enviar o e-mail de verificação para o novo e-mail
  Future<void> _enviarEmailVerificacaoNovoEmail(String novoEmail) async {
    try {
      if (_currentUser != null) {
        await _currentUser?.verifyBeforeUpdateEmail(novoEmail);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('E-mail de verificação enviado. Verifique sua caixa de entrada.')),
        );
        _monitorarVerificacaoEmail();
      }
    } catch (e) {
      print('Erro ao enviar e-mail de verificação para o novo e-mail: $e');
      _showErrorDialog('Erro ao enviar e-mail de verificação. Tente novamente.');
    }
  }

  // Monitorar o estado de verificação do e-mail
  void _monitorarVerificacaoEmail() {
    _auth.userChanges().listen((user) {
      if (user != null && user.emailVerified) {
        setState(() {
          _emailVerificado = true;
        });
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

  // Exibir um diálogo de erro
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Exibir um diálogo de sucesso
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sucesso'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Exibir o diálogo para inserir a senha para reautenticação
  Future<String?> _showPasswordDialog() async {
    TextEditingController _passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reautenticação Necessária'),
          content: TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Digite sua senha'),
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
                      inputFormatters: [maskFormatterTelefone], // Aplica a máscara
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
                    SizedBox(height: 16),
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
