import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroPage extends StatelessWidget {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  // Máscara para o campo de CPF
  final maskFormatterCPF = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Configura o TextInputFormatter para o campo de Telefone
  final maskFormatterTelefone = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  Future<void> _cadastrarUsuario(BuildContext context) async {
    final String nome = _nomeController.text.trim();
    final String email = _emailController.text.trim();
    final String senha = _senhaController.text.trim();
    final String confirmarSenha = _confirmarSenhaController.text.trim();
    final String telefone = _telefoneController.text.trim();
    final String cpf = _cpfController.text.trim();

    // Verificando se todos os campos estão preenchidos
    if (nome.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty ||
        telefone.isEmpty ||
        cpf.isEmpty) {
      _showErrorDialog(context, 'Por favor, preencha todos os campos.');
      return;
    }

    // Verificando se as senhas são iguais
    if (senha != confirmarSenha) {
      _showErrorDialog(context, 'As senhas não coincidem.');
      return;
    }

    // Validando a senha mínima de 8 caracteres
    if (senha.length < 8) {
      _showErrorDialog(context, 'A senha deve ter pelo menos 8 caracteres.');
      return;
    }

    // Verificando CPF
    if (!_validarCPF(cpf)) {
      _showErrorDialog(context, 'CPF inválido.');
      return;
    }

    try {
      // Criando o usuário com o Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Atualizando o nome do usuário no Firebase Auth
      await userCredential.user?.updateDisplayName(nome);

      // Salvando os dados adicionais no Firestore
      await FirebaseFirestore.instance.collection('Usuarios').doc(nome).set({
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'cpf': cpf,
      });

      _showSuccessDialog(context, 'Cadastro realizado com sucesso!');
      _limparCampos();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'O e-mail já está em uso.';
          break;
        case 'weak-password':
          errorMessage = 'A senha é muito fraca.';
          break;
        case 'invalid-email':
          errorMessage = 'O e-mail é inválido.';
          break;
        default:
          errorMessage = 'Erro desconhecido. Tente novamente.';
      }
      _showErrorDialog(context, errorMessage);
    } catch (e) {
      _showErrorDialog(
          context, 'Erro ao cadastrar. Por favor, tente novamente.');
    }
  }

  void _limparCampos() {
    _nomeController.clear();
    _emailController.clear();
    _senhaController.clear();
    _confirmarSenhaController.clear();
    _telefoneController.clear();
    _cpfController.clear();
  }

  void _showErrorDialog(BuildContext context, String message) {
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

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sucesso'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, '/login'); // Redireciona para a página de login
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _validarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11 || RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // title: const Text('Cadastro', style: TextStyle(color: Colors.black)),
        // centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Login',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Cadastro',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(_nomeController, 'Nome'),
                const SizedBox(height: 15),
                _buildTextField(_emailController, 'E-mail',
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 15),
                _buildTextField(_senhaController, 'Senha', obscureText: true),
                const SizedBox(height: 15),
                _buildTextField(_confirmarSenhaController, 'Confirmar Senha',
                    obscureText: true),
                const SizedBox(height: 15),
                _buildTextField(_telefoneController, 'Telefone',
                    maskFormatter: maskFormatterTelefone),
                const SizedBox(height: 15),
                _buildTextField(_cpfController, 'CPF',
                    maskFormatter: maskFormatterCPF),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _cadastrarUsuario(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Já tem uma conta? Faça login.',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Image.asset(
        'assets/imagem-de-fundo(cadastro-e-login).png', // Caminho da imagem
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text,
      bool obscureText = false,
      MaskTextInputFormatter? maskFormatter}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: maskFormatter != null ? [maskFormatter] : [],
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: UnderlineInputBorder(),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange)),
      ),
    );
  }
}
