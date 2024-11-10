import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'registrationScreen.dart';

class TennisList extends StatefulWidget {
  const TennisList({super.key});

  @override
  State createState() => TennisListState();
}

class TennisListState extends State<TennisList> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('tennis');
  List<Map<String, dynamic>> itens = [];

  @override
  void initState() {
    super.initState();
    _loadTennis();
  }

  void _loadTennis() {
    // Observa mudanças no nó "tennis" em tempo real.
    _database.onValue.listen((event) {
      final dataSnapshot = event.snapshot;
      final List<Map<String, dynamic>> loadedTennis = [];
      if (dataSnapshot.value != null) {
        final Map<String, dynamic> tennisMap = Map<String, dynamic>.from(dataSnapshot.value as Map);
        tennisMap.forEach((key, value) {
          loadedTennis.add({
            'id': key, // Chave do Firebase como identificador
            ...Map<String, dynamic>.from(value) // Dados do item
          });
        });
      }
      setState(() {
        itens = loadedTennis;
      });
    });
  }

  void _abreTelaDigitacao(BuildContext context, [Map<String, dynamic>? tennisData]) async {
    var resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // Se tennisData for null, passa como parâmetro padrão para um novo cadastro
          return RegistrationScreen(tennisData: tennisData);
        },
      ),
    );
    if (resultado == true) {
      _loadTennis(); // Atualiza os dados ao voltar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Tênis')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: itens.isEmpty
                ? const Center(
              child: Text(
                'Nenhum tênis cadastrado',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: itens.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext _context, int i) {
                return _buildRow(i);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _abreTelaDigitacao(context);
        },
        tooltip: 'Incluir Novo Tênis',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRow(int i) {
    var item = itens[i];
    return Card(
      color: Colors.teal[50],
      child: ListTile(
        title: Text(
          item['modelo'] ?? 'Modelo Desconhecido',
          style: const TextStyle(fontSize: 24),
        ),
        subtitle: Text(
          'Marca: ${item['marca'] ?? 'Indefinida'}\nTamanho: ${item['tamanho'] ?? 'Indefinido'}',
          style: const TextStyle(fontSize: 18),
        ),
        onTap: () {
          _abreTelaDigitacao(context, item);
        },
      ),
    );
  }
}
