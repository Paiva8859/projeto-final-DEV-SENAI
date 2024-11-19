import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (user != null)
              Text(
                user.displayName ?? "Nome",
                style: TextStyle(color: Colors.orange, fontSize: 16),
              ),
            SizedBox(width: 10),
            TextButton(
              onPressed: () => _logout(context),
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/ilustracao.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "De ajuda em ajuda\n",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: "o mundo se torna ",
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: "melhor.",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Encontre Locais Próximos a você!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/mapa.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "Conteúdo adicional aqui",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFooterIcon(
                context,
                Icons.home,
                "Início",
                Colors.orange,
              ),
              _buildFooterIcon(
                context,
                Icons.location_on,
                "Locais",
                Colors.black,
              ),
              _buildFooterIcon(
                context,
                Icons.emoji_events,
                "Conquistas",
                Colors.black,
              ),
              _buildFooterIcon(
                context,
                Icons.settings,
                "Configurações",
                Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterIcon(
      BuildContext context, IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 30, color: color),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }
}
