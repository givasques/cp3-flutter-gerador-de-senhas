import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gerador_de_senhas/routes.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference passwords = FirebaseFirestore.instance.collection(
    'passwords',
  );

  List<bool> obscureList = [];

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    void deletePassword(DocumentSnapshot doc) {
      passwords.doc(doc.id).delete();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 8),
            Text(
              'Gerador de Senhas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Text('Olá, ${user?.email}!'), SizedBox(width: 20)],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: Image.asset('assets/images/banner.png'),
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Suas Senhas',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: passwords.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Ocorreu um erro ao carregar os dados.',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: 50),
                        Lottie.asset(
                          'assets/lottie/nodata.json',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 25),
                        Text(
                          "Nenhuma senha cadastrada!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("Clique no + para cadastrar uma nova senha."),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                if (obscureList.length != docs.length) {
                  obscureList = List.generate(docs.length, (_) => true);
                }
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, index) {
                      final doc = docs[index];
                      return ListTile(
                        leading: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureList[index] = !obscureList[index];
                            });
                          },
                          icon: Icon(
                            obscureList[index]
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        title: Text(doc['title']),
                        subtitle: GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: doc['password']),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Senha copiada para a área de transferência!',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            obscureList[index] ? '••••••••' : doc['password'],
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () => deletePassword(doc),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushReplacementNamed(context, Routes.password),
        child: Icon(Icons.add),
      ),
    );
  }
}
