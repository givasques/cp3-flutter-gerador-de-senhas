import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerador_de_senhas/routes.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final CollectionReference passwords = FirebaseFirestore.instance.collection(
    'passwords',
  );

  final TextEditingController titleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void addPassword() {
    final titleText = titleController.text;
    final passwordText = passwordController.text;
    if (titleText.isNotEmpty && passwordText.isNotEmpty) {
      passwords.add({'title': titleText, 'password': passwordText});
      titleController.clear();
      passwordController.clear();
    }
    if(mounted) {
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Nova Senha')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titulo da senha'),
                validator: (v) => (v == null || v.isEmpty) ? 'Preencha o nome' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                validator: (v) => (v == null || v.isEmpty) ? 'Preencha a senha' : null,
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: addPassword,
                child: const Text('Salvar Senha')
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {if(mounted) Navigator.pushReplacementNamed(context, Routes.home);},
                child: const Text('Voltar')
              )
            ],
          ),    
        ),
    )
    );
  }
}
