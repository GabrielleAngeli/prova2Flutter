import 'package:flutter/material.dart'; //import para criar as UIs do usuário
import 'package:firebase_database/firebase_database.dart'; // import para banco de dados em tempo real do Firebase.

class RegistrationScreen extends StatefulWidget {
  final String? tennisId; // Chave para buscar os dados do Firebase (opcional, caso seja a tela de edição)
  final Map<String, dynamic>? tennisData; // Dados do tênis (opcional, para edição)

  const RegistrationScreen({Key? key, this.tennisId, this.tennisData}) : super(key: key);

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  //Controladores para os campos de texto de entrada.
  TextEditingController tcModelo = TextEditingController();
  TextEditingController tcMarca = TextEditingController();
  TextEditingController tcTamanho = TextEditingController();

  //Referência ao nó 'tennis' no banco de dados do Firebase.
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('tennis');

  @override
  void initState() {
    super.initState();
    // Se os dados do tennisData estiverem presentes (edição de item existente), ele preenche os campos de texto.
    if (widget.tennisData != null) {
      tcModelo.text = widget.tennisData!['modelo'] ?? '';
      tcMarca.text = widget.tennisData!['marca'] ?? '';
      tcTamanho.text = widget.tennisData!['tamanho'] ?? '';
    }

    // Listeners para verificar os inputs
    tcModelo.addListener(_checkFields);
    tcMarca.addListener(_checkFields);
    tcTamanho.addListener(_checkFields);
  }

  // Método que verifica se todos os campos estão preenchidos par aliberar botão de salvar
  bool _areFieldsValid() {
    return tcModelo.text.isNotEmpty && tcMarca.text.isNotEmpty && tcTamanho.text.isNotEmpty;
  }

  // Método que será chamado sempre que um dos campos for alterado
  void _checkFields() {
    setState(() {});
  }

  Future<void> _addTennis() async {
    Map<String, String> tennisData = {
      'modelo': tcModelo.text,
      'marca': tcMarca.text,
      'tamanho': tcTamanho.text,
    };
    await _database.push().set(tennisData);
  }

  Future<void> _deleteTennis(String tennisId) async {
    await _database.child(tennisId).remove();
  }

  @override
  Widget build(BuildContext context) {
    bool isViewMode = widget.tennisData != null;  // Verifique se é modo de visualização (edição)

    return Scaffold(
      appBar: AppBar(title: Text(
        isViewMode ? 'Editar Tênis' : 'Cadastro de Novo Tênis',
      )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Modelo input
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                const Text(
                  "MODELO: ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 45.0,
                    child: TextField(
                      controller: tcModelo,
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(fontSize: 20),
                        hintText: 'modelo do tênis',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      readOnly: isViewMode,  // Defina como somente leitura em modo de visualização
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Marca input
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                const Text(
                  "MARCA: ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 45.0,
                    child: TextField(
                      controller: tcMarca,
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(fontSize: 20),
                        hintText: 'marca do tênis',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      readOnly: isViewMode,  // Defina como somente leitura em modo de visualização
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tamanho input
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                const Text(
                  "TAMANHO: ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 45.0,
                    child: TextField(
                      controller: tcTamanho,
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(fontSize: 20),
                        hintText: 'tamanho do tênis',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      readOnly: isViewMode,  // Defina como somente leitura em modo de visualização
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botões de ação (Adicionar/Excluir)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                if (isViewMode)
                  Expanded(
                    child: ElevatedButton(
                      child: const Text('EXCLUIR'),
                      onPressed: () async {
                        if (widget.tennisData != null) {
                          bool? confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmar Exclusão'),
                                content: const Text('Você tem certeza que deseja excluir este tênis?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('CANCELAR'),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('CONFIRMAR'),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            await _deleteTennis(widget.tennisData!['id']);
                            Navigator.pop(context, true);
                          }
                        }
                      },
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      child: const Text('ADICIONAR'),
                      onPressed: _areFieldsValid() ? () async {
                        await _addTennis();
                        Navigator.pop(context, true);
                      } : null,  // Desabilita o botão se os campos não forem válidos
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    child: const Text('CANCELAR'),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
