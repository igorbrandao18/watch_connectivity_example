import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import necessário para o MethodChannel

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Apple Watch Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Send Text to Apple Watch'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _receivedText = "";
  final TextEditingController _textController = TextEditingController();

  // Método de canal para se comunicar com o código nativo
  static const platform = MethodChannel('com.example.watch');

  @override
  void initState() {
    super.initState();

    // Escutar mensagens vindas do iPhone (via canal nativo)
    platform.setMethodCallHandler((call) async {
      if (call.method == "receivedMessage") {
        setState(() {
          _receivedText = call.arguments as String;
        });
        print("Mensagem recebida no Flutter: $_receivedText");
      }
    });
  }

  // Enviar texto ao Apple Watch via MethodChannel
  Future<void> _sendTextToAppleWatch() async {
    final textToSend = _textController.text;

    try {
      await platform.invokeMethod('sendMessage', {'text': textToSend});
      print('Mensagem enviada ao Apple Watch via iPhone: $textToSend');
    } on PlatformException catch (e) {
      print('Erro ao enviar mensagem via MethodChannel: ${e.message}');
    }

    // Limpar o campo de texto após o envio
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Digite o texto para enviar ao Apple Watch',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendTextToAppleWatch,
              child: const Text('Enviar para Apple Watch via iPhone'),
            ),
            const SizedBox(height: 20),
            Text(
              'Recebido do Apple Watch: $_receivedText',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}