import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerador_de_senhas/routes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:gerador_de_senhas/widgets/password_result.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final CollectionReference passwords = FirebaseFirestore.instance.collection(
    'passwords',
  );

  String generatedPassword = "Clique em gerar senha";
  double passwordLength = 12;

  bool lowerCase = true;
  bool upperCase = true;
  bool numbers = true;
  bool symbols = true;

  bool showOptions = false;

  bool hasGenerated = false;

  void addPassword(String nome, String password) {
    if (nome.isNotEmpty && password.isNotEmpty) {
      passwords.add({'title': nome, 'password': password});
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Missão concluida! Senha salva com sucesso!',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  Future<void> generatePassword() async {
    final url = "https://safekey-api-a1bd9aa97953.herokuapp.com/generate";

    final Map<String, dynamic> data = {
      "length": passwordLength.toInt(),
      "includeLowercase": lowerCase,
      "includeUppercase": upperCase,
      "includeNumbers": numbers,
      "includeSymbols": symbols,
    };

    debugPrint('REQUEST -> $data');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          generatedPassword = data["password"];
          hasGenerated = true;
        });
      } else {
        setState(() => generatedPassword = "Erro no servidor");
      }
    } catch (e) {
      setState(() => generatedPassword = "Erro de conexão: $e");
    }
  }

  void _showNameDialog(BuildContext context, String password) {
    final TextEditingController _nameController = TextEditingController();
    final _formKey = GlobalKey<FormState>(); // NOVO

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nome da senha"),
          content: Form(
            key: _formKey, // NOVO
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: "Digite um nome"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O nome é obrigatório';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // fecha sem salvar
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                // se o formulário for válido, salva
                if (_formKey.currentState!.validate()) {
                  final nome = _nameController.text.trim();
                  Navigator.pop(context);
                  addPassword(nome, password);
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
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
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sobre Gerador de Senhas'),
                  content: const Text(
                    'Este é um gerador de senhas criado em Flutter.\n'
                    'Você pode selecionar tamanho, caracteres especiais, números e mais.\n'
                    'Depois de selecionado, basta clicar em Gerar Senha.\n'
                    'No canto inferior direito da página você encontrará um botão que permitirá nomear aquela senha para salvá-la na sua lista de senhas.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(width: 16),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 109, 131, 188),
        onPressed: hasGenerated
            ? () => _showNameDialog(context, generatedPassword)
            : null, // botão de salvar no Firestore depois
        child: const Icon(Icons.save, color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              PasswordResultWidget(password: generatedPassword),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() => showOptions = !showOptions);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(showOptions ? "Ocultar opções" : "Exibir opções"),
                    const SizedBox(width: 6),
                  ],
                ),
              ),

              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                firstChild: options(),
                secondChild: Container(),
                crossFadeState: showOptions
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: generatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 109, 131, 188),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Gerar Senha",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget options() {
    return Column(
      children: [
        const SizedBox(height: 8),

        Text("Tamanho da senha: ${passwordLength.toInt()}"),
        Slider(
          value: passwordLength,
          min: 4,
          max: 32,
          divisions: 28,
          activeColor: Color.fromARGB(255, 109, 131, 188),
          onChanged: (v) => setState(() => passwordLength = v),
        ),

        buildSwitch("Incluir letras minúsculas", lowerCase, (v) {
          setState(() => lowerCase = v);
        }),

        buildSwitch("Incluir letras maiúsculas", upperCase, (v) {
          setState(() => upperCase = v);
        }),

        buildSwitch("Incluir números", numbers, (v) {
          setState(() => numbers = v);
        }),

        buildSwitch("Incluir símbolos", symbols, (v) {
          setState(() => symbols = v);
        }),
      ],
    );
  }

  Widget buildSwitch(String text, bool value, Function(bool) onChange) {
    return SwitchListTile(
      title: Text(text),
      value: value,
      activeColor: Color.fromARGB(255, 109, 131, 188),
      onChanged: onChange,
    );
  }
}
