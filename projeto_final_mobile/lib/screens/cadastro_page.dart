import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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

  Future<void> _cadastrarUsuario(BuildContext context) async {
    final String nome = _nomeController.text.trim();
    final String email = _emailController.text.trim();
    final String senha = _senhaController.text.trim();
    final String confirmarSenha = _confirmarSenhaController.text.trim();
    final String telefone = _telefoneController.text.trim();
    final String cpf = _cpfController.text.trim();

    if (nome.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty ||
        telefone.isEmpty ||
        cpf.isEmpty) {
      _showErrorDialog(context, 'Por favor, preencha todos os campos.');
      return;
    }

    if (senha != confirmarSenha) {
      _showErrorDialog(context, 'As senhas não coincidem.');
      return;
    }

    if (!_validarCPF(cpf)) {
      _showErrorDialog(context, 'CPF inválido.');
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await userCredential.user?.updateDisplayName(nome);
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
              Navigator.pushReplacementNamed(context, '/login');
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
      appBar: AppBar(
        title: Text('Cadastro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(_nomeController, 'Nome'),
            SizedBox(height: 15),
            _buildTextField(_emailController, 'E-mail',
                keyboardType: TextInputType.emailAddress),
            SizedBox(height: 15),
            _buildTextField(_senhaController, 'Senha', obscureText: true),
            SizedBox(height: 15),
            _buildTextField(_confirmarSenhaController, 'Confirmar Senha',
                obscureText: true),
            SizedBox(height: 15),
            _buildTextField(_telefoneController, 'Telefone',
                keyboardType: TextInputType.phone),
            SizedBox(height: 15),
            _buildTextField(
              _cpfController,
              'CPF',
              keyboardType: TextInputType.number,
              inputFormatters: [maskFormatterCPF],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _cadastrarUsuario(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black87),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.orange),
          ),
        ),
      ),
    );
  }
}
